# ACL2-ACmotormodel-check

Independent, machine-checked (ACL2 / ACL2(r)) verification of the
algebraic derivations in:

> P. O. Cayuela, "Modelo vectorial de la máquina de corriente alterna
> trifásica simétrica" (extended version), Universidad Tecnológica
> Nacional, Facultad Regional Córdoba, 2026.

That paper rewrites the classical complex-domain model of the
symmetric three-phase AC machine (W. Leonhard, *Control of Electrical
Drives*, Ch. 10) in vectorial form, using the correspondence between
complex-number products and the dot/cross products of the underlying
planar vectors. It completes three derivations the original text left
implicit — the self/mutual inductance integral, the three-phase
"collapse" of the flux-linkage space vector, and the full torque
equation derivation — and, along the way, argues that a previously
published sign in the torque equation's exponent (`e^{-jε(t)}`) should
actually be `e^{+jε(t)}`.

This repository re-derives, independently and mechanically in ACL2,
every algebraic step of those derivations that is actually algebra
(as opposed to calculus — see the honesty note below), plus a
follow-up, partial mechanization attempt at the one step that *is*
calculus.

## What is proved

| File | Paper section / eqs. | Result |
|---|---|---|
| `00-complex-vectors.lisp` | §III.A, eqs. (6)–(9) | Complex-product ↔ dot-product and cross-product correspondence |
| `01-euler-identities.lisp` | §III.A, eqs. (10), (12) | Euler's formula and its relation to the dot product |
| `02-roots-of-unity.lisp` | eqs. used in (16)–(28), (33)–(35) | The two cube-root-of-unity sums that make the collapse lemma work |
| `03-zeta-deduction.lisp` | §III.C, eqs. (16)–(28) | Algebraic core of the ζₖ(t) deduction (real/imag parts, magnitude²) |
| `04-collapse-lemma.lisp` | §III.H, eqs. (33)–(35) | The three-phase "collapse lemma" for the concrete roots `e0`,`e1(s3)`,`e2(s3)`, plus the mutual-term phase-shift identity |
| `05-torque-sign-correction.lisp` | §III.K, eqs. (40)–(46) | **`torque-exponent-sign-is-plus`** — the algebraic chain confirming the `+ε(t)` sign correction |
| `06-generic-omega-collapse.lisp` | §III.H (independent, more general route) | The collapse lemma for an **arbitrary** ω satisfying ω²+ω+1=0 — conditional in plain ACL2 (no rational witness exists) |
| `06-generic-omega-collapse-acl2r.lisp` | §III.H (independent, more general route) | Discharges that condition: constructs the real ω=e^{j2π/3} in ACL2(r) and makes the generic lemma unconditional |
| `07-inductance-note.lisp` | §III.F, eqs. (29)–(31) | *Not* mechanized here — see below |
| `08-inductance-integral.lisp` | §III.F, eqs. (29)–(31) | Follow-up ACL2(r) attempt: confirms the antiderivative's trigonometric algebra and machine-derives the raw derivative of its oscillating term; does **not** complete the integral — see the file header for exactly where it stops |
| `top.lisp` | — | Includes `00`–`07`; certifying it certifies that chain from scratch |
| `top-acl2r.lisp` | — | Includes the two ACL2(r)-only books (`06-...-acl2r`, `08-...`); certifying it certifies that chain from scratch |

**On `06-generic-omega-collapse{,-acl2r}.lisp`:** these are *not* a
dependency of `04-collapse-lemma.lisp`'s result — that book already
establishes the collapse lemma unconditionally (modulo the honest
`s3*s3=3` hypothesis) by direct computation on the three concrete
roots. The generic-ω route is independent, additional material: a
strictly more general statement (holds for *any* valid primitive cube
root of unity, not just this specific parametrization), proved by a
cleaner algebraic argument (no zero divisors + the factorization
x³−1=(x−1)(x²+x+1)) instead of brute coordinate computation.

## Honesty boundary — what this does *not* prove

ACL2 has no built-in theory of transcendental functions, real
analysis, or symbolic calculus (ACL2(r) adds nonstandard analysis, but
only where explicitly invoked below). To stay honest about that:

