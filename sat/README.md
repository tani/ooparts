# ooparts/sat

SATCH 0.5.6rc のデフォルト production 構成を関数単位で Common Lisp に移植し、Lisp 向け API を追加した SAT ソルバーです。実行時に C ソルバーや FFI を呼びません。

- ASDF システム・公開パッケージ: `ooparts/sat`、パッケージ別名: `sat`
- 対象: **SBCL / Linux x86-64 / LP64 / little endian**。検証: SBCL 2.2.9。
- 実行時依存: SBCL と付属 ASDF/UIOP のみ。Quicklisp・GCC・Python は不要。
- 元の C 形式の API: `ooparts/sat/low-level` パッケージ。

## 最短の利用例

```lisp
(require :asdf)
(asdf:load-asd #p"/path/to/ooparts/ooparts.asd")
(asdf:load-system "ooparts/sat")

(multiple-value-bind (status model stats)
    (sat:solve-cnf '((1 2) (-1 2) (-2 3)))
  (when (eq status :sat)
    (list (sat:model-value model 2)
          (sat:model-value model -3)
          (getf stats :conflicts))))
;; => (T NIL 0)

(sat:solve-cnf '((1) (-1)))
;; => :UNSAT, NIL, (:STATUS :UNSAT :VARIABLES 1 :CLAUSES 2 :CONFLICTS ...)
```

節は整数リテラルのリストまたはベクトル、その集まりが CNF です。変数番号は1から始まり、負号は否定を表します。`0` は公開 API のリテラルに使えません。節内の終端 `0` は不要です。空の CNF (`nil` / `#()`) は SAT、空節を含む CNF (`(nil)` / `#(#())`) は UNSAT です。

`solve` 系は常に3値を返します。

1. `:sat` / `:unsat` / `:unknown`
2. SAT のとき符号付きモデルのベクトル、それ以外は `nil`
3. `:status`、`:variables`、`:clauses`、`:conflicts` を持つ新しい plist

モデルの添字 `v-1` の値は、変数 `v` が真なら `v`、偽なら `-v` です。未使用の宣言済み変数は原版に従い真になります。モデルは独立したスナップショットで、solver の解放後も使えます。`model-value` は負のリテラルも受け取り、真偽値を返します。

## Solver を構築する

```lisp
(sat:with-solver (solver :variables 2)
  (let ((z (sat:new-variable solver))) ; => 3
    (sat:add-clauses solver #((1 2) #(-1 2)))
    (sat:add-clause solver (list -2 z))
    (multiple-value-bind (status model stats) (sat:solve solver)
      (declare (ignore model stats))
      (when (eq status :sat)
        (sat:value solver z)))))
;; => T
```

`with-solver` は正常終了、エラー、非局所脱出のいずれでも solver の割当てを解放し、body の多値を保ちます。手動管理には `make-solver` / `close-solver` を使います。`close-solver` は複数回呼べます。ネイティブ arena 自体はプロセス内で保持し、解放済み領域を再利用します。

| API | 意味 |
|---|---|
| `make-solver &key clauses variables verbosity proof-stream proof-format` | solver を作る。既定の変数数・verbosity は0、証明形式は `:ascii` |
| `with-solver (s &rest options) &body body` | `make-solver` のオプションで構築し、必ず解放 |
| `close-solver s` / `solver-closed-p s` | 解放／解放済みかを調べる |
| `add-clause s literals` / `add-clauses s clauses` | 節／節の集まりを追加。solver を返す |
| `new-variable s` | 現在の最大番号より大きい変数を宣言し、その番号を返す |
| `reserve-variables s count` | 変数1〜countを宣言・容量確保。既存の大きい上限は維持 |
| `solve s &key conflict-limit` | 求解し、状態・モデル・統計を返す |
| `model s` / `value s literal` | SAT モデルのコピー／リテラルの真偽値 |
| `model-value model literal` | 保存済みモデルでリテラルの真偽値を調べる |
| `statistics s` / `solver-status s` | 統計 plist／現在の状態 |
| `solve-cnf clauses &key variables conflict-limit` | 一度だけ構築・求解・解放 |
| `read-dimacs stream` | 厳密な DIMACS を読み、節リストと宣言変数数を返す |
| `solve-stream stream &key conflict-limit` | DIMACS を読み求解。ストリームは閉じない |
| `solve-file path &key conflict-limit` | DIMACS ファイルを求解 |

`variables` は宣言する最小の変数数で、節中の番号に応じて増えます。予約だけでは原版の使用変数数が増えないため、Lisp 向け API 側でも宣言数を保持します。`:clauses` は入力した節の数であり、学習節数ではありません。

## 状態と条件

節の追加・変数の宣言は最初の `solve` の前 (`:building`) に行います。`conflict-limit` は `nil` が無制限、整数の場合は0〜2147483647です。

`:unknown` は制限内で判定できなかった状態で、同じ solver に `solve` を再度呼ぶと探索を継続できます。`:sat` / `:unsat` の後に再び求解したり、最初の求解後に節を追加したりすることは原版で未対応です。assumptions API もありません。別の式には新しい solver を作ってください。

