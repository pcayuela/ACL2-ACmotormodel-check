; 09-nonvacuity-acl2r.lisp
;
; ACL2(r)-only. Answers the observation that the theorems of books
; 03-05 carry the hypothesis (equal (* s3 s3) 3) together with
; (rationalp s3). In plain ACL2 no rational (indeed no ACL2 number)
; satisfies it, so those hypotheses are unsatisfiable there. In
; ACL2(r) the same is true for RATIONALP (sqrt(3) is irrational), but
; not for REALP. This book:
;   1. restates the theorems with REALP hypotheses (identical in
;      plain ACL2, where REALP and RATIONALP coincide), and
;   2. instantiates them at s3 = (acl2-sqrt 3), proving they hold
;      with NO hypothesis on s3, i.e. they are not vacuous.

(in-package "ACL2")
(include-book "nonstd/nsa/trig" :dir :system)
(include-book "arithmetic-5/top" :dir :system)
(include-book "03-zeta-deduction")
(include-book "04-collapse-lemma")
(include-book "05-torque-sign-correction")

(defthm sqrt-3-squared-nv
  (equal (* (acl2-sqrt 3) (acl2-sqrt 3)) 3)
  :hints (("Goal" :use (:instance sqrt-=-y (x 3) (y (acl2-sqrt 3))))))

(defthm realp-sqrt-3
  (realp (acl2-sqrt 3)))

; The hypothesis is satisfiable in ACL2(r).
(defthm s3-hypothesis-satisfiable
  (and (realp (acl2-sqrt 3))
       (equal (* (acl2-sqrt 3) (acl2-sqrt 3)) 3))
  :rule-classes nil
  :hints (("Goal" :use (sqrt-3-squared-nv realp-sqrt-3))))

; Note: sqrt(3) is irrational, so the RATIONALP hypotheses of books
; 03-05 also exclude it; REALP is the right hypothesis in ACL2(r)
; (and is equivalent to RATIONALP in plain ACL2).

(defthm eq33-35-collapse-realp
  (implies (and (realp ra) (realp ia) (realp s3)
                (equal (* s3 s3) 3))
           (equal (cadd (cscale (* 2/3 (dotp (cplx ra ia) (e0))) (e0))
                  (cadd (cscale (* 2/3 (dotp (cplx ra ia) (e1 s3))) (e1 s3))
                        (cscale (* 2/3 (dotp (cplx ra ia) (e2 s3))) (e2 s3))))
                  (cplx ra ia)))
  :hints (("Goal" :nonlinearp t)))

(defthm eq33-35-collapse-concrete
  (implies (and (realp ra) (realp ia))
           (equal (cadd (cscale (* 2/3 (dotp (cplx ra ia) (e0))) (e0))
                  (cadd (cscale (* 2/3 (dotp (cplx ra ia) (e1 (acl2-sqrt 3))))
                                (e1 (acl2-sqrt 3)))
                        (cscale (* 2/3 (dotp (cplx ra ia) (e2 (acl2-sqrt 3))))
                                (e2 (acl2-sqrt 3)))))
                  (cplx ra ia)))
  :hints (("Goal" :use ((:instance eq33-35-collapse-realp (s3 (acl2-sqrt 3)))
                        sqrt-3-squared-nv realp-sqrt-3))))

(defthm eq-ik-magnitude-squared-realp
  (implies (and (realp i0) (realp i1) (realp i2) (realp s3)
                (equal i0 (- (+ i1 i2)))
                (equal (* s3 s3) 3))
           (equal (+ (* (re (ik i0 i1 i2 s3)) (re (ik i0 i1 i2 s3)))
                     (* (imz (ik i0 i1 i2 s3)) (imz (ik i0 i1 i2 s3))))
                  (* 9/4 (+ (* i0 i0) (* 1/3 (- i1 i2) (- i1 i2))))))
  :hints (("Goal" :nonlinearp t)))

(defthm eq-ik-magnitude-squared-concrete
  (implies (and (realp i0) (realp i1) (realp i2)
                (equal i0 (- (+ i1 i2))))
           (equal (+ (* (re (ik i0 i1 i2 (acl2-sqrt 3)))
                        (re (ik i0 i1 i2 (acl2-sqrt 3))))
                     (* (imz (ik i0 i1 i2 (acl2-sqrt 3)))
                        (imz (ik i0 i1 i2 (acl2-sqrt 3)))))
                  (* 9/4 (+ (* i0 i0)
                            (* 1/3 (- i1 i2) (- i1 i2))))))
  :hints (("Goal" :use ((:instance eq-ik-magnitude-squared-realp
                                   (s3 (acl2-sqrt 3)))
                        sqrt-3-squared-nv realp-sqrt-3))))

(defthm sign-matters-realp
  (implies (and (realp s3) (equal (* s3 s3) 3))
           (not (equal (crossp (cplx 1 1) (cmul (cplx 1 0) (e1 s3)))
                       (crossp (cplx 1 1) (cmul (cplx 1 0) (e2 s3))))))
  :hints (("Goal" :nonlinearp t)))

(defthm sign-matters-concrete
  (not (equal (crossp (cplx 1 1) (cmul (cplx 1 0) (e1 (acl2-sqrt 3))))
              (crossp (cplx 1 1) (cmul (cplx 1 0) (e2 (acl2-sqrt 3))))))
  :hints (("Goal" :use ((:instance sign-matters-realp (s3 (acl2-sqrt 3)))
                        sqrt-3-squared-nv realp-sqrt-3))))

; --- The constraints of the ENCAPSULATE in 01-euler-identities.lisp
;     (Pythagorean identity, parity, angle-difference formulas) are
;     theorems about the library's ACL2-COSINE / ACL2-SINE, so the
;     abstract COSINE / SINE of books 01-05 can be instantiated with
;     them. Stated for ACL2 numbers (the domain of interest). ---
(defthm acl2-trig-pythagorean
  (implies (acl2-numberp x)
           (equal (+ (* (acl2-cosine x) (acl2-cosine x))
                     (* (acl2-sine x) (acl2-sine x)))
                  1))
  :hints (("Goal" :use ((:instance cosine-of-sums (x x) (y (- x)))
                        (:instance cos-uminus (x x))
                        (:instance sin-uminus (x x))))))

(defthm acl2-trig-cosine-even
  (implies (acl2-numberp x)
           (equal (acl2-cosine (- x)) (acl2-cosine x)))
  :hints (("Goal" :use cos-uminus)))

(defthm acl2-trig-sine-odd
  (implies (acl2-numberp x)
           (equal (acl2-sine (- x)) (- (acl2-sine x))))
  :hints (("Goal" :use sin-uminus)))

(defthm acl2-trig-cosine-difference
  (implies (and (acl2-numberp x) (acl2-numberp y))
           (equal (acl2-cosine (- x y))
                  (+ (* (acl2-cosine x) (acl2-cosine y))
                     (* (acl2-sine x) (acl2-sine y)))))
  :hints (("Goal" :use ((:instance cosine-of-sums (x x) (y (- y)))
                        (:instance cos-uminus (x y))
                        (:instance sin-uminus (x y))))))

(defthm acl2-trig-sine-difference
  (implies (and (acl2-numberp x) (acl2-numberp y))
           (equal (acl2-sine (- x y))
                  (- (* (acl2-sine x) (acl2-cosine y))
                     (* (acl2-cosine x) (acl2-sine y)))))
  :hints (("Goal" :use ((:instance sine-of-sums (x x) (y (- y)))
                        (:instance cos-uminus (x y))
                        (:instance sin-uminus (x y))))))
