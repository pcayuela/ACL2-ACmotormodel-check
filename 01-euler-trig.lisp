; 01-euler-trig.lisp
;
; Verifica las ecuaciones (10)-(12) del articulo: identidades de Euler
; y su relacion con el producto escalar.
;
; LIMITE DE HONESTIDAD: ACL2 (sin la extension ACL2(r) de analisis no
; estandar) no tiene una teoria de funciones trascendentes ni de
; analisis real: no puede "derivar" seno y coseno desde primeros
; principios. Por eso cosine/sine se introducen aqui via ENCAPSULATE
; como funciones CONSTREÑIDAS a cumplir un conjunto de hechos
; trigonometricos estandar (pitagorica, paridad, formulas de angulo
; diferencia) que se IMPORTAN como axiomas, no se prueban. El testigo
; local usado para admitir el encapsulate es la funcion constante
; trivial (cosine=1, sine=0), que satisface por casualidad todas las
; restricciones; esto solo demuestra que las restricciones son
; consistentes, no que cosine/sine sean las funciones trigonometricas
; reales. Todo lo que se prueba DESPUES de este punto es entonces:
; "para cualquier par de funciones que satisfaga estas propiedades
; estandar del seno y coseno, se cumple que...".

(in-package "ACL2")
(include-book "00-complejos-vectores")

(encapsulate
 (((cosine *) => *) ((sine *) => *))
 (local (defun cosine (x) (declare (ignore x)) 1))
 (local (defun sine (x) (declare (ignore x)) 0))
 (defthm pitagorica-cos-sen
   (equal (+ (* (cosine x) (cosine x)) (* (sine x) (sine x))) 1))
 (defthm cosine-par
   (equal (cosine (- x)) (cosine x)))
 (defthm sine-impar
   (equal (sine (- x)) (- (sine x))))
 (defthm cosine-diferencia
   (equal (cosine (- x y))
          (+ (* (cosine x) (cosine y)) (* (sine x) (sine y)))))
 (defthm sine-diferencia
   (equal (sine (- x y))
          (- (* (sine x) (cosine y)) (* (cosine x) (sine y)))))
 (defthm acl2-numberp-cosine (acl2-numberp (cosine x)))
 (defthm acl2-numberp-sine (acl2-numberp (sine x))))

; e^{j theta} := cplx(cos theta, sen theta)
(defun eiz (theta) (cplx (cosine theta) (sine theta)))

; --- Ecuacion (10): cos(delta) = (e^{j delta} + e^{-j delta}) / 2 ---
(defthm eq10-euler-coseno
  (implies (acl2-numberp delta)
           (equal (* 1/2 (+ (re (eiz delta)) (re (eiz (- delta)))))
                  (cosine delta))))

; --- Ecuacion (12): cos(delta - gamma) = e^{j delta} . e^{j gamma} ---
(defthm eq12-coseno-diferencia-es-dotp
  (implies (and (acl2-numberp delta) (acl2-numberp gamma))
           (equal (dotp (eiz delta) (eiz gamma))
                  (cosine (- delta gamma)))))
