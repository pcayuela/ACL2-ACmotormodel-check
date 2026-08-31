; 00-complejos-vectores.lisp
;
; Verificacion mecanica (ACL2) de las identidades complejo<->vector
; usadas en Cayuela, "Modelo vectorial de la maquina de corriente
; alterna trifasica simetrica", ecuaciones (6)-(9).
;
; Representacion: un numero complejo / vector 2D se representa como
; (cons re im), NO como el tipo complejo nativo de Lisp (porque mas
; adelante aparecen componentes irracionales/simbolicas como sqrt(3)
; y cos/sen de un angulo arbitrario, que el tipo complejo nativo de
; ACL2 no admite: sus partes deben ser racionales).
;
; La convencion de producto cruzado usada aqui es la del articulo,
; citada a Needham (ref. [2]): A x B := Im(A B*). Con A=(a,b), B=(c,d)
; esto da A x B = b*c - a*d, que es la NEGATIVA de la formula "de
; libro de fisica" a*d - b*c. Es una eleccion de convencion valida y
; coherente, no un error: se usa consistentemente en todo el resto.

(in-package "ACL2")
(include-book "arithmetic-5/top" :dir :system)

(defun cplx (re im) (cons re im))
(defun re (z) (car z))
(defun imz (z) (cdr z))
(defun cconj (z) (cplx (re z) (- (imz z))))
(defun cadd (z w) (cplx (+ (re z) (re w)) (+ (imz z) (imz w))))
(defun csub (z w) (cplx (- (re z) (re w)) (- (imz z) (imz w))))
(defun cscale (k z) (cplx (* k (re z)) (* k (imz z))))
(defun cmul (z w) (cplx (- (* (re z) (re w)) (* (imz z) (imz w)))
                        (+ (* (re z) (imz w)) (* (imz z) (re w)))))
(defun dotp (z w) (+ (* (re z) (re w)) (* (imz z) (imz w))))
(defun crossp (z w) (- (* (imz z) (re w)) (* (re z) (imz w))))

; --- Ecuacion (6): AB* + A*B = 2 (A . B) ---
(defthm eq6-dotproducto-parte-real
  (equal (re (cadd (cmul z (cconj w)) (cmul (cconj z) w)))
         (* 2 (dotp z w))))

(defthm eq6-dotproducto-parte-imz
  (equal (imz (cadd (cmul z (cconj w)) (cmul (cconj z) w)))
         0))

; --- Ecuaciones (8)-(9): AB* - A*B = j2 (A x B) ---
(defthm eq8-9-cruz-parte-real
  (equal (re (csub (cmul z (cconj w)) (cmul (cconj z) w)))
         0))

(defthm eq8-9-cruz-parte-imz
  (equal (imz (csub (cmul z (cconj w)) (cmul (cconj z) w)))
         (* 2 (crossp z w))))

; Forma directa de (9), reutilizada en 05-correccion-signo-torque.lisp:
; Im(AB*) = A x B.
(defthm eq9-im-ab*-es-crossp
  (equal (imz (cmul z (cconj w)))
         (crossp z w)))
