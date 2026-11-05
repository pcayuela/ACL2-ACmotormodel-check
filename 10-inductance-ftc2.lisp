; 10-inductance-ftc2.lisp
;
; ACL2(r)-ONLY BOOK.
;
; Completes what 08-inductance-integral.lisp left open: the value of the
; winding-function (self/mutual) inductance integral
;
;     integral_0^{2 pi}  cos(d - m*gamma) cos(d - n*gamma)  dd  =  pi cos((n-m) gamma)
;
; (gamma = 2 pi / 3) by instantiating the community FTC-2 book
; (nonstd/integrals/ftc-2) with the antiderivative of 08.
;
; The step that 08 could not close -- the derivative of the antiderivative
; stated with acl2-sine/acl2-cosine instead of raw acl2-exp -- is obtained
; here by registering acl2-sine and acl2-cosine with the Reid-Gamboa
; differentiator (support/sin-cos-minimal), so DEFDERIVATIVE differentiates
; sin(2x-c) directly through the chain rule.

; cert_param: (uses-acl2r)

(in-package "ACL2")
(include-book "08-inductance-integral")
(include-book "nonstd/workshops/2011/reid-gamboa-differentiator/support/sin-cos-minimal" :dir :system)
(include-book "nonstd/integrals/ftc-2" :dir :system)

; ---------------------------------------------------------------------
; Symbolic (standard, real) winding indices m0, n0.  Any particular
; indices are recovered by functional instantiation.
(encapsulate (((m0) => *) ((n0) => *))
  (local (defun m0 () 0))
  (local (defun n0 () 0))
  (defthm realp-m0 (realp (m0)))
  (defthm realp-n0 (realp (n0)))
  (defthm standardp-m0 (standardp (m0)))
  (defthm standardp-n0 (standardp (n0))))

(defthm-std standardp-acl2-pi (standardp (acl2-pi)))

(defthm standardp-winding-gamma (standardp (winding-gamma)))
(defthm realp-winding-gamma (realp (winding-gamma)))

; ---------------------------------------------------------------------
; The pieces ftc-2 wants: rcdfn = F, rcdfn-prime = g, domain = all of R.
(defun ind-g0 (x) (inductance-integrand x (m0) (n0)))
(defun ind-f0 (x) (inductance-antideriv x (m0) (n0)))
(defun ind-domain () (interval nil nil))

; The same rewrite loops that 08 documents (cosine-of-sums vs its converse,
; functional-commutativity-of-minus-* vs (- (* c x))) appear whenever
; acl2-sine/acl2-cosine meet arithmetic-5, so they stay disabled here.
(in-theory (disable cosine-of-sums sine-of-sums cos-uminus sin-uminus
                    functional-commutativity-of-minus-*-left
                    functional-commutativity-of-minus-*-right
                    |(- (* c x))| winding-gamma
                    (:executable-counterpart winding-gamma)
                    integerp-minus-x real/rationalp-minus-x rationalp-minus-x
                    |(real/rationalp (- x))| |(integerp (- x))| |(rationalp (- x))|))

(defthm realp-ind-f0
  (implies (realp x) (realp (ind-f0 x)))
  :hints (("Goal" :in-theory (enable inductance-antideriv)
                  :use ((:instance realp-sine   (x (+ (* 2 x) (- (* (+ (m0) (n0)) (winding-gamma))))))
                        (:instance realp-cosine (x (* (+ (n0) (- (m0))) (winding-gamma))))))))

(defthm realp-ind-g0
  (implies (realp x) (realp (ind-g0 x)))
  :hints (("Goal" :in-theory (enable inductance-integrand)
                  :use ((:instance realp-cosine (x (+ x (- (* (m0) (winding-gamma))))))
                        (:instance realp-cosine (x (+ x (- (* (n0) (winding-gamma))))))))))

; --- derivative of the antiderivative, via the chain rule through acl2-sine
(defderivative antideriv-lemma
  (+ (* 1/2 a x) (* 1/4 (acl2-sine (- (* 2 x) c)))))

; Standardness of the constants that feed the derivative lemma.
(defthm standardp-cos-shift
  (standardp (acl2-cosine (* (+ (n0) (- (m0))) (winding-gamma)))))
(defthm standardp-sin-shift
  (standardp (* (+ (m0) (n0)) (winding-gamma))))

(defthm ind-f0-derivative
  (implies (and (standardp x) (realp x) (realp y)
                (i-close x y) (not (equal x y)))
           (i-close (/ (- (ind-f0 x) (ind-f0 y)) (- x y))
                    (ind-g0 x)))
  :hints (("Goal"
           :in-theory (enable inductance-antideriv inductance-integrand-as-sum)
           :use ((:instance antideriv-lemma
                            (a (acl2-cosine (* (+ (n0) (- (m0))) (winding-gamma))))
                            (c (* (+ (m0) (n0)) (winding-gamma))))))))

