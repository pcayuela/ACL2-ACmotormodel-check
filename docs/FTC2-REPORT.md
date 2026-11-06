# Completing the inductance integral with FTC-2

Date: 2026-11-05. System: ACL2(r) 8.7, image `ghcr.io/pcayuela/acl2-acl2r-docker:8.7`.

Result: `inductance-integral-value` is proved and certified with `cert.pl` from clean
sources (certificate header `ACL2 Version 8.7(r)`; no `skip-proofs`, `defaxiom` or `ttag`).

| New book | Root | What it proves |
|---|---|---|
| `10-inductance-ftc2.lisp` | `top-acl2r-ftc2` | `inductance-integral-value`: the integral over [0, 2π] of cos(δ−mγ)·cos(δ−nγ) is π·cos((n−m)γ), with γ = 2π/3 |

## Starting point

`08-inductance-integral.lisp` confirmed the trigonometric algebra of the antiderivative
`F(x) = ½cos((n−m)γ)·x + ¼sin(2x−(m+n)γ)`, but could not state its derivative with
`acl2-sine`/`acl2-cosine`: differentiating through raw `acl2-exp` fell into rewrite loops
of `arithmetic-5`. `ftc-2` was not instantiated.

## What unblocked it

1. `support/sin-cos-minimal.lisp` of the Reid-Gamboa differentiator registers `acl2-sine` and
   `acl2-cosine` (`def-elem-derivative`). With it, `defderivative` differentiates `sin(2x−c)`
   by the chain rule, in terms of `acl2-cosine`.
2. The rewrite loops were removed by disabling a fixed set of rules (listed in the book):
   `cosine-of-sums`, `sine-of-sums`, `cos-uminus`, `sin-uminus`,
   `functional-commutativity-of-minus-*-left/right`, `|(- (* c x))|`, and the
   `integerp-minus-x` / `real/rationalp-minus-x` / `rationalp-minus-x` families with their
   `|(… (- x))|` variants. Also `(:executable-counterpart winding-gamma)`: ACL2 tried to
   evaluate the closed term `(winding-gamma)` and wrapped it in `hide`.
3. The `ftc-2` instantiation follows `nonstd/circles/circumference-of-a-circle`: `map-`,
   `riemann-`, `strict-int-` (via `defun-std`) and `int-` definitions, the limited Riemann
   sum lemma by functional instantiation of `limited-riemann-rcfn-small-partition`, and the
   derivative and continuity subgoals with explicit `:use`.

## Final theorem

```lisp
(defthm inductance-integral-value
  (equal (int-ind-g 0 (* 2 (acl2-pi)))
         (* (acl2-pi) (acl2-cosine (* (+ (n0) (- (m0))) (winding-gamma))))))
```

`int-ind-g` is the nonstandard Riemann integral of the library. `m0` and `n0` are standard
real indices introduced with `encapsulate`.

## Reproduce

Run as root inside the container, because `cert.pl` writes the certificates of community
books under `/opt`:

```bash
docker run --rm -v "$PWD":/work -w /work ghcr.io/pcayuela/acl2-acl2r-docker:8.7 \
  /opt/acl2r/books/build/cert.pl --acl2 /opt/acl2r/saved_acl2r -j 4 \
  top-acl2r top-acl2r-nonvacuity top-acl2r-ftc2
```

With an image built before 2026-11-06, `nonstd/integrals/ftc-2` and `sin-cos-minimal` are
certified on first use (about 2 minutes). Images built from `acl2-acl2r-docker` commit
`094236f` or later have them pre-certified.

## Limits

- The theorem holds for any standard real `m0`, `n0` (encapsulated constants). No numeric
  instances were derived.
- The rules listed above are disabled globally in the new books, which affects anyone who
  includes them. This is proof engineering, not mathematics.
- The `acl2-mcp` tool was not used; the work was done with the same ACL2(r) from the command
  line.
