# ooparts/continuation

Danvy–Filinski の単一 prompt の `shift` / `reset` を、ソース変換とヒープ上の継続で実装する SBCL 用ライブラリです。継続は合成的で、多重呼出しでき、元の `reset` が終了した後にも呼び出せます。単発の脱出や計算の最初からの再実行による模倣ではありません。

Asai–Uehara (PEPM 2018) の「制御効果を解析し、純粋な部分を direct style に残す」という変換を、動的型付けの Common Lisp に保守的に適用しました。論文の answer-type を含む多相型推論器・制約解法の逐語的移植ではありません。型検査も行いません。関数値には native/CPS の共通の呼出し口を与え、不明な呼出しは CPS 側へ分類します。`reset` は内側の制御効果を閉じ込めるため、外側からは direct に扱えます。

`cl-cont` はコードウォーカ、関数のラッパー、Lisp-2 の関数呼出し処理の設計上の参考にしました。依存・fork・互換レイヤーではなく、同ライブラリのソースを配布物に含めていません。SBCL 本体の変更、スタックコピー、FFI は使いません。

## 1.2 の通常計算の高速化

直接実行する領域内の `*native-call*` 束縛を、各演算から領域の入口へまとめました。
返された純粋な関数も、呼び出し時には自身の入口で境界検査用の束縛を行います。
純粋な局所関数群は通常の `flet` / `labels` として生成し、混在する群は従来の経路を使います。
明示的な `type`（字句変数）、`optimize`、および native の関数束縛に対応できる
`ftype` / `inline` / `notinline` 宣言を生成コードへ保存します。
継続の表現・複製・トランポリン・動的環境のランタイムは変更していません。
`shift` を含むループ全体を直接実行する最適化は追加していません。

3073チェックとFASL・保存コアの再ロードを検証しました。利用側も再コンパイルしてください。
三者比較の数値と再実行手順は [benchmarks/README.md](benchmarks/README.md) を参照してください。

## 1.1 の高速化

制御効果のない reset は、driver と prompt を作らずに body を直接実行します。
純粋な引数列・progn の連続部分は、継続フレームと多値リストを作らずにまとめて評価します。
既知の CL プリミティブと funcall の呼出しでは不要な汎用ディスパッチを省略します。

block/return-from と tagbody/go には領域ごとの効果制約を持たせ、同じ関数・同じ reset 領域で完結する純粋な制御を native の構文として出力します。関数・reset をまたぐ脱出は、失効した対象の検査を含むヒープ上の経路に残します。未知の関数呼出しも保守的に CPS 側へ分類します。

継続の共通末尾は、フレーム列の長さを合わせて走査し、ハッシュ表を作りません。
単純な継続の複製では mapping を省きます。保留中の退出・再入を含む場合は、従来の rebasing を保持します。実行時の内部タグは名前文字列を作らない一意な cons で表します。

検証は 3041 件で、FASL/core の再ロードも確認しています。最適化はマクロ展開時にも適用するため、既存の利用側コードも再コンパイルしてください。
性能の全ケース・割当量・生データは [benchmarks/](benchmarks/) を参照してください。
すべての継続操作が cl-cont より高速になるという保証ではありません。

## 実行

必要なのは SBCL と付属の ASDF・SB-CLTL2・SB-MOP です。Quicklisp や外部ライブラリは不要です。

```sh
sbcl --load /path/to/sbcl-ooparts/continuation/load.lisp
sbcl --script /path/to/sbcl-ooparts/continuation/example.lisp
bash /path/to/sbcl-ooparts/continuation/tests/run.sh
```

ASDF を使う場合は、このディレクトリを source registry に登録し、`(asdf:load-system "ooparts/continuation")` または `(asdf:test-system "ooparts/continuation")` を実行してください。3073チェックに加え、FASLと保存コアの再ロードを検証しています。

