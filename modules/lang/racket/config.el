;;; lang/racket/config.el -*- lexical-binding: t; -*-

(after! projectile
  (add-to-list 'projectile-project-root-files "info.rkt"))


;;
;;; Packages

(use-package! racket-mode
  :hook (racket-repl-mode . racket-unicode-input-method-enable)
  :config
  ;; (set-popup-rule! "^\\*Racket REPL" :size 10 :select t)
  (set-repl-handler! 'racket-mode #'+racket/open-repl)
  (set-lookup-handlers! 'racket-mode
    :definition    #'racket-visit-definition
    :documentation #'racket-describe)
  (set-docsets! 'racket-mode "Racket")
  (set-pretty-symbols! 'racket-mode
    :lambda  "lambda"
    :map     "map"
    :dot     ".")
  (set-rotate-patterns! 'racket-mode
    :symbols '(("#true" "#false")))

  (add-hook! 'racket-mode-hook
             #'rainbow-delimiters-mode
             #'highlight-quoted-mode)

  ;; (defadvice! my/racket-small-repl (orig-fn &optional noselect)
  ;;   ""
  ;;   (let ((repl-live-p (get-buffer-window "*Racket REPL*")))
  ;;     (funcall orig-fn noselect)
  ;;     (when (not repl-live-p)
  ;;       (shrink-window 12))
  ;;     ))

  ;; (advice-add #'racket-repl :around #'my/racket-small-repl)

  (map! :map (racket-mode-map racket-repl-mode-map)
        :i "[" #'racket-smart-open-bracket)

  (map! :map racket-mode-map
        ;; "C-t" #'racket-unvisit
        [remap pop-tag-mark] #'racket-unvisit
        "C-c C-c" #'my/racket-run
        "C-c C-s" #'my/racket-repl
        )

  ;; (define-key racket-mode-map (kbd "C-t") #'racket-unvisit)
  ;; (local-set-key (kbd "C-t") #'racket-unvisit)

  (map! :localleader
        :map racket-mode-map
        "a" #'racket-align
        "A" #'racket-unalign
        "f" #'racket-fold-all-tests
        "F" #'racket-unfold-all-tests
        "h" #'racket-doc
        "i" #'racket-unicode-input-method-enable
        "l" #'racket-logger
        "o" #'racket-profile
        "p" #'racket-cycle-paren-shapes
        "r" #'racket-run
        "R" #'my/racket-run-and-switch-to-repl
        "t" #'racket-test
        "u" #'racket-backward-up-list
        "y" #'racket-insert-lambda
        (:prefix ("m" . "macros")
          "d" #'racket-expand-definition
          "e" #'racket-expand-last-sexp
          "r" #'racket-expand-region
          "a" #'racket-expand-again)
        (:prefix ("g" . "goto")
          "b" #'racket-unvisit
          "d" #'racket-visit-definition
          "m" #'racket-visit-module
          "r" #'racket-open-require-path)
        (:prefix ("s" . "send")
          "d" #'racket-send-definition
          "e" #'racket-send-last-sexp
          "r" #'racket-send-region)))
