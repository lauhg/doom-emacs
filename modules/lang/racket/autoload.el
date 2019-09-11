;;; lang/racket/autoload.el -*- lexical-binding: t; -*-

;;;###autoload
(defun +racket/repl ()
  "Open the Racket REPL."
  (interactive)
  (pop-to-buffer
   (or (get-buffer "*Racket REPL*")
       (progn (racket-run-and-switch-to-repl)
              (let ((buf (get-buffer "*Racket REPL*")))
                (bury-buffer buf)
                buf)))))

;;;###autoload
(defun my/racket-repl ()
  ""
  (interactive)
  (let ((window (selected-window))
        (repl-live-p (get-buffer-window "*Racket REPL*")))
    (racket-repl)
    (when (not repl-live-p)
      (shrink-window 12))
    ))

;;;###autoload
(defun my/racket-run ()
  ""
  (interactive)
  (let ((window (selected-window))
        (repl-live-p (get-buffer-window "*Racket REPL*")))
    (racket-run-and-switch-to-repl)
    (when (not repl-live-p)
      (shrink-window 12))
    (select-window window)))

(defun my/racket-run-and-switch-to-repl ()
  ""
  (interactive)
  (let ((window (selected-window))
        (repl-live-p (get-buffer-window "*Racket REPL*")))
    (racket-run-and-switch-to-repl)
    (when (not repl-live-p)
      (shrink-window 12))))
