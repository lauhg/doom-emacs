;;; ui/neotree/config.el -*- lexical-binding: t; -*-

(use-package! neotree
  :commands (neotree-show
             neotree-hide
             neotree-toggle
             neotree-dir
             neotree-find
             neo-global--with-buffer
             neo-global--window-exists-p)
  :config
  (setq neo-create-file-auto-open nil
        neo-toggle-window-keep-p t
        neo-window-fixed-size nil
        neo-auto-indent-point nil
        neo-autorefresh nil
        neo-mode-line-type 'none
        neo-window-width 30
        neo-show-updir-line nil
        neo-theme 'nerd ; fallback
        neo-banner-message nil
        neo-confirm-create-file #'off-p
        neo-confirm-create-directory #'off-p
        neo-show-hidden-files nil
        neo-keymap-style 'concise
        neo-show-hidden-files t
        neo-hidden-regexp-list
        '(;; vcs folders
          "^\\.\\(?:git\\|hg\\|svn\\)$"
          ;; compiled files
          "\\.\\(?:pyc\\|o\\|elc\\|lock\\|css.map\\|class\\)$"
          ;; generated files, caches or local pkgs
          "^\\(?:node_modules\\|vendor\\|.\\(project\\|cask\\|yardoc\\|sass-cache\\)\\)$"
          ;; macos
          "^\\.\\(?:DS_Store\\)$"
          ;; org-mode folders
          "^\\.\\(?:sync\\|export\\|attach\\)$"
          ;; temp files
          "~$"
          "^#.*#$"))

  (set-popup-rule! "^ ?\\*NeoTree"
    :side neo-window-position :size neo-window-width
    :quit nil :select t)

  (after! winner
    (add-to-list 'winner-boring-buffers neo-buffer-name))

  ;; The cursor always sits at bol. `+neotree--fix-cursor-h' and
  ;; `+neotree--indent-cursor-a' change that behavior so that the cursor is
  ;; always on the first non-blank character on the line, in the neo buffer.
  (add-hook! 'neo-enter-hook
    (defun +neotree-fix-cursor-h (&rest _)
      (with-current-buffer neo-global--buffer
        (+neotree--indent-cursor-a))))

  (defadvice! +neotree--indent-cursor-a (&rest _)
    :after '(neotree-next-line neotree-previous-line)
    (beginning-of-line)
    (skip-chars-forward " \t\r"))

  (map! :map neotree-mode-map
        :n "g"      nil
        :n "TAB"    #'neotree-quick-look
        :n "RET"    #'neotree-enter
        :n [tab]    #'neotree-quick-look
        :n [return] #'neotree-enter
        :n "DEL"    #'evil-window-prev
        :n "c"      #'neotree-create-node
        :n "r"      #'neotree-rename-node
        :n "d"      #'neotree-delete-node
        :n "j"      #'neotree-next-line
        :n "k"      #'neotree-previous-line
        :n "n"      #'neotree-next-line
        :n "p"      #'neotree-previous-line
        :n "h"      #'+neotree/collapse-or-up
        :n "l"      #'+neotree/expand-or-open
        :n "J"      #'neotree-select-next-sibling-node
        :n "K"      #'neotree-select-previous-sibling-node
        :n "H"      #'neotree-select-up-node
        :n "L"      #'neotree-select-down-node
        :n "G"      #'evil-goto-line
        :n "gg"     #'evil-goto-first-line
        :n "v"      #'neotree-enter-vertical-split
        :n "s"      #'neotree-enter-horizontal-split
        :n "q"      #'neotree-hide
        :n "R"      #'neotree-refresh))
