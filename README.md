# ACL2-ACmotormodel-check

Independent, machine-checked (ACL2) verification of the algebraic
derivations in:

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
(as opposed to calculus — see the honesty note below).

## What is proved

| File | Paper section / eqs. | Result |
|---|---|---|
| `00-complejos-vectores.lisp` | §III.A, eqs. (6)–(9) | Complex-product ↔ dot-product and cross-product correspondence |
| `01-euler-trig.lisp` | §III.A, eqs. (10), (12) | Euler's formula and its relation to the dot product |
| `02-raices-unidad.lisp` | eqs. used in (16)–(28), (33)–(35) | The two cube-root-of-unity sums that make the collapse lemma work |
| `03-deduccion-zeta.lisp` | §III.C, eqs. (16)–(28) | Algebraic core of the ζₖ(t) deduction (real/imag parts, magnitude²) |
| `04-lema-colapso.lisp` | §III.H, eqs. (33)–(35) | The three-phase "collapse lemma", in full generality, plus the mutual-term phase-shift identity |
| `05-correccion-signo-torque.lisp` | §III.K, eqs. (40)–(46) | **`torque-exponent-sign-is-plus`** — the algebraic chain confirming the `+ε(t)` sign correction |
| `06-inductancias-nota.lisp` | §III.F, eqs. (29)–(31) | *Not* mechanized — see below |
| `top.lisp` | — | Includes all of the above; certifying it certifies the whole chain from scratch |

## Honesty boundary — what this does *not* prove

ACL2 has no built-in theory of transcendental functions, real
analysis, or symbolic calculus. To stay honest about that:

- **Trigonometric facts** (Pythagorean identity, angle-difference
  formulas) are introduced in `01-euler-trig.lisp` via `encapsulate`
  as explicitly *assumed* constraints on abstract `cosine`/`sine`
  functions, not derived from first principles. Every theorem that
  depends on them should be read as "for any pair of functions
  satisfying these standard properties of sine and cosine...".
- **`sqrt(3)`** is irrational, so it cannot be an ACL2 `encapsulate`
  witness. It is instead a universally-quantified free variable `s3`
  with the hypothesis `s3*s3 = 3` in every theorem that uses it.
- **Section III.F (self/mutual inductance)** requires evaluating
  genuine definite integrals over `[0, 2π]`. ACL2 cannot do symbolic
  integration, so this section is deliberately **not** mechanized —
  see `06-inductancias-nota.lisp` for what *is* mechanizable there
  (the trig product-to-sum step) and what isn't.
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

- [ACL2](https://www.cs.utexas.edu/users/moore/acl2/) with the
  standard [community books](https://github.com/acl2/acl2) available
  (`arithmetic-5/top` is used).

## Certifying

```sh
cert.pl top
```

This certifies `top.lisp` and, transitively, all seven books in
dependency order. A clean run should produce no errors.

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