```lisp
(scps:reset
  (+ 1 (scps:shift k
         (+ (funcall k 10) (funcall k 20)))))
;; => 32

(let ((k (scps:reset (+ 10 (scps:shift k k)))))
  (list (funcall k 2) (funcall k 7)))
;; => (12 17)

(multiple-value-list
  (scps:reset (scps:shift k (funcall k 1 2 3))))
;; => (1 2 3)

(scps:defun/cps choose (xs)
  (scps:shift k (mapcan (lambda (x) (funcall k x)) xs)))

(scps:reset
  (let ((x (choose '(1 2))) (y (choose '(10 20))))
    (list (+ x y))))
;; => (11 21 12 22)
```

## API

| 名前 | 用途 |
|---|---|
| `reset &body body` | body を変換して delimiter を設定する |
| `shift variable &body body` | 最も近い reset までの継続を variable へ束縛し、body をその reset 内で実行する |
| `with-cps &body body` | 変換範囲を指定する。暗黙の reset は追加しない |
| `lambda/cps lambda-list &body body` | 変換済みの関数値を作る。純粋な場合は通常の関数になる |
| `defun/cps name lambda-list &body body` | 変換済みの大域関数を定義する。`(setf name)` も可 |
| `transform form &optional environment mode` | 通常の Lisp へ変換したコードを返す |
| `analyze form &optional environment` | 制御効果と IR の direct/CPS ノード数を返す |
| `cps-function-p object` | CPS 呼出し口を持つ関数オブジェクトか調べる |
| `continuation-p object` | shift で取得した継続か調べる |
| `register-cps-adapter name replacement` | native 関数の現在の関数オブジェクトへアダプタを登録する |
| `dynamic-wind before thunk after` | 再入時の before と脱出時の after を持つ動的領域を設定する。変換範囲内で使用する |

継続は `functionp` を満たすオブジェクトです。`funcall` / `apply` でゼロ個以上の値を渡せます。単一値文脈では通常の CL と同様に第１値だけを使い、値がなければ `nil` になります。複数値文脈では値をすべて保持します。

`*transformation-mode*` はマクロ展開時のモードで、既定値は `:selective` です。`transform` の第３引数を `:full` にすると direct 部分も CPS 化できます。これは同じプログラムを比較するための検証用モードです。

## 変換範囲

制御効果を呼出し元まで伝える関数は `defun/cps` / `lambda/cps` で定義してください。範囲内の `lambda`、`flet`、`labels` も変換します。範囲外で既にコンパイルされた関数のコードを逆変換することはありません。

標準の特殊形式を処理し、`macrolet` / `symbol-macrolet` と外側のマクロ環境を考慮してマクロ展開します。`block` / `return-from`、`tagbody` / `go`、`catch` / `throw`、`progv`、`unwind-protect`、多値、通常の lambda list の required / optional / rest / key / allow-other-keys / aux を扱います。optional・key・aux の初期化式にも shift を書けます。

`block` と `tagbody` の対象は変換範囲内へ置いてください。捕捉した継続に含まれる対象は再開時にも有効です。範囲外に残って失効した対象への脱出には `inactive-control-target` を通知します。

以下の高階関数には CPS アダプタがあります。関数名の別名や `funcall` 経由の呼出しにも、関数オブジェクトの同一性で適用します。

```lisp
funcall apply
mapcar maplist mapc mapl mapcan mapcon map maphash
reduce some every notany notevery
```

その他の native 関数も普通に呼び出せます。ただし、その関数がコールバックを呼び、コールバックの shift が native フレームを越えようとすると `native-boundary` になります。callback 自身の reset 内で完結する制御操作は可能です。native callback から外側の変換済み block/catch への脱出も可能です。

アダプタは元の引数規約を持つ通常の変換済み関数として登録します。登録先の関数を再定義した場合は再登録してください。

```lisp
(defun native-caller (f x) (+ 100 (funcall f x)))
(scps:register-cps-adapter
 'native-caller
 (scps:lambda/cps (f x) (+ 100 (funcall f x))))
```

## 動的環境の規約

