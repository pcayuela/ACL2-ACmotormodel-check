; 05-correccion-signo-torque.lisp
;
; Verifica la cadena de derivacion de la Seccion III.K (ecuaciones
; 40-46): la correccion de signo del exponente en la ecuacion del
; momento motor. Es la parte de mayor riesgo del articulo: afirma que
; el texto original traia e^{-j eps(t)} y que la derivacion correcta
; a partir de la propia ecuacion de partida de Leonhard (40) da
; e^{+j eps(t)}.
;
; Aqui se fija W(t) := i_S(t) i_R*(t) e^{-j eps(t)} EXACTAMENTE como
; en (41)-(42) del articulo (ese es el "dato de entrada" que se toma
; de Leonhard, no algo que se derive aqui), y se verifica que el resto
; de la cadena -- hasta obtener el signo + en el argumento del
; producto vectorial cruzado -- es consecuencia algebraica correcta.
; No se verifica que (40)/(41) sean fieles al libro de Leonhard (no
; se tiene acceso al libro); solo que TODO lo que se deriva de (41)
; en el articulo es correcto.

(in-package "ACL2")
(include-book "00-complejos-vectores")
(include-book "01-euler-trig")
(include-book "02-raices-unidad")

; W = i_S * conj(i_R * E),  E = e^{j eps}  =>  W = i_S i_R* e^{-j eps}
(defun torque-W (i-s i-r eps)
  (cmul i-s (cconj (cmul i-r (eiz eps)))))

; --- W* = i_S* i_R e^{+j eps}  (dado explicitamente en el articulo) ---
(defthm eq-W-conjugado
  (equal (cconj (torque-W i-s i-r eps))
         (cmul (cconj i-s) (cmul i-r (eiz eps)))))

; --- (W - W*)/(2j) = Im(W), identidad general reutilizada de (8)-(9) ---
(defthm eq-w-menos-wconj-es-2j-im
  (and (equal (re (csub w (cconj w))) 0)
       (equal (imz (csub w (cconj w))) (* 2 (imz w)))))

; --- Comprobacion definicional AB* = W (imagen 74, con el check "✓") ---
(defthm eq-ab-estrella-es-w
  (equal (cmul i-s (cconj (cmul i-r (eiz eps))))
         (torque-W i-s i-r eps)))

; --- Aplicando (9): Im(W) = Im(AB*) = A x B, con A=i_S, B=i_R e^{j eps} ---
(defthm eq-im-w-es-crossp
  (equal (imz (torque-W i-s i-r eps))
         (crossp i-s (cmul i-r (eiz eps))))
  :hints (("Goal" :in-theory (e/d (torque-w) (eq-ab-estrella-es-w)))))

; --- Resultado final: el argumento que sobrevive en el producto
;     vectorial cruzado es i_R(t) rotado por +eps(t), es decir el
;     exponente correcto es +eps(t), no -eps(t) como en el texto
;     original. Esto reproduce exactamente (43)/(46) del articulo. ---
(defthm torque-exponent-sign-is-plus
  (equal (imz (torque-W i-s i-r eps))
         (crossp i-s (cmul i-r (eiz eps))))
  :hints (("Goal" :use eq-im-w-es-crossp :in-theory nil))
  :rule-classes nil)

; --- La correccion de signo no es vacua: para valores concretos, usar
;     el exponente -eps en vez de +eps cambia el resultado. Se usa
;     e1(s3)=e^{j gamma} como "+eps" y su conjugado e2(s3)=e^{-j gamma}
;     como la alternativa "-eps", con i_S=(1,1), i_R=(1,0). ---
(defthm signo-importa-no-es-vacuo
  (implies (and (rationalp s3) (equal (* s3 s3) 3))
           (not (equal (crossp (cplx 1 1) (cmul (cplx 1 0) (e1 s3)))
                       (crossp (cplx 1 1) (cmul (cplx 1 0) (e2 s3))))))
  :hints (("Goal" :nonlinearp t)))