- **Trigonometric facts** (Pythagorean identity, angle-difference
  formulas) are introduced in `01-euler-identities.lisp` via
  `encapsulate` as explicitly *assumed* constraints on abstract
  `cosine`/`sine` functions, not derived from first principles. Every
  theorem that depends on them should be read as "for any pair of
  functions satisfying these standard properties of sine and
  cosine...".
- **`sqrt(3)`** is irrational, so it cannot be a plain-ACL2
  `encapsulate` witness. In `00`–`07` it is left as a
  universally-quantified free variable `s3` with the hypothesis
  `s3*s3 = 3`. In the ACL2(r)-only books it is instead the genuine
  `(acl2-sqrt 3)`.
- **The generic collapse lemma** (`06-generic-omega-collapse.lisp`) is
  conditional in plain ACL2 for the same reason: no rational pair
  satisfies ω²+ω+1=0. `06-generic-omega-collapse-acl2r.lisp` closes
  that specific gap by constructing the real ω=e^{j2π/3}, but — see
  above — this was never a gap in the paper's *main* collapse-lemma
  result, only in this independent, more general side result.
- **Section III.F (self/mutual inductance)** requires evaluating a
  genuine definite integral over `[0, 2π]`. Plain ACL2 cannot even
  state it. `07-inductance-note.lisp` explains why it is left
  unmechanized there; `08-inductance-integral.lisp` is a follow-up
  ACL2(r) attempt that gets partway (the antiderivative's algebra is
  confirmed, and the raw nonstandard derivative of its oscillating
  term is machine-derived via an automatic differentiator) but does
  **not** complete the integral — its header comment documents exactly
  which ACL2/`arithmetic-5` obstacles stopped it, rather than
  simulating a finished proof.
- Equation (40) — the torque formula as stated in Leonhard's book — is
  taken as a *given* starting point (as the paper itself does); this
  repository does not have independent access to Leonhard's text and
  only checks that everything *derived from* (40)–(41) in the paper is
  algebraically correct.
- `atan2` (used for ζₖ(t) itself) is not mechanized, as it's
  transcendental/multivalued; only the algebraic sin/cos components
  that feed it are checked.

None of this weakens the results that *are* proved — it just marks
the line between "checked by ACL2" and "taken as a standard
mathematical fact ACL2 cannot itself derive."

## Requirements

- [ACL2(r)](https://www.cs.utexas.edu/users/moore/acl2/) — the
  nonstandard-analysis extension of
  [ACL2](https://www.cs.utexas.edu/users/moore/acl2/) — with the
  standard [community books](https://github.com/acl2/acl2) available
  (`arithmetic-5/top`, `nonstd/nsa/trig`, and
  `nonstd/workshops/2011/reid-gamboa-differentiator` are used).
- Both `top.lisp` and `top-acl2r.lisp` are certified under the ACL2(r)
  executable in this repository's own CI/development environment.
  `top.lisp`'s own proofs do not use any nonstandard-analysis feature
  — they would certify identically under plain ACL2 — but ACL2(r) is a
  strict superset of ACL2, so certifying the whole repository under
  one executable avoids maintaining two separately-provisioned
  community-books installations. If you have a plain-ACL2 setup
  without ACL2(r), `top.lisp` alone should certify there unmodified.

## Certifying

```sh
export ACL2=/path/to/saved_acl2r
cert.pl --acl2 "$ACL2" top        # 00-07, the main chain
cert.pl --acl2 "$ACL2" top-acl2r  # the two ACL2(r)-only extensions
```

Each certifies its own book and, transitively, everything it depends
on, from a clean state. A clean run should produce no errors.

## Citation

If you use this in academic work, please cite the original paper
above. Suggested citation for this repository:

```
P. O. Cayuela, "ACL2-ACmotormodel-check: mechanized verification of
the complex-to-vector AC machine model derivations", 2026.
https://github.com/pcayuela/ACL2-ACmotormodel-check
```

## License

MIT — see [LICENSE](LICENSE).

## Contact

Pablo Oscar Cayuela — Centro Universitario de Desarrollo en
Automación y Robótica, Depto. Ing. Electrónica, Universidad
Tecnológica Nacional, Facultad Regional Córdoba, Argentina.
pcayuela@frc.utn.edu.ar