; --- two small facts about infinitesimal closeness
(defthm i-close-times-2
  (implies (i-close x y) (i-close (* 2 x) (* 2 y)))
  :hints (("Goal" :in-theory (enable i-close)
                  :use ((:instance i-small-plus (x (- x y)) (y (- x y)))))))

(defthm i-close-times-half
  (implies (i-close x y) (i-close (* 1/2 x) (* 1/2 y)))
  :hints (("Goal" :in-theory (enable i-close)
                  :use ((:instance limited*small->small (x 1/2) (y (- x y)))))))

(local
 (defthm i-close-shift-diff
   (equal (+ (+ a x) (- (+ a y))) (+ x (- y))))
)

(defthm i-close-shift
  (implies (and (i-close x y) (acl2-numberp a))
           (i-close (+ a x) (+ a y)))
  :hints (("Goal" :in-theory (union-theories '(i-close i-close-shift-diff)
                                             (theory 'minimal-theory)))))

; Continuity of the integrand at standard points: g(x) = 1/2 (A + cos(2x - c)).
(defthm ind-g0-continuous
  (implies (and (standardp x) (realp x) (realp y) (i-close x y))
           (i-close (ind-g0 x) (ind-g0 y)))
  :hints (("Goal"
           :in-theory (enable inductance-integrand-as-sum)
           :use ((:instance cosine-continuous
                            (x (+ (* 2 x) (- (* (+ (m0) (n0)) (winding-gamma)))))
                            (y (+ (* 2 y) (- (* (+ (m0) (n0)) (winding-gamma))))))
                 (:instance i-close-times-2)
                 (:instance i-close-times-half
                            (x (+ (acl2-cosine (* (+ (n0) (- (m0))) (winding-gamma)))
                                  (acl2-cosine (+ (* 2 x) (- (* (+ (m0) (n0)) (winding-gamma)))))))
                            (y (+ (acl2-cosine (* (+ (n0) (- (m0))) (winding-gamma)))
                                  (acl2-cosine (+ (* 2 y) (- (* (+ (m0) (n0)) (winding-gamma))))))))
                 (:instance i-close-shift
                            (a (acl2-cosine (* (+ (n0) (- (m0))) (winding-gamma))))
                            (x (acl2-cosine (+ (* 2 x) (- (* (+ (m0) (n0)) (winding-gamma))))))
                            (y (acl2-cosine (+ (* 2 y) (- (* (+ (m0) (n0)) (winding-gamma))))))))
           :do-not-induct t)))

; ---------------------------------------------------------------------
; Total versions (0 off the reals), as ftc-2's encapsulated rcdfn /
; rcdfn-prime must be real-valued everywhere.
(defun ind-g (x) (if (realp x) (ind-g0 x) 0))
(defun ind-f (x) (if (realp x) (ind-f0 x) 0))

(defthm realp-ind-f (realp (ind-f x)))
(defthm realp-ind-g (realp (ind-g x)))

(defthm intervalp-ind-domain
  (interval-p (ind-domain))
  :rule-classes (:type-prescription :rewrite))

(defthm inside-ind-domain-is-realp
  (equal (inside-interval-p x (ind-domain)) (realp x))
  :hints (("Goal" :in-theory (enable ind-domain interval-definition-theory))))

(defthm ind-domain-real
  (implies (inside-interval-p x (ind-domain)) (realp x))
  :rule-classes (:forward-chaining))

(defthm ind-domain-non-trivial
  (or (null (interval-left-endpoint (ind-domain)))
      (null (interval-right-endpoint (ind-domain)))
      (< (interval-left-endpoint (ind-domain))
         (interval-right-endpoint (ind-domain))))
  :hints (("Goal" :in-theory (enable ind-domain interval-definition-theory)))
  :rule-classes nil)

(defthm ind-f-is-antiderivative
  (implies (and (standardp x)
                (inside-interval-p x (ind-domain))
                (inside-interval-p x1 (ind-domain))
                (i-close x x1) (not (= x x1)))
           (i-close (/ (- (ind-f x) (ind-f x1)) (- x x1))
                    (ind-g x)))
  :hints (("Goal" :in-theory (disable ind-f0 ind-g0 ind-f0-derivative)
                  :use ((:instance ind-f0-derivative (y x1))))))

(defthm ind-g-continuous
  (implies (and (standardp x)
                (inside-interval-p x (ind-domain))
                (i-close x x1)
                (inside-interval-p x1 (ind-domain)))
           (i-close (ind-g x) (ind-g x1)))
  :hints (("Goal" :in-theory (disable ind-g0 ind-g0-continuous)
                  :use ((:instance ind-g0-continuous (y x1))))))

; ---------------------------------------------------------------------
; The Riemann integral of g, defined exactly as ftc-2 defines the integral
; of its encapsulated rcdfn-prime.
(defun map-ind-g (p)
  (if (consp p)
      (cons (ind-g (car p)) (map-ind-g (cdr p)))
    nil))

(defun riemann-ind-g (p)
  (dotprod (deltas p) (map-ind-g (cdr p))))

(encapsulate
 nil

 (local
  (defthm limited-riemann-ind-g-small-partition
    (implies (and (realp a) (standardp a)
                  (realp b) (standardp b)
                  (inside-interval-p a (ind-domain))
                  (inside-interval-p b (ind-domain))
                  (< a b))
             (i-limited (riemann-ind-g (make-small-partition a b))))
    :hints (("Goal"
             :by (:functional-instance limited-riemann-rcfn-small-partition
                                       (rcfn-domain ind-domain)
                                       (rcfn ind-g)
                                       (map-rcfn map-ind-g)
                                       (riemann-rcfn riemann-ind-g)))
            ("Subgoal 2"
             :use ((:instance ind-domain-non-trivial))))))

 (local (in-theory (disable riemann-ind-g)))

 (defun-std strict-int-ind-g (a b)
   (if (and (realp a) (realp b)
            (inside-interval-p a (ind-domain))
            (inside-interval-p b (ind-domain))
            (< a b))
       (standard-part (riemann-ind-g (make-small-partition a b)))
     0)))

(defun int-ind-g (a b)
  (if (<= a b)
      (strict-int-ind-g a b)
    (- (strict-int-ind-g b a))))

; --- FTC-2 for g
(defthmd ind-ftc-2
  (implies (and (inside-interval-p a (ind-domain))
                (inside-interval-p b (ind-domain)))
           (equal (int-ind-g a b)
                  (- (ind-f b) (ind-f a))))
  :hints (("Goal"
           :use ((:functional-instance ftc-2
                                       (rcdfn-domain ind-domain)
                                       (int-rcdfn-prime int-ind-g)
                                       (riemann-rcdfn-prime riemann-ind-g)
                                       (map-rcdfn-prime map-ind-g)
                                       (rcdfn-prime ind-g)
                                       (rcdfn ind-f)
                                       (strict-int-rcdfn-prime strict-int-ind-g)))
           :in-theory (disable ind-f ind-g ind-f0 ind-g0))
          ("Subgoal 7"
           :use ((:instance ind-g-continuous (x x) (x1 x1)))
           :in-theory (disable ind-f ind-g ind-f0 ind-g0))
          ("Subgoal 6"
           :use ((:instance ind-f-is-antiderivative (x x) (x1 x1)))
           :in-theory (disable ind-f ind-g ind-f0 ind-g0))))

; ---------------------------------------------------------------------
; Evaluating F(2 pi) - F(0).
(defthm sin-plus-2pi
  (implies (acl2-numberp u)
           (equal (acl2-sine (+ u (* 2 (acl2-pi)))) (acl2-sine u)))
  :hints (("Goal" :use ((:instance sine-of-sums (x u) (y (* 2 (acl2-pi)))))
                  :in-theory (disable sine-of-sums))))

(defthm sin-4pi-minus
  (implies (acl2-numberp u)
           (equal (acl2-sine (+ u (* 4 (acl2-pi)))) (acl2-sine u)))
  :hints (("Goal" :use ((:instance sin-plus-2pi (u u))
                        (:instance sin-plus-2pi (u (+ u (* 2 (acl2-pi))))))
                  :in-theory (disable sin-plus-2pi))))

(defthm ind-f-2pi-minus-ind-f-0
  (equal (- (ind-f (* 2 (acl2-pi))) (ind-f 0))
         (* (acl2-pi) (acl2-cosine (* (+ (n0) (- (m0))) (winding-gamma)))))
  :hints (("Goal"
           :in-theory (enable ind-f ind-f0 inductance-antideriv)
           :use ((:instance sin-4pi-minus
                            (u (+ (- (* (+ (m0) (n0)) (winding-gamma)))))))))
  )

; ---------------------------------------------------------------------
; THE RESULT.  For standard real winding indices m0, n0 and gamma = 2 pi / 3:
;
;    integral_0^{2 pi} cos(d - m0*gamma) cos(d - n0*gamma) dd
;         = pi * cos((n0 - m0) * gamma)
;
; where the integral is the nonstandard Riemann integral of ftc-2's
; library (int-ind-g, built from standard-part of Riemann sums over
; infinitesimal partitions).
(defthm realp-2pi (realp (* 2 (acl2-pi)))
  :hints (("Goal" :in-theory (disable acl2-pi))))

(defthm int-ind-g-from-0
  (implies (realp b)
           (equal (int-ind-g 0 b) (- (ind-f b) (ind-f 0))))
  :hints (("Goal"
           :use ((:instance ind-ftc-2 (a 0)))
           :in-theory (union-theories '(inside-ind-domain-is-realp)
                                      (theory 'minimal-theory)))))

(defthm inductance-integral-value
  (equal (int-ind-g 0 (* 2 (acl2-pi)))
         (* (acl2-pi) (acl2-cosine (* (+ (n0) (- (m0))) (winding-gamma)))))
  :hints (("Goal"
           :use ((:instance int-ind-g-from-0 (b (* 2 (acl2-pi))))
                 (:instance realp-2pi)
                 (:instance ind-f-2pi-minus-ind-f-0))
           :in-theory (theory 'minimal-theory))))
