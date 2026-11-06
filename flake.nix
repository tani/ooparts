{
  description = "OOPArts: package-inferred Common Lisp libraries and tests";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ flake-parts.flakeModules.easyOverlay ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      perSystem = { config, pkgs, lib, system, ... }:
        let
          src = lib.cleanSource ./.;
          python = pkgs.python3.withPackages (ps: [ ps.pycparser ]);
          implementations = {
            sbcl = { program = "sbcl"; args = "--noinform --disable-debugger"; eval = "--eval"; };
            ecl = { program = "ecl"; args = "-norc"; eval = "--eval"; };
            abcl = { program = "abcl"; args = "--noinform --noinit"; eval = "--eval"; };
            ccl = { program = "ccl"; args = "--quiet --no-init"; eval = "--eval"; };
            mkcl = { program = "mkcl"; args = "-norc"; eval = "-eval"; };
            clisp = { program = "clisp"; args = "-q -norc"; eval = "-x"; };
            cmucl_binary = { program = "lisp"; args = "-quiet -noinit"; eval = "-eval"; };
            clasp-common-lisp = { program = "clasp"; args = "--noinform --norc"; eval = "--eval"; };
          };
          available = lib.filterAttrs (impl: _: let
            candidate = builtins.tryEval pkgs.${impl};
          in candidate.success
            && lib.meta.availableOn pkgs.stdenv.hostPlatform candidate.value
            && !(candidate.value.meta.broken or false)
          ) implementations;
          # The locked ABCL package already selects OpenJDK 17 internally.
          lispFor = impl: if impl == "mkcl" then pkgs.wrapLisp {
            pkg = pkgs.mkcl;
            faslExt = "fas";
            # Apply before ASDF itself is compiled, as well as in packaged REPLs.
            flags = [ "-norc" "-load" "${./tools/advice/mkcl-gnu11.lisp}" ];
          } else pkgs.${impl};
          components = {
            curry = { library = "ooparts/curry"; tests = "ooparts-tests/curry"; };
            test = { library = "ooparts/test"; tests = "ooparts-tests/test"; };
            readline = { library = "ooparts/readline"; tests = "ooparts-tests/readline"; };
            advice = { library = "ooparts/advice"; tests = "ooparts-tests/advice"; };
            curses = { library = "ooparts/curses"; tests = "ooparts-tests/curses"; };
            prolog = { library = "ooparts/prolog"; tests = "ooparts-tests/prolog"; };
            continuation = { library = "ooparts/continuation"; tests = "ooparts-tests/continuation"; };
            sat = { library = "ooparts/sat"; tests = "ooparts-tests/sat"; };
            regexp = { library = "ooparts/regexp"; tests = "ooparts-tests/regexp"; };
            all = { library = "ooparts"; tests = "ooparts-tests"; };
          };
          # Every component is offered for every available implementation.
          # MKCL needs the internal adapters in src/continuation/environment.lisp
          # and src/continuation/runtime.lisp because its compiler package and
          # macro-environment representation differ from ECL's.
          supported = component: impl: true;
          recipes = lib.listToAttrs (lib.concatMap (component:
            lib.mapAttrsToList (impl: options: let
              settings = components.${component};
              lisp = lispFor impl;
              library = lisp.buildASDFSystem {
                pname = "ooparts-${component}";
                version = "0.2.0";
                inherit src;
                systems = [ settings.library settings.tests ]
                  ++ lib.optionals (component == "curry" || component == "all") [ "ooparts/curry/user" ]
                  ++ lib.optionals (component == "prolog" || component == "all") [ "ooparts/prolog/text/cli" ]
                  ++ lib.optionals (component == "sat" || component == "all") [ "ooparts/sat/cli" ];
                lispLibs = [];
                nativeLibs = [];
                preBuild = ''export XDG_CACHE_HOME="$TMPDIR/asdf-cache"'';
                # Nixpkgs filters ASD filenames against the compiled system names.
                # Inferred children need both primary definitions at runtime, while
                # compiling those primaries would load unrelated sibling libraries.
                postInstall = ''cp ooparts.asd ooparts-tests.asd "$out/"'';
              };
              runtime = lisp.withPackages (_: [ library ]);
              testPackage = if component == "all" then "ooparts-tests/all" else settings.tests;
              test = pkgs.writeShellScriptBin "ooparts-test" ''
                exec ${runtime}/bin/${options.program} ${options.args} \
                  ${options.eval} '(require "asdf")' \
                  ${options.eval} '(handler-case (progn (asdf:load-system "${settings.tests}") (uiop:symbol-call :${testPackage} :run-tests) (uiop:quit 0)) (error (condition) (format *error-output* "~&~A~%" condition) (uiop:quit 1)))'
              '';
              repl = pkgs.writeShellScriptBin "ooparts-repl" ''
                exec ${runtime}/bin/${options.program} ${options.args} \
                  ${options.eval} '(require "asdf")' \
                  ${options.eval} '(asdf:load-system "${if component == "curry" then "ooparts/curry/user" else settings.library}")' \
                  ${lib.optionalString (component == "curry") ''${options.eval} '(ooparts/curry/user:enter)' \
                  ''}${lib.optionalString (impl == "clisp") "-repl"} "$@"
              '';
              check = pkgs.runCommand "ooparts-test-${component}-${impl}" {
                nativeBuildInputs = lib.optionals (builtins.elem component [ "curses" "readline" "curry" "all" ]) [ pkgs.python3 ];
              } ''
                export XDG_CACHE_HOME="$TMPDIR/asdf-cache"
                ${lib.optionalString (component == "continuation" || component == "all") ''
                  export OOPARTS_CONT_FIXTURE_FASL="$TMPDIR/fixture.fasl"
                  cd ${src}
                  for script in compile-fixture load-fixture; do
                    ${runtime}/bin/${options.program} ${options.args} \
                      ${options.eval} '(require "asdf")' \
                      ${options.eval} '(load "tools/continuation/'"$script"'.lisp")' \
                      ${options.eval} '(uiop:quit 0)'
                  done
                ''}
                ${test}/bin/ooparts-test
                ${lib.optionalString (component == "curry" || component == "all") ''
                  python3 ${src}/tools/curry/generate-cl.py --check
                  export OOPARTS_CURRY_BUILD_DIRECTORY="$TMPDIR/curry/"
                  ${runtime}/bin/${options.program} ${options.args} \
                    ${options.eval} '(load "${src}/tools/curry/compile-clean.lisp")' \
                    ${options.eval} '(uiop:quit 0)'
                ''}
                ${lib.optionalString (component == "curses") ''
                  export JAVA_TOOL_OPTIONS="--add-modules=jdk.incubator.foreign --enable-native-access=ALL-UNNAMED"
                  cp -R ${src} source
                  chmod -R u+w source
                  cd source
                  python3 -m unittest discover -s tests/curses -p 'test_*.py' -v
                  python3 tools/curses/coverage.py --implementation ${
                    if impl == "cmucl_binary" then "cmucl"
                    else if impl == "clasp-common-lisp" then "clasp" else impl
                  } --lisp ${runtime}/bin/${options.program}
                  python3 tools/curses/test-terminal.py --implementation ${
                    if impl == "cmucl_binary" then "cmucl"
                    else if impl == "clasp-common-lisp" then "clasp" else impl
                  } --lisp ${runtime}/bin/${options.program}
                ''}
                ${lib.optionalString (component == "readline") ''
                  export JAVA_TOOL_OPTIONS="--add-modules=jdk.incubator.foreign --enable-native-access=ALL-UNNAMED"
                  cp -R ${src} source
                  chmod -R u+w source
                  cd source
                  python3 tools/readline/test-terminal.py --implementation ${
                    if impl == "cmucl_binary" then "cmucl"
                    else if impl == "clasp-common-lisp" then "clasp" else impl
                  } --lisp ${runtime}/bin/${options.program}
                ''}
                touch "$out"
              '';
            in lib.nameValuePair "${component}-${impl}" {
              inherit library runtime test repl check;
            }) (lib.filterAttrs (impl: _: supported component impl) available)
          ) (builtins.attrNames components));
          packagesFor = prefix: field: lib.mapAttrs' (name: value:
            lib.nameValuePair "${prefix}-${name}" value.${field}) recipes;
          appsFor = prefix: field: command: lib.mapAttrs' (name: value:
            lib.nameValuePair "${prefix}-${name}" {
              type = "app";
              program = "${value.${field}}/bin/${command}";
            }) recipes;
          defaultRecipe = if recipes ? all-sbcl then recipes.all-sbcl else if recipes ? prolog-sbcl then recipes.prolog-sbcl else builtins.head (builtins.attrValues recipes);
          cliApp = component: module: let
            runtime = recipes."${component}-sbcl".runtime;
            entry = pkgs.writeText "ooparts-${component}-main.lisp" ''
              (require :asdf)
              (asdf:load-system "${module}")
              (uiop:symbol-call :${module} :main)
            '';
            command = pkgs.writeShellScriptBin "ooparts-${component}" ''
              exec ${runtime}/bin/sbcl --noinform --script ${entry} "$@"
            '';
          in { type = "app"; program = "${command}/bin/ooparts-${component}"; };
        in {
          packages = packagesFor "lib" "library" // packagesFor "test" "test"
            // packagesFor "repl" "repl" // { default = defaultRecipe.library; };
          apps = { default = { type = "app"; program = "${defaultRecipe.repl}/bin/ooparts-repl"; }; } // appsFor "test" "test" "ooparts-test" // appsFor "repl" "repl" "ooparts-repl"
            // lib.optionalAttrs (recipes ? prolog-sbcl) {
              prolog = cliApp "prolog" "ooparts/prolog/text/cli";
            } // lib.optionalAttrs (recipes ? sat-sbcl) {
              sat = cliApp "sat" "ooparts/sat/cli";
            };
          checks = lib.mapAttrs' (name: value: lib.nameValuePair "test-${name}" value.check) (lib.filterAttrs (name: _: lib.hasPrefix "all-" name || lib.hasPrefix "curses-" name || lib.hasPrefix "readline-" name) recipes)
            // {
              layout = pkgs.runCommand "ooparts-layout-and-licenses" {
                nativeBuildInputs = [ pkgs.python3 ];
              } ''
                cd ${src}
                python3 tools/check-layout.py
                touch "$out"
              '';
            };
          devShells = {
            default = pkgs.mkShell {
              packages = lib.mapAttrsToList (impl: _: lispFor impl) available
                ++ [ python pkgs.stdenv.cc ];
              shellHook = ''export CL_SOURCE_REGISTRY="$PWD//"'';
            };
          } // lib.mapAttrs (impl: _: pkgs.mkShell {
            packages = [ (lispFor impl) python pkgs.stdenv.cc ];
            shellHook = ''export CL_SOURCE_REGISTRY="$PWD//"'';
          }) available;
          overlayAttrs = lib.mapAttrs (impl: _: (lispFor impl).withOverrides
            (_: _: lib.listToAttrs (lib.concatMap (component:
              lib.optionals (supported component impl) [
                (lib.nameValuePair components.${component}.library
                  recipes."${component}-${impl}".library)
                (lib.nameValuePair components.${component}.tests
                  recipes."${component}-${impl}".library)
              ]) (builtins.attrNames components)))) available
            // lib.mapAttrs' (name: _: lib.nameValuePair "ooparts-${name}"
              config.packages."repl-${name}") recipes;
        };
    };
}
