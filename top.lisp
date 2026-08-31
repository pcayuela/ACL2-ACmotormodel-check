; top.lisp
;
; Incluye, en orden de dependencia, todos los libros de esta
; verificacion. Certificar este libro certifica (transitivamente)
; todos los demas y confirma que la cadena completa carga sin
; errores desde cero.
;
;   cert.pl top
;
; Requiere ACL2 con los community-books estandar disponibles
; (usa arithmetic-5/top :dir :system).

(in-package "ACL2")

(include-book "00-complejos-vectores")
(include-book "01-euler-trig")
(include-book "02-raices-unidad")
(include-book "03-deduccion-zeta")
(include-book "04-lema-colapso")
(include-book "05-correccion-signo-torque")
(include-book "06-inductancias-nota")
