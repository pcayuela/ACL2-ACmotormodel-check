; 03-deduccion-zeta.lisp
;
; Verifica el nucleo algebraico de la deduccion de zeta_k(t), Seccion
; III.C del articulo (ecuaciones 16-28): dado el vector espacial de
; corriente i_k(t) = i_k0 e^{j0} + i_k1 e^{j gamma} + i_k2 e^{j 2 gamma}
; con corrientes balanceadas (i_k0+i_k1+i_k2=0), se prueban sus partes
; real e imaginaria y la formula del modulo al cuadrado. No se
; mecaniza atan2 (transcendente/multivaluada); el atan2 del articulo
; se apoya directamente en estas dos componentes algebraicas, que son
; donde podria esconderse un error de signo o de factor.

(in-package "ACL2")
(include-book "02-raices-unidad")

(defun ik (i0 i1 i2 s3)
  (cadd (cscale i0 (e0)) (cadd (cscale i1 (e1 s3)) (cscale i2 (e2 s3)))))

; --- Parte real de (16), tras usar el balance de corrientes (13) ---
(defthm eq16-28-re-ik-balanceada
  (implies (equal (+ i0 i1 i2) 0)
           (equal (re (ik i0 i1 i2 s3)) (* 3/2 i0))))

; --- Parte imaginaria de (16) ---
(defthm eq16-28-imz-ik
  (equal (imz (ik i0 i1 i2 s3)) (* (/ s3 2) (- i1 i2))))

; --- Formula del modulo al cuadrado que alimenta la ecuacion de
;     magnitud i_k(t) del articulo (division de senxcos + suma de
;     cuadrados). Requiere s3^2=3 y las corrientes/racional s3 como
;     racionales para que la aritmetica no lineal de ACL2 cierre. ---
(defthm eq-ik-magnitud-cuadrado
  (implies (and (rationalp i0) (rationalp i1) (rationalp i2) (rationalp s3)
                (equal i0 (- (+ i1 i2)))
                (equal (* s3 s3) 3))
           (equal (+ (* (re (ik i0 i1 i2 s3)) (re (ik i0 i1 i2 s3)))
                     (* (imz (ik i0 i1 i2 s3)) (imz (ik i0 i1 i2 s3))))
                  (* 9/4 (+ (* i0 i0) (* 1/3 (- i1 i2) (- i1 i2))))))
  :hints (("Goal" :nonlinearp t)))
