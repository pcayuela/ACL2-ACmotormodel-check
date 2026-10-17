; 09-nonvacuity-acl2r.lisp
;
; ACL2(r)-only. Books 03-05 prove theorems under the hypothesis
; (equal (* s3 s3) 3) (with s3 REALP). In plain ACL2 no ACL2 number
; satisfies it, so there those theorems are schematic. In ACL2(r) the
; hypothesis IS satisfiable, by s3 = (acl2-sqrt 3). This book:
;   1. proves that (acl2-sqrt 3) is real and has square 3, and
;   2. instantiates the theorems of books 03-05 at s3 = (acl2-sqrt 3),
;      obtaining the same statements with NO hypothesis on s3, and
;   3. proves the five constraints of the ENCAPSULATE of
;      01-euler-identities.lisp for the library's genuinely defined
;      ACL2-COSINE / ACL2-SINE.

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

; The hypotheses on s3 are satisfiable in ACL2(r).
(defthm s3-hypothesis-satisfiable
  (and (realp (acl2-sqrt 3))
       (equal (* (acl2-sqrt 3) (acl2-sqrt 3)) 3))
  :rule-classes nil
  :hints (("Goal" :use (sqrt-3-squared-nv realp-sqrt-3))))

(defthm eq33-35-collapse-concrete
  (implies (and (realp ra) (realp ia))
           (equal (cadd (cscale (* 2/3 (dotp (cplx ra ia) (e0))) (e0))
                  (cadd (cscale (* 2/3 (dotp (cplx ra ia) (e1 (acl2-sqrt 3))))
                                (e1 (acl2-sqrt 3)))
                        (cscale (* 2/3 (dotp (cplx ra ia) (e2 (acl2-sqrt 3))))
                                (e2 (acl2-sqrt 3)))))
                  (cplx ra ia)))
  :hints (("Goal" :use ((:instance eq33-35-three-phase-collapse-lemma
                                   (s3 (acl2-sqrt 3)))
                        sqrt-3-squared-nv realp-sqrt-3))))

(defthm eq-ik-magnitude-squared-concrete
  (implies (and (realp i0) (realp i1) (realp i2)
                (equal i0 (- (+ i1 i2))))
           (equal (+ (* (re (ik i0 i1 i2 (acl2-sqrt 3)))
                        (re (ik i0 i1 i2 (acl2-sqrt 3))))
                     (* (imz (ik i0 i1 i2 (acl2-sqrt 3)))
                        (imz (ik i0 i1 i2 (acl2-sqrt 3)))))
                  (* 9/4 (+ (* i0 i0)
                            (* 1/3 (- i1 i2) (- i1 i2))))))
  :hints (("Goal" :use ((:instance eq-ik-magnitude-squared
                                   (s3 (acl2-sqrt 3)))
                        sqrt-3-squared-nv realp-sqrt-3))))

(defthm sign-matters-concrete
  (not (equal (crossp (cplx 1 1) (cmul (cplx 1 0) (e1 (acl2-sqrt 3))))
              (crossp (cplx 1 1) (cmul (cplx 1 0) (e2 (acl2-sqrt 3))))))
  :hints (("Goal" :use ((:instance sign-matters-nonvacuous
                                   (s3 (acl2-sqrt 3)))
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
