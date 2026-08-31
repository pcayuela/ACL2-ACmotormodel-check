; 06-inductancias-nota.lisp
;
; NOTA, sin contenido ejecutable: la Seccion III.F del articulo
; (ecuaciones 29-31, calculo de inductancia propia y mutua) requiere
; evaluar integrales definidas trigonometricas sobre [0, 2*pi]
; (metodo de "winding function"). ACL2 no tiene calculo simbolico ni
; una teoria de integracion: no puede evaluar esas integrales, y
; fingir una prueba mecanica de ese paso seria enganoso.
;
; Se deja deliberadamente sin mecanizar (se prefiere omitir antes que
; simular una prueba que no es tal). La unica parte de esa seccion que
; SI es mecanizable -- la identidad trigonometrica de producto a suma
; cos(A)cos(B) = 1/2[cos(A-B)+cos(A+B)] -- es consecuencia directa de
; las formulas de angulo-diferencia ya verificadas en
; 01-euler-trig.lisp (cosine-diferencia), y no se repite aqui por no
; aportar nada nuevo mas alla de lo ya probado.
;
; La verificacion manual (no mecanica) de esta seccion, incluido el
; chequeo cruzado L_k/M = (1+sigma_k) N_k/N_{k+1} contra el resultado
; escalar clasico de Leonhard, se reporto en la conversacion previa a
; este directorio, no aqui.

(in-package "ACL2")
