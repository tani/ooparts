{
  description = "OOPArts: package-inferred Common Lisp libraries and tests";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ flake-parts.flakeModules.easyOverlay ];
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
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
          # The v0.9 API builds unsupported atomics on CMUCL and drops CLISP.
          # OOPArts needs the stable v0.8 recursive-lock/thread API only.
          lispFor = impl: pkgs.${impl}.withOverrides (self: super: {
            bordeaux-threads = if builtins.elem impl [ "clisp" "cmucl_binary" "mkcl" ] then pkgs.${impl}.buildASDFSystem {
              pname = "bordeaux-threads";
              version = "0.8.8";
              # ASDF's source registry needs an immutable directory, not the
              # archive filename supplied to a conventional unpack phase.
              src = pkgs.runCommand "bordeaux-threads-0.8.8-source" {
                nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ];
              } ''
                mkdir -p "$out"
                tar -xzf ${pkgs.fetchurl {
                  url = "https://deb.debian.org/debian/pool/main/b/bordeaux-threads/bordeaux-threads_0.8.8.orig.tar.gz";
                  hash = "sha256-bAEtA4UV9fpsow0LwkxNICIZhhofcIHBB37Fd9Uv+do=";
                }} --strip-components=1 -C "$out"
              '';
              systems = [ "bordeaux-threads" ];
              lispLibs = [ self.alexandria ];
            } else super.bordeaux-threads;
            cl-environments = super.cl-environments.overrideLispAttrs {
              # ASDF reads immutable SRC paths, so patch the source derivation.
              src = pkgs.runCommand "cl-environments-portable-source" {} ''
                cp -R ${super.cl-environments.src} "$out"
                chmod -R u+w "$out"
                substituteInPlace "$out/src/walker/cl-environments.lisp" \
                  --replace-fail '(defconstant +walk-macros+' '(defparameter +walk-macros+'
                substituteInPlace "$out/src/walker/environment.lisp" \
                  --replace-fail '(defconstant +optimize-qualities+' '(defparameter +optimize-qualities+' \
                  --replace-fail '(defconstant +global-special-vars+' '(defparameter +global-special-vars+'
              '';
            };
          });
          components = {
            prolog = { library = "ooparts/prolog"; tests = "ooparts-tests/prolog"; };
            continuation = { library = "ooparts/continuation"; tests = "ooparts-tests/continuation"; };
            sat = { library = "ooparts/sat"; tests = "ooparts-tests/sat"; };
            all = { library = "ooparts"; tests = "ooparts-tests"; };
          };
          # MKCL remains available for Prolog. The continuation environment/MOP
          # dependency stack does not advertise MKCL support.
          supported = component: impl:
            component == "prolog" || component == "sat" || impl != "mkcl";
          recipes = lib.listToAttrs (lib.concatMap (component:
            lib.mapAttrsToList (impl: options: let
              settings = components.${component};
              lisp = lispFor impl;
              library = lisp.buildASDFSystem {
                pname = "ooparts-${component}";
                version = "0.2.0";
                inherit src;
                systems = [ settings.library settings.tests ]
                  ++ lib.optionals (component == "prolog" || component == "all") [ "ooparts/prolog/text/cli" ]
                  ++ lib.optionals (component == "sat" || component == "all") [ "ooparts/sat/cli" ];
                lispLibs = lib.optionals (impl != "sbcl" && component != "prolog") (
                  [ lisp.pkgs.bordeaux-threads ]
                  ++ lib.optionals (component == "continuation" || component == "all")
                    [ lisp.pkgs.cl-environments lisp.pkgs.closer-mop lisp.pkgs.trivial-garbage ]
                );
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
                  ${options.eval} '(asdf:load-system "${settings.library}")' \
                  ${lib.optionalString (impl == "clisp") "-repl"} "$@"
              '';
              check = pkgs.runCommand "ooparts-test-${component}-${impl}" {} ''
                export XDG_CACHE_HOME="$TMPDIR/asdf-cache"
                ${test}/bin/ooparts-test
                ${lib.optionalString (component == "continuation" || component == "all") ''
                  export OOPARTS_CONT_FIXTURE_FASL="$TMPDIR/fixture.fasl"
                  cd ${src}
                  for script in compile-fixture load-fixture; do
                    ${runtime}/bin/${options.program} ${options.args} \
                      ${options.eval} '(load "tools/continuation/'"$script"'.lisp")' \
                      ${options.eval} '(uiop:quit 0)'
                  done
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
          checks = lib.mapAttrs' (name: value: lib.nameValuePair "test-${name}" value.check) (lib.filterAttrs (name: _: lib.hasPrefix "all-" name || (builtins.elem name [ "prolog-mkcl" "sat-mkcl" ])) recipes)
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
              packages = lib.mapAttrsToList (impl: _: (lispFor impl).withPackages (libraries:
                lib.optionals (impl != "sbcl") [ libraries.bordeaux-threads ]
                ++ lib.optionals (impl != "sbcl" && impl != "mkcl")
                  [ libraries.cl-environments libraries.closer-mop libraries.trivial-garbage ])) available
                ++ [ python pkgs.stdenv.cc ];
              shellHook = ''export CL_SOURCE_REGISTRY="$PWD//"'';
            };
          } // lib.mapAttrs (impl: _: pkgs.mkShell {
            packages = [ ((lispFor impl).withPackages (libraries:
              lib.optionals (impl != "sbcl") [ libraries.bordeaux-threads ]
              ++ lib.optionals (impl != "sbcl" && impl != "mkcl")
                [ libraries.cl-environments libraries.closer-mop libraries.trivial-garbage ])) python pkgs.stdenv.cc ];
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
