# Selective CPS for shift/reset in Common Lisp

Implementation note · 2026-10-29

Single prompt, composable multi-shot continuations. A conservative adaptation of the control-effect idea of Asai–Uehara to dynamically typed Common Lisp.

**Scope of the claims.** This note gives an operational specification and design invariants, not a machine-checked proof of the complete Common Lisp implementation. It does not claim to implement the paper's polymorphic answer-type inference or capture untransformed native stacks.

## 1. Reference semantics

The core is call-by-value lambda calculus with Danvy–Filinski shift/reset. $v$ denotes a value and $E$ an evaluation context without reset. Common Lisp application uses `funcall`, with arguments evaluated from left to right.

$$
\begin{aligned}
e &::= v \mid e\;e \mid \langle e\rangle \mid \mathcal S k.e\\
E &::= [\,] \mid E\;e \mid v\;E
\end{aligned}
$$

$$
\begin{aligned}
(\lambda x.e)\;v &\longrightarrow e[v/x],\\
\langle v\rangle &\longrightarrow v,\\
\langle E[\mathcal S k.e]\rangle
 &\longrightarrow
 \left\langle e\left[(\lambda x.\langle E[x]\rangle)/k\right]\right\rangle.
\end{aligned}
$$

The final rule reinstalls reset inside the captured continuation. Invocation returns to its caller, and a shift during resumption sees a fresh delimiter. This is composable delimited control, with the stated reduction rules.

```lisp
(reset (+ 1 (shift k (+ (funcall k 10) (funcall k 20)))))
;; => 32

(let ((k (reset (+ 10 (shift k k)))))
  (list (funcall k 2) (funcall k 7)))
;; => (12 17)
```

## 2. Annotations and selective CPS

Control effects form the two-point order $p\leq i$. Here $p$ means direct execution is safe; it does not imply referential transparency. Mutating operations such as `rplaca` may remain direct when they do not capture control.

$$
\begin{aligned}
\epsilon_{\mathrm{sub}} &\leq \epsilon_{\mathrm{parent}},\\
\epsilon_{\mathrm{body}(f)} &\leq \epsilon_{\mathrm{latent}(f)},\\
\epsilon_{\mathrm{latent}(f)} &\leq \epsilon_{\mathrm{call}(f)},\\
\epsilon_{\mathcal S k.e} &= i,\qquad
\epsilon_{\langle e\rangle}=p.
\end{aligned}
$$

Unknown calls start at $i$. Known safe CL primitives start at $p$; local named calls depend on the callee's latent effect. Optional, keyword and auxiliary initializers contribute effects. Recursive LABELS constraints are solved by monotone fixed-point iteration. Constructing a function and calling its body have distinct effects.

Dynamic control is conservatively placed in CPS when needed. Captured/nonlocal BLOCK and TAGBODY targets and special bindings require runtime frames. RESET confines its body's control effect, creating a separate driver and prompt when the body needs CPS. A direct body can omit that machinery.

| Paper concept | Implementation |
|---|---|
| Selective translation using pure/impure annotations | Regions classified as direct are emitted as native Lisp. |
| Latent effects on function types | Local named functions carry latent effects; unknown dynamic function values use conservative CPS calls. |
| Polymorphic answer-type inference | Not implemented. Dynamic typing is retained, with a common native/CPS calling interface. |
| Consistent function representations | CPS functions use the host MOP's funcallable objects and share a calling interface with native functions. |
| Correctness theorem and Agda verification | Design references, without claiming that their theorems directly prove this Common Lisp extension. |

## 3. Heap continuations and fresh prompts

A runtime continuation is an immutable frame spine. Let $P$ be the nearest prompt and $R$ the surrounding continuation.

$$
K=F_1::\cdots::F_n::P::R,
\qquad \Gamma=[F_1,\ldots,F_n].
$$

SHIFT retains $\Gamma$, exits the dynamic regions up to $P$, and evaluates its body. Calling the captured continuation with a value sequence $\vec v$ copies its spine above a fresh prompt and the caller's continuation $C$.

$$
\operatorname{invoke}(\Gamma,\vec v,C)
=\operatorname{resume}\bigl(
\operatorname{copy}(\Gamma)\mathbin{+\!+}[P_{\rm fresh}]\mathbin{+\!+}C,
\vec v\bigr).
$$

The saved spine is never destroyed. Frame actions receive an explicit `next` rather than closing over the old tail. Lexical locations and special-binding cells remain shared. Repeated invocation therefore preserves store effects and does not reevaluate previously evaluated arguments.

## 4. Multiple values and evaluation order

Internal results are possibly empty sequences $\vec v=(v_1,\ldots,v_m)$. Single-value contexts, including arguments, conditions and SETQ right-hand sides, apply the following projection.

$$
\operatorname{primary}(\vec v)=
\begin{cases}v_1 & m>0,\\ \mathrm{nil} & m=0.\end{cases}
$$

