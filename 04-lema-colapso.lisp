; 04-lema-colapso.lisp
;
; Verifica el "lema de colapso trifasico" de la Seccion III.H
; (ecuaciones 33-35), la demostracion mas sustancial que el articulo
; agrega respecto del original: para cualquier vector A constante en
; n, sum_{n=0}^{2} (2/3)(A . e^{jn gamma}) e^{jn gamma} = A.
; Tambien verifica la identidad de corrimiento de fase (imagen 62)
; usada para aplicar el lema al termino MUTUO del enlace de flujo.

(in-package "ACL2")
(include-book "02-raices-unidad")
(include-book "01-euler-trig")

; --- Lema de colapso (imagenes 56-60), version general para A=(ra,ia) ---
(defthm eq33-35-lema-colapso-trifasico
  (implies (and (rationalp ra) (rationalp ia) (rationalp s3)
                (equal (* s3 s3) 3))
           (equal (cadd (cscale (* 2/3 (dotp (cplx ra ia) (e0))) (e0))
                  (cadd (cscale (* 2/3 (dotp (cplx ra ia) (e1 s3))) (e1 s3))
                        (cscale (* 2/3 (dotp (cplx ra ia) (e2 s3))) (e2 s3))))
                  (cplx ra ia)))
  :hints (("Goal" :nonlinearp t)))

; --- Identidad de corrimiento de fase (imagen 62), aplicada al
;     termino mutuo con B=i_{k+1}(t), phi=(-1)^k eps(t):
;     B . e^{j(n gamma - phi)} = (B e^{j phi}) . e^{j n gamma}.
;     No requiere la identidad pitagorica de cos/sin: es pura algebra
;     de las formulas de angulo-diferencia (verificado explicitamente:
;     ambos lados se reducen, sin usar cos^2+sin^2=1, a la misma
;     combinacion cos(n gamma)[p cos(phi)-q sin(phi)] +
;     sin(n gamma)[p sin(phi)+q cos(phi)]). ---
(defthm eq-desplazamiento-fase-mutuo
  (implies (and (rationalp p) (rationalp q)
                (acl2-numberp x) (acl2-numberp phi))
           (equal (dotp (cplx p q) (eiz (- x phi)))
                  (dotp (cmul (cplx p q) (eiz phi)) (eiz x))))
  :hints (("Goal" :use ((:instance cosine-diferencia (x x) (y phi))
                        (:instance sine-diferencia (x x) (y phi))))))
