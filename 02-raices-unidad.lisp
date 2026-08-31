; 02-raices-unidad.lisp
;
; Introduce las tres raices cubicas de la unidad e^{j n gamma},
; gamma = 2*pi/3, n=0,1,2 -- usadas en las ecuaciones (16)-(28) y en
; el lema de colapso trifasico (33)-(35) -- y prueba que su suma es
; cero (imagenes 20 y 58-60 del articulo).
;
; LIMITE DE HONESTIDAD: sqrt(3) es irracional. ACL2 estandar (sin
; ACL2(r)) solo tiene numeros racionales y complejo-racionales como
; objetos: NO existe ningun objeto ACL2 racional testigo que satisfaga
; s3*s3=3, por lo que introducir s3 via ENCAPSULATE (que exige exhibir
; un testigo concreto) es imposible aqui. En su lugar, s3 se deja como
; variable libre UNIVERSALMENTE CUANTIFICADA en cada teorema, con la
; hipotesis explicita (equal (* s3 s3) 3). Esto es honesto y suficiente:
; cada teorema dice "para cualquier s3 que cumpla s3^2=3 (en particular,
; sqrt(3) si se trabajara en los reales), se cumple que...".

(in-package "ACL2")
(include-book "00-complejos-vectores")

(defun e0 () (cplx 1 0))
(defun e1 (s3) (cplx (- (/ 1 2)) (/ s3 2)))
(defun e2 (s3) (cplx (- (/ 1 2)) (- (/ s3 2))))

; --- Imagen 20: 1 + e^{j gamma} + e^{j 2 gamma} = 0 ---
(defthm eq-raices-unidad-suma-cero
  (equal (cadd (e0) (cadd (e1 s3) (e2 s3)))
         (cplx 0 0)))

; --- Imagen 60: suma de raices cubicas con angulo doblado (usada en
;     el lema de colapso, aplicada al termino mutuo) tambien es cero.
;     Es la MISMA suma que arriba, solo que los terminos n=0,1,2 caen
;     en distinto orden (0, 4pi/3, 8pi/3 = 2pi/3): e0 + e2 + e1. ---
(defthm eq-raices-unidad-angulo-doble-suma-cero
  (equal (cadd (e0) (cadd (e2 s3) (e1 s3)))
         (cplx 0 0)))