```lisp
(sat:with-solver (s :clauses clauses)
  (multiple-value-bind (status model stats) (sat:solve s :conflict-limit 100)
    (declare (ignore model stats))
    (if (eq status :unknown)
        (sat:solve s) ; 同じ式を制限なしで継続
        status)))
```

不正な入力は `type-error`、状態に合わない呼出しは `solver-state-error` になります。後者には `state-error-solver`、`state-error-operation`、`state-error-expected`、`state-error-actual` の reader があります。`add-clause` は節全体、`add-clauses` はバッチ全体を検証・コピーしてから solver を変更するため、不正な入力の途中までが追加されることはありません。

探索中の状態は `:solving` です。エンジンの変更がエラーや脱出で中断された場合は `:failed` とし、解放のみ可能にします。`solver-status` と `solver-closed-p` は解放後も問い合わせられます。公開操作は再帰 mutex で直列化し、複数の solver の状態も分離しています。

## 証明出力

```lisp
(with-open-file (proof "proof.drup" :direction :output :if-exists :supersede)
  (sat:with-solver (s :clauses '((1) (-1))
                      :proof-stream proof :proof-format :ascii)
    (sat:solve s)))
```

バイナリ証明には、`:element-type '(unsigned-byte 8)` の出力ストリームと `:proof-format :binary` を指定します。証明は入力節の追加前から有効にします。solver の解放時もストリームは閉じず、呼出し側が所有します。

CLI は `sbcl --script sat/cli.lisp input.cnf` で実行できます。SAT Competition の `s` / `v` 行と終了コード10 / 20 / 0（SAT / UNSAT / UNKNOWN）を使い、入力エラーの終了コードは1です。

## 原版との対応・最適化

原版は [arminbiere/satch](https://github.com/arminbiere/satch)、固定コミットは `b4d4081f8971931399b36c8fdd92bdf4aabac005` です。`-DNDEBUG` の production 構成で、機能を無効化する追加の `N...` オプションは指定していません。全284関数を変換し、elimination・subsumption・vivification・restart・reduction・モード切替・モデル再構成・証明出力を保持しています。

`src/translated.lisp` は統合参照ソース、実際の ASDF ビルドは `src/generated/prefix.lisp` と15個の分割ファイルを使います。`tools/function-map.json` が対応表です。`src/runtime.lisp` は Lisp 製のメモリ／OS アダプター、`src/api.lisp` は C 形式の検証付き API、`src/interface.lisp` が上記の Lisp 向け API です。

型・ftype・局所 optimize・選択的 inline で汎用演算と SAP の boxing を減らしています。コアは speed 2/3・safety 1、公開境界は safety 3。アドレス範囲検査は維持しています。SBCL 2.2.9 で全20実装モジュールの NOTE・警告（STYLE-WARNING を含む）が0件です。診断の muffle や inhibit-warnings による抑制は使いません。

統合前の最適化では11ケースの求解 CPU 時間の幾何平均が3.92倍改善し、同時測定した C 比は37.79倍から9.63倍になりました。これは低水準 API の測定であり、新しい Lisp API 全体のベンチマークではありません。[測定条件と生データ](benchmarks/README.md)を同梱しています。

## 検証・再生成

リポジトリ直下で実行します。

```sh
sbcl --script sat/tests/run.lisp
sbcl --non-interactive --load sat/tests/compile-clean.lisp
python3 sat/tests/differential.py --random 1000
python3 sat/tests/proofs.py
```

ASDF では `(asdf:test-system "ooparts/sat")` を使います。Lisp API の検証には96式の独立した全割当て列挙との照合を含みます。差分検査は原版の63 CNF・ランダム1000例など計1105例で、判定・モデル・探索カウンタを照合します。原版が節のポインターアドレスでタイブレークするため、同じ確保順の C 参照も用います。証明検査は公開 API を経由した ASCII／バイナリ6出力の完全一致と、ASCII 証明の独立した RUP 検査を行います。C 参照を使う検査には GCC と Python が必要です。`SBCL` 環境変数で実行ファイルを指定できます。

変換器を変更した場合は `cd sat && python3 tools/translate.py` で再生成します。Python・pycparser・GCC が必要で、491件の ABI 配置を実際の GCC と照合します。固定された SATCH 構成に対する変換器であり、汎用 C コンパイラーではありません。

## 制約・ライセンス

SBCL の SAP と private arena を使うため、標準 Common Lisp のみで移植可能な実装ではありません。arena 上限は全 solver で共有する heap 256 MiB、automatic storage 16 MiB です。超過時は Lisp エラーになります。live solver や arena を含む Lisp image の保存・復元は未対応です。

MIT。原版の著作権表示とライセンスを `LICENSE` および `upstream/LICENSE` に保持しています。原版 C のフロントエンド・debug checker・任意構成用ファイルは参照用で、Lisp の実行には使いません。