`special` 束縛と `progv` はヒープ上の束縛セルとして保持し、各 trampoline ステップを native な `progv` の内側で実行します。native 関数からの読み書きも同期します。捕捉範囲内の束縛セルは多重呼出し間で共有されます。reset の外側の束縛は捕捉せず、呼出し時の環境を使います。

shift による脱出で捕捉範囲内の動的領域を退出してから shift の body を実行します。`unwind-protect` の cleanup は退出ごとに実行します。再開で資源を開き直す処理が必要なら `dynamic-wind` の before を使ってください。既に閉じたファイル等を自動で復活させる処理はありません。before/after/cleanup 内の shift も、変換済みの制御遷移に対して扱います。

SBCL の標準的な `handler-bind` / `handler-case` / `restart-case` の展開を通した動作を検証しています。ハンドラや restart 関数自身から native の signal/invoke-restart のフレームを捕捉するには、そこで独立した reset が必要です。未処理の native エラーや native throw により既に始まったアンワインドを cleanup 内の shift が外側へ捕捉する場合も `native-boundary` で拒否します。その cleanup 内に新しい reset を置くことは可能です。

## 適用範囲と保証の限界

これは **変換対象言語上の完全な多重呼出し shift/reset** を実装するライブラリであり、任意の未変換 SBCL スタックを捕捉する VM 拡張ではありません。multi-prompt、shift0/control、CPS 階層、native CLOS メソッド本体や FFI フレームの透過的捕捉は対象外です。未知の SBCL 内部特殊形式は `unsupported-form` として拒否します。

変換範囲内の `declare` では `special` の意味を実装します。1.2では明示的な `type`（字句変数）と `optimize`、対応する native 関数名へ解決できる `ftype` / `inline` / `notinline` を出力へ転記します。型名を先頭に置く省略記法、特殊変数への型宣言、寿命宣言や独自宣言は転記しません。マクロ展開環境への宣言の伝達は従来どおり `special` に限定します。したがって、ローカルな型宣言等を `&environment` 経由で観測して振舞いを変える独自マクロや、SBCL の内部表現へ依存するマクロに対する完全互換性は主張しません。明示的な `the` は保持します。式文脈の `eval-when` は execute のみ実行し、`load-time-value` は native コンパイラへ渡します。トップレベル定義と大域的なコンパイル時副作用は通常の Lisp ファイルに置いてください。

継続の別スレッドでの逐次呼出しは検証しています。同じ継続から共有する可変セル・ユーザオブジェクトの並行更新を自動で排他制御することはありません。

実装全体の機械検証や Common Lisp 全体の意味保存定理を提供するものではありません。`tests/reference.lisp` はコンパイラや CPS ランタイムを使わない CBV 簡約器で、1328 個の core 式に対し両モードの一致を調べます。追加の具体例、深さ 2000 の捕捉、100000 ステップの末尾再帰、GC、別スレッド、別プロセスの FASL / core ロードも検証します。

数式を含む意味論と設計上の不変条件は、MathJax を使う `docs/semantics.html` に記載しています。

## 参照資料

- Kenichi Asai and Chihiro Uehara. *Selective CPS Transformation for Shift and Reset*. PEPM 2018, 40–52. DOI: https://doi.org/10.1145/3162069 . 著者版: https://www.is.ocha.ac.jp/~asai/papers/pepm18.pdf
- Chiaki Ishio and Kenichi Asai. *Verifying Selective CPS Transformation for Shift and Reset*. TFP 2019 / LNCS 12053 (2020), 38–57. DOI: https://doi.org/10.1007/978-3-030-47147-7_3 . 著者公開の Agda: https://www.is.ocha.ac.jp/~asai/papers/tfp19.agda
- cl-cont: https://cl-cont.common-lisp.dev/ ; source: https://gitlab.common-lisp.net/cl-cont/cl-cont . 参照したソース配布版: cl-cont-20110219-darcs。cl-cont は LLGPL、本実装の新規コードは MIT です。
