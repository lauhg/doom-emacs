;; -*- no-byte-compile: t; -*-
;;; lang/go/packages.el

(package! go-eldoc)
;; (package! go-guru)
(package! go-mode)
(package! go-add-tags)
(package! go-gen-test)

(when (featurep! :completion company)
  (package! company-go))

; (package! lsp-mode)
; (package! company-lsp)