`multiple-value-call` concatenates argument value sequences in order. `multiple-value-prog1` and normal `unwind-protect` completion retain the original sequence. Continuations accept both `(funcall k)` and `(funcall k 1 2 3)`.

Evaluated arguments are retained in lexical temporaries. A later capture does not reevaluate an earlier expression or reread a location that has since changed.

## 5. Dynamic regions and pending transfers

Frames represent SPECIAL/PROGV bindings, CATCH, BLOCK, TAGBODY, cleanup and dynamic-wind. Every task runs under the special environment represented by its continuation. Native symbol-value, SETQ and MAKUNBOUND changes are synchronized with binding cells.

Transfers find the common tail. Exited cleanup/after actions run from inside out; reentered before actions run from outside in. Shared mutable used-once flags do not suppress cleanup on later invocations.

A capture inside cleanup or before also captures a pending transfer. Targets are explicit `transfer-goal`/`entry-state` data, rebound along with prompts during copying. Expired targets outside the original reset are not revived.

```lisp
(reset
  (let ((first t))
    (+ 10 (unwind-protect (shift k (funcall k 1))
            (when first
              (setf first nil)
              (shift h (+ 100 (funcall h 0))))))))
;; => 111  (capture inside cleanup remains composable)
```

When direct RESET and CPS calls use different drivers, RETURN/GO/THROW first leave the current driver's virtual dynamic regions, then perform the native transfer. Cleanup can therefore capture normally before native unwinding has begun.

## 6. Native boundaries

An untransformed function's return continuation is not represented on the heap. Capture cannot cross that native frame to an outer prompt. The native CPS entry point uses an independent driver without an implicit reset and signals `native-boundary` for such requests. An explicit reset inside the callee can handle capture locally.

Bundled adapters for mapping, reduce and sequence quantifiers also represent callback returns on the heap. `register-cps-adapter` registers a transformed replacement with the original calling convention.

Native unwinding already started by an unhandled error is also a boundary. Capture from its cleanup to the original prompt is rejected. Capture within a fresh independent reset is permitted.

The transformed single-prompt core and transparent interoperability with arbitrary native Common Lisp have different guarantees. See the README for restrictions, including custom macros that inspect local type declarations.

## Direct-code generation

Direct argument sequences use ordinary left-to-right LET* evaluation and lexical temporaries. Standard CL single-value projection retains the first value or NIL. Combining direct regions preserves evaluated operands across later capture or mutation. Regions requiring PROGV execute inside a task with the correct bindings.

BLOCK/TAGBODY effects are constrained jointly with their bodies and RETURN-FROM/GO uses. Closed direct regions use native forms. References crossing function or reset boundaries conservatively use heap targets with expiration checks.

Common-tail search aligns immutable acyclic spine lengths. Copying can omit a mapping when no pending transfer occurs. Transition/entry frames retain rebasing. Direct regions bind their native-call boundary once at entry, and explicit lexical type/optimization declarations are preserved where supported.

## 7. Verification

The independent reference reducer implements beta-value and shift/reset rules directly with capture-avoiding substitution. It does not use compiler IR, runtime frames, effect solving or a CPS evaluator.

| Check | Coverage |
|---|---|
| Reference reduction | 1008 terms from seven schemas instantiated with 12 by 12 constants, plus 320 fixed-seed terms at depth 4/5. Both selective and full modes are compared. |
| Common Lisp extensions | Multiple values, evaluation order, mutation, lambda lists, higher-order calls, recursion, nonlocal control, special bindings, handlers/restarts, wind and capture inside cleanup. |
| Resources and execution | 100000 tail calls, depth-2000 multi-shot capture, invocation after full GC and from another thread, and separate-process FASL/core reloads. |

The current regression suite has 3073 checks. Run `tools/continuation/test.sh` from the repository root for the suite and fresh-process reload checks. The [validation guide](../testing.md) records the scope; passing tests is not a formal correctness proof.

## References

1. Asai, K. and Uehara, C. (2018). *Selective CPS Transformation for Shift and Reset*. PEPM, 40–52. [DOI](https://doi.org/10.1145/3162069) · [Author version](https://www.is.ocha.ac.jp/~asai/papers/pepm18.pdf)
2. Ishio, C. and Asai, K. (2020). *Verifying Selective CPS Transformation for Shift and Reset*. LNCS 12053, 38–57. [DOI](https://doi.org/10.1007/978-3-030-47147-7_3) · [Agda development](https://www.is.ocha.ac.jp/~asai/papers/tfp19.agda)
3. [cl-cont](https://cl-cont.common-lisp.dev/) / [source](https://gitlab.common-lisp.net/cl-cont/cl-cont). Design reference, not a distributed code dependency.

Equations use TeX notation in Markdown. OOPArts code is MIT licensed. Papers, cl-cont source and the Agda development are not copied into this distribution. See [license and provenance records](../../THIRD_PARTY.md).
