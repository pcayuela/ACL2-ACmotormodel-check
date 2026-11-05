; top-acl2r-ftc2.lisp
;
; Includes the FTC-2 completion of the inductance integral (10-...), which
; the ACL2(r)-only chain top-acl2r left open.  Certify with:
;   cert.pl --acl2 /path/to/saved_acl2r top-acl2r-ftc2
; cert_param: (uses-acl2r)

(in-package "ACL2")
(include-book "10-inductance-ftc2")
