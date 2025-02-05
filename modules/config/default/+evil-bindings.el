;;; config/default/+bindings.el -*- lexical-binding: t; -*-

(when (featurep! :editor evil +everywhere)
  ;; Have C-u behave similarly to `doom/backward-to-bol-or-indent'.
  ;; NOTE SPC u replaces C-u as the universal argument.
  (map! :gi "C-u" #'doom/backward-kill-to-bol-and-indent
        :gi "C-w" #'backward-kill-word
        ;; Vimmish ex motion keys
        :gi "C-b" #'backward-word
        :gi "C-f" #'forward-word)

  ;; Minibuffer
  (define-key! evil-ex-completion-map
    "C-a" #'move-beginning-of-line
    "C-b" #'backward-word
    "C-s" (if (featurep! :completion ivy)
              #'counsel-minibuffer-history
            #'helm-minibuffer-history))

  (define-key! :keymaps +default-minibuffer-maps
    [escape] #'abort-recursive-edit
    "C-v"    #'yank
    "C-z"    (λ! (ignore-errors (call-interactively #'undo)))
    "C-a"    #'move-beginning-of-line
    "C-b"    #'backward-word
    "C-r"    #'evil-paste-from-register
    ;; Scrolling lines
    "C-j"    #'next-line
    "C-k"    #'previous-line
    "C-S-j"  #'scroll-up-command
    "C-S-k"  #'scroll-down-command)

  (define-key! read-expression-map
    "C-j" #'next-line-or-history-element
    "C-k" #'previous-line-or-history-element))


;;
;;; Global keybindings

;; Smart tab, these will only work in GUI Emacs
(map! :i [tab] (general-predicate-dispatch nil ; fall back to nearest keymap
                 (and (featurep! :editor snippets)
                      (bound-and-true-p yas-minor-mode)
                      (yas-maybe-expand-abbrev-key-filter 'yas-expand))
                 #'yas-expand
                 (and (featurep! :completion company +tng)
                      (+company-has-completion-p))
                 #'+company/complete)
      :n [tab] (general-predicate-dispatch nil
                 (and (featurep! :editor fold)
                      (save-excursion (end-of-line) (invisible-p (point))))
                 #'+fold/toggle
                 (fboundp 'evil-jump-item)
                 #'evil-jump-item)
      :v [tab] (general-predicate-dispatch nil
                 (and (bound-and-true-p yas-minor-mode)
                      (or (eq evil-visual-selection 'line)
                          (not (memq (char-after) (list ?\( ?\[ ?\{ ?\} ?\] ?\))))))
                 #'yas-insert-snippet
                 (fboundp 'evil-jump-item)
                 #'evil-jump-item)

      ;; Smarter newlines
      :i [remap newline] #'newline-and-indent  ; auto-indent on newline
      :i "C-j"           #'+default/newline    ; default behavior

      (:after help :map help-mode-map
        :n "o"       #'ace-link-help)
      (:after helpful :map helpful-mode-map
        :n "o"       #'ace-link-help)
      (:after info :map Info-mode-map
        :n "o"       #'ace-link-info)
      (:after apropos :map apropos-mode-map
        :n "o"       #'ace-link-help
        :n "TAB"     #'forward-button
        :n [tab]     #'forward-button
        :n [backtab] #'backward-button)
      (:after view :map view-mode-map
        [escape]  #'View-quit-all)
      (:after man :map Man-mode-map
        :n "q"    #'kill-current-buffer)

      :m "gs"     #'+evil/easymotion  ; lazy-load `evil-easymotion'
      (:when (featurep! :editor multiple-cursors)
        :prefix "gz"
        :nv "d" #'evil-mc-make-and-goto-next-match
        :nv "D" #'evil-mc-make-and-goto-prev-match
        :nv "j" #'evil-mc-make-cursor-move-next-line
        :nv "k" #'evil-mc-make-cursor-move-prev-line
        :nv "m" #'evil-mc-make-all-cursors
        :nv "n" #'evil-mc-make-and-goto-next-cursor
        :nv "N" #'evil-mc-make-and-goto-last-cursor
        :nv "p" #'evil-mc-make-and-goto-prev-cursor
        :nv "P" #'evil-mc-make-and-goto-first-cursor
        :nv "q" #'evil-mc-undo-all-cursors
        :nv "t" #'+multiple-cursors/evil-mc-toggle-cursors
        :nv "u" #'evil-mc-undo-last-added-cursor
        :nv "z" #'+multiple-cursors/evil-mc-make-cursor-here
        :v  "I" #'evil-mc-make-cursor-in-visual-selection-beg
        :v  "A" #'evil-mc-make-cursor-in-visual-selection-end)

      ;; misc
      :n "C-S-f"  #'toggle-frame-fullscreen
      :n "C-+"    #'doom/reset-font-size
      ;; Buffer-local font resizing
      :n "C-="    #'text-scale-increase
      :n "C--"    #'text-scale-decrease
      ;; Frame-local font resizing
      :n "M-C-="  #'doom/increase-font-size
      :n "M-C--"  #'doom/decrease-font-size)


;;
;;; Module keybinds

;;; :completion
(map! (:when (featurep! :completion company)
        :i "C-@"      #'+company/complete
        :i "C-SPC"    #'+company/complete
        (:after company
          (:map company-active-map
            "C-w"     nil  ; don't interfere with `evil-delete-backward-word'
            "C-n"     #'company-select-next
            "C-p"     #'company-select-previous
            "C-j"     #'company-select-next
            "C-k"     #'company-select-previous
            "C-h"     #'company-show-doc-buffer
            "C-u"     #'company-previous-page
            "C-d"     #'company-next-page
            "C-s"     #'company-filter-candidates
            "C-S-s"   (cond ((featurep! :completion helm) #'helm-company)
                            ((featurep! :completion ivy)  #'counsel-company))
            "C-SPC"   #'company-complete-common
            "TAB"     #'company-complete-common-or-cycle
            [tab]     #'company-complete-common-or-cycle
            [backtab] #'company-select-previous)
          (:map company-search-map  ; applies to `company-filter-map' too
            "C-n"     #'company-select-next-or-abort
            "C-p"     #'company-select-previous-or-abort
            "C-j"     #'company-select-next-or-abort
            "C-k"     #'company-select-previous-or-abort
            "C-s"     (λ! (company-search-abort) (company-filter-candidates))
            "ESC"     #'company-search-abort))
        ;; TAB auto-completion in term buffers
        (:after comint :map comint-mode-map
          "TAB" #'company-complete
          [tab] #'company-complete))

      (:when (featurep! :completion ivy)
        (:after ivy
          :map ivy-minibuffer-map
          "C-SPC" #'ivy-call-and-recenter  ; preview file
          "C-l"   #'ivy-alt-done
          "C-v"   #'yank)
        (:after counsel
          :map counsel-ag-map
          "C-SPC"    #'ivy-call-and-recenter ; preview
          "C-l"      #'ivy-done
          [C-return] #'+ivy/git-grep-other-window-action))

      (:when (featurep! :completion helm)
        (:after helm :map helm-map
          [left]     #'left-char
          [right]    #'right-char
          "C-S-f"    #'helm-previous-page
          "C-S-n"    #'helm-next-source
          "C-S-p"    #'helm-previous-source
          "C-S-j"    #'helm-next-source
          "C-S-k"    #'helm-previous-source
          "C-j"      #'helm-next-line
          "C-k"      #'helm-previous-line
          "C-u"      #'helm-delete-minibuffer-contents
          "C-s"      #'helm-minibuffer-history
          ;; Swap TAB and C-z
          "TAB"      #'helm-execute-persistent-action
          [tab]      #'helm-execute-persistent-action
          "C-z"      #'helm-select-action)
        (:after helm-ag :map helm-ag-map
          "C--"      #'+helm-do-ag-decrease-context
          "C-="      #'+helm-do-ag-increase-context
          [left]     nil
          [right]    nil)
        (:after helm-files :map (helm-find-files-map helm-read-file-map)
          [C-return] #'helm-ff-run-switch-other-window
          "C-w"      #'helm-find-files-up-one-level)
        (:after helm-locate :map helm-generic-files-map
          [C-return] #'helm-ff-run-switch-other-window)
        (:after helm-buffers :map helm-buffer-map
          [C-return] #'helm-buffer-switch-other-window)
        (:after helm-occur :map helm-occur-map
          [C-return] #'helm-occur-run-goto-line-ow)
        (:after helm-grep :map helm-grep-map
          [C-return] #'helm-grep-run-other-window-action)))

;;; :ui
(map! (:when (featurep! :ui popup)
        :n "C-`"   #'+popup/toggle
        :n "C-~"   #'+popup/raise
        :g "C-x p" #'+popup/other)

      (:when (featurep! :ui workspaces)
        :n "C-S-t" #'+workspace/display
        :g "M-1"   #'winum-select-window-1
        :g "M-2"   #'winum-select-window-2
        :g "M-3"   #'winum-select-window-3
        :g "M-4"   #'winum-select-window-4
        :g "M-5"   #'winum-select-window-5
        :g "M-6"   #'winum-select-window-6
        :g "M-7"   #'winum-select-window-7
        :g "M-8"   #'winum-select-window-8
        :g "M-9"   #'winum-select-window-9
        :g "M-0"   #'winum-select-window-0
        (:when IS-MAC
          :g "s-t"   #'+workspace/new
          :g "s-T"   #'+workspace/display
          :n "s-1"   #'+workspace/switch-to-0
          :n "s-2"   #'+workspace/switch-to-1
          :n "s-3"   #'+workspace/switch-to-2
          :n "s-4"   #'+workspace/switch-to-3
          :n "s-5"   #'+workspace/switch-to-4
          :n "s-6"   #'+workspace/switch-to-5
          :n "s-7"   #'+workspace/switch-to-6
          :n "s-8"   #'+workspace/switch-to-7
          :n "s-9"   #'+workspace/switch-to-8
          :n "s-0"   #'+workspace/switch-to-final)))

;;; :editor
(map! (:when (featurep! :editor format)
        :n "gQ" #'+format:region)

      (:when (featurep! :editor rotate-text)
        :n "!"  #'rotate-text)

      (:when (featurep! :editor multiple-cursors)
        ;; evil-multiedit
        :v  "R"     #'evil-multiedit-match-all
        :n  "M-d"   #'evil-multiedit-match-symbol-and-next
        :n  "M-D"   #'evil-multiedit-match-symbol-and-prev
        :v  "M-d"   #'evil-multiedit-match-and-next
        :v  "M-D"   #'evil-multiedit-match-and-prev
        :nv "C-M-d" #'evil-multiedit-restore
        (:after evil-multiedit
          (:map evil-multiedit-state-map
            "M-d"    #'evil-multiedit-match-and-next
            "M-D"    #'evil-multiedit-match-and-prev
            "RET"    #'evil-multiedit-toggle-or-restrict-region
            [return] #'evil-multiedit-toggle-or-restrict-region)))

      (:when (featurep! :editor snippets)
        ;; auto-yasnippet
        :i  [C-tab] #'aya-expand
        :nv [C-tab] #'aya-create))

;;; :tools
(when (featurep! :tools eval)
  (map! "M-r" #'+eval/buffer))


;;
;;; <leader>

(map! :leader
      :desc "Eval expression"       ";"    #'eval-expression
      :desc "M-x"                   ":"    #'execute-extended-command
      :desc "Pop up scratch buffer" "x"    #'doom/open-scratch-buffer
      :desc "Org Capture"           "X"    #'org-capture

      ;; C-u is used by evil
      :desc "Universal argument"    "u"    #'universal-argument
      :desc "window"                "w"    evil-window-map
      :desc "help"                  "h"    help-map

      (:when (featurep! :ui popup)
        :desc "Toggle last popup"     "~"    #'+popup/toggle)
      :desc "Find file"             "."    #'find-file

      :desc "Switch buffer"         ","    #'switch-to-buffer
      (:when (featurep! :ui workspaces)
        :desc "Switch workspace buffer" "," #'persp-switch-to-buffer
        :desc "Switch buffer"           "<" #'switch-to-buffer)

      :desc "Switch to last buffer" "`"    #'evil-switch-to-windows-last-buffer
      :desc "Resume last search"    "'"
      (cond ((featurep! :completion ivy)   #'ivy-resume)
            ((featurep! :completion helm)  #'helm-resume))

      :desc "Search for symbol in project" "*" #'+default/search-project-for-symbol-at-point

      :desc "Find file in project"  "SPC"  #'projectile-find-file
      :desc "Blink cursor line"     "DEL"  #'+nav-flash/blink-cursor
      :desc "Jump to bookmark"      "RET"  #'bookmark-jump

      ;;; <leader> / --- search
      (:prefix-map ("/" . "search")
        :desc "Search buffer"                 "/" #'swiper
        :desc "Search buffer"                 "b" #'swiper
        :desc "Search current directory"      "d" #'+default/search-cwd
        :desc "Search other directory"        "D" #'+default/search-other-cwd
        :desc "Locate file"                   "f" #'locate
        :desc "Jump to symbol"                "i" #'imenu
        :desc "Jump to link"                  "l" #'ace-link
        :desc "jump list"                     "j" #'evil-show-jumps
        :desc "Jump to mark"                  "m"   #'evil-show-marks
        :desc "Look up online"                "o" #'+lookup/online
        :desc "Look up online (w/ prompt)"    "O" #'+lookup/online-select
        :desc "Look up in local docsets"      "k" #'+lookup/in-docsets
        :desc "Look up in all docsets"        "K" #'+lookup/in-all-docsets
        :desc "Search project"                "p" #'+default/search-project
        :desc "Search other project"          "P" #'+default/search-other-project)

      ;;; <leader> TAB --- workspace
      (:when (featurep! :ui workspaces)
        (:prefix-map ("l" . "workspace")
          :desc "Display tab bar"           "l"   #'+workspace/display
          :desc "Switch workspace"          "."   #'+workspace/switch-to
          :desc "Switch to last workspace"  "TAB" #'+workspace/other
          :desc "New workspace"             "n"   #'+workspace/new
          :desc "Load workspace from file"  "i"   #'+workspace/load
          :desc "Save workspace to file"    "s"   #'+workspace/save
          :desc "Delete session"            "x"   #'+workspace/kill-session
          :desc "Delete this workspace"     "d"   #'+workspace/delete
          :desc "Rename workspace"          "r"   #'+workspace/rename
          :desc "Restore last session"      "R"   #'+workspace/restore-last-session
          :desc "Next workspace"            "]"   #'+workspace/switch-right
          :desc "Previous workspace"        "["   #'+workspace/switch-left
          :desc "Switch to 1st workspace"   "1"   #'+workspace/switch-to-0
          :desc "Switch to 2nd workspace"   "2"   #'+workspace/switch-to-1
          :desc "Switch to 3rd workspace"   "3"   #'+workspace/switch-to-2
          :desc "Switch to 4th workspace"   "4"   #'+workspace/switch-to-3
          :desc "Switch to 5th workspace"   "5"   #'+workspace/switch-to-4
          :desc "Switch to 6th workspace"   "6"   #'+workspace/switch-to-5
          :desc "Switch to 7th workspace"   "7"   #'+workspace/switch-to-6
          :desc "Switch to 8th workspace"   "8"   #'+workspace/switch-to-7
          :desc "Switch to 9th workspace"   "9"   #'+workspace/switch-to-8
          :desc "Switch to final workspace" "0"   #'+workspace/switch-to-final
          ))

      ;;; <leader> b --- buffer
      (:prefix-map ("b" . "buffer")
        :desc "Toggle narrowing"            "-"   #'doom/toggle-narrow-buffer
        :desc "Previous buffer"             "["   #'previous-buffer
        :desc "Next buffer"                 "]"   #'next-buffer
        (:when (featurep! :ui workspaces)
          :desc "Switch workspace buffer" "b" #'persp-switch-to-buffer
          :desc "Switch buffer"           "B" #'switch-to-buffer)
        (:unless (featurep! :ui workspaces)
          :desc "Switch buffer"           "b" #'switch-to-buffer)
        :desc "Kill buffer"                 "d"   #'kill-current-buffer
        :desc "ibuffer"                     "i"   #'ibuffer
        :desc "Kill buffer"                 "k"   #'kill-current-buffer
        :desc "Kill all buffers"            "K"   #'doom/kill-all-buffers
        :desc "Jumplist"                    "j"   #'evil-show-jumps
        :desc "Switch to last buffer"       "l"   #'evil-switch-to-windows-last-buffer
        :desc "Next buffer"                 "n"   #'next-buffer
        :desc "New empty buffer"            "N"   #'evil-buffer-new
        :desc "Kill other buffers"          "O"   #'doom/kill-other-buffers
        :desc "Previous buffer"             "p"   #'previous-buffer
        :desc "Revert buffer"               "r"   #'revert-buffer
        :desc "Save buffer"                 "s"   #'basic-save-buffer
        :desc "Save all buffers"            "S"   #'evil-write-all
        :desc "Pop up scratch buffer"       "x"   #'doom/open-scratch-buffer
        :desc "Switch to scratch buffer"    "X"   #'doom/switch-to-scratch-buffer
        :desc "Bury buffer"                 "z"   #'bury-buffer
        :desc "Kill buried buffers"         "Z"   #'doom/kill-buried-buffers)

      ;;; <leader> c --- code
      (:prefix-map ("c" . "code")
        :desc "Compile"                     "c"   #'compile
        :desc "Recompile"                   "C"   #'recompile
        :desc "Jump to definition"          "d"   #'+lookup/definition
        :desc "Jump to references"          "D"   #'+lookup/references
        :desc "Evaluate buffer/region"      "e"   #'+eval/buffer-or-region
        :desc "Evaluate & replace region"   "E"   #'+eval:replace-region
        :desc "Format buffer/region"        "f"   #'+format/region-or-buffer
        :desc "LSP Format buffer/region"    "F"   #'+default/lsp-format-region-or-buffer
        :desc "LSP Organize imports"        "i"   #'lsp-organize-imports
        :desc "Jump to documentation"       "k"   #'+lookup/documentation
        :desc "LSP Rename"                  "r"   #'lsp-rename
        :desc "Send to repl"                "s"   #'+eval/send-region-to-repl
        :desc "Delete trailing whitespace"  "w"   #'delete-trailing-whitespace
        :desc "Delete trailing newlines"    "W"   #'doom/delete-trailing-newlines
        (:when (featurep! :tools flycheck)
          :desc "List errors"                 "x"   #'flycheck-list-errors)
        (:unless (featurep! :tools flycheck)
          :desc "List errors"                 "x"   #'flymake-show-diagnostics-buffer))

      ;;; <leader> f --- file
      (:prefix-map ("f" . "file")
        :desc "Find file"                   "."   #'find-file
        :desc "Find file from here"         "/"
        (if (featurep! :completion ivy)
            #'counsel-file-jump
          (λ! (doom-project-find-file default-directory)))
        :desc "Open project editorconfig"   "c"   #'editorconfig-find-current-editorconfig
        :desc "Copy this file"              "C"   #'doom/copy-this-file
        :desc "Find directory"              "d"   #'dired
        :desc "Delete this file"            "D"   #'doom/delete-this-file
        :desc "Find file in emacs.d"        "e"   #'+default/find-in-emacsd
        :desc "Browse emacs.d"              "E"   #'+default/browse-emacsd
        :desc "Find file from here"         "f"   #'find-file
        :desc "Locate file"                 "l"   #'locate
        :desc "Move/rename file"            "m"   #'doom/move-this-file
        :desc "Find file in private config" "p"   #'doom/find-file-in-private-config
        :desc "Browse private config"       "P"   #'doom/open-private-config
        :desc "Recent files"                "r"   #'recentf-open-files
        :desc "Recent project files"        "R"   #'projectile-recentf
        :desc "Save file"                   "s"   #'save-buffer
        :desc "Save file as..."             "S"   #'write-file
        :desc "Sudo find file"              "u"   #'doom/sudo-find-file
        :desc "Sudo this file"              "U"   #'doom/sudo-this-file
        :desc "Yank filename"               "y"   #'+default/yank-buffer-filename)

      ;;; <leader> g --- git
      (:prefix-map ("g" . "git")
        :desc "Git revert file"             "R"   #'vc-revert
        :desc "Copy git link"               "y"   #'git-link
        :desc "Copy git link to homepage"   "Y"   #'git-link-homepage
        (:when (featurep! :ui vc-gutter)
          :desc "Git revert hunk"           "r"   #'git-gutter:revert-hunk
          :desc "Git stage hunk"            "s"   #'git-gutter:stage-hunk
          :desc "Git time machine"          "t"   #'git-timemachine-toggle
          :desc "Jump to next hunk"         "]"   #'git-gutter:next-hunk
          :desc "Jump to previous hunk"     "["   #'git-gutter:previous-hunk)
        (:when (featurep! :tools magit)
          :desc "Magit dispatch"            "/"   #'magit-dispatch
          :desc "Forge dispatch"            "'"   #'forge-dispatch
          :desc "Magit switch branch"       "b"   #'magit-branch-checkout
          :desc "Magit status"              "g"   #'magit-status
          :desc "Magit file delete"         "D"   #'magit-file-delete
          :desc "Magit blame"               "B"   #'magit-blame-addition
          :desc "Magit clone"               "C"   #'+magit/clone
          :desc "Magit fetch"               "F"   #'magit-fetch
          :desc "Magit buffer log"          "L"   #'magit-log
          :desc "Git stage file"            "S"   #'magit-stage-file
          :desc "Git unstage file"          "U"   #'magit-unstage-file
          (:prefix ("f" . "find")
            :desc "Find file"                 "f"   #'magit-find-file
            :desc "Find gitconfig file"       "g"   #'magit-find-git-config-file
            :desc "Find commit"               "c"   #'magit-show-commit
            :desc "Find issue"                "i"   #'forge-visit-issue
            :desc "Find pull request"         "p"   #'forge-visit-pullreq)
          (:prefix ("o" . "open in browser")
            :desc "Browse region or line"     "o"   #'+vc/git-browse-region-or-line
            :desc "Browse remote"             "r"   #'forge-browse-remote
            :desc "Browse commit"             "c"   #'forge-browse-commit
            :desc "Browse an issue"           "i"   #'forge-browse-issue
            :desc "Browse a pull request"     "p"   #'forge-browse-pullreq
            :desc "Browse issues"             "I"   #'forge-browse-issues
            :desc "Browse pull requests"      "P"   #'forge-browse-pullreqs)
          (:prefix ("l" . "list")
            (:when (featurep! :tools gist)
              :desc "List gists"              "g"   #'+gist:list)
            :desc "List repositories"         "r"   #'magit-list-repositories
            :desc "List submodules"           "s"   #'magit-list-submodules
            :desc "List issues"               "i"   #'forge-list-issues
            :desc "List pull requests"        "p"   #'forge-list-pullreqs
            :desc "List notifications"        "n"   #'forge-list-notifications)
          (:prefix ("c" . "create")
            :desc "Initialize repo"           "r"   #'magit-init
            :desc "Clone repo"                "R"   #'+magit/clone
            :desc "Commit"                    "c"   #'magit-commit-create
            :desc "Fixup"                     "f"   #'magit-commit-fixup
            :desc "Branch"                    "b"   #'magit-branch-and-checkout
            :desc "Issue"                     "i"   #'forge-create-issue
            :desc "Pull request"              "p"   #'forge-create-pullreq)))

      ;;; <leader> i --- insert
      (:prefix-map ("i" . "insert")
        :desc "From clipboard"                "y"   #'+default/yank-pop
        :desc "From evil register"            "r"   #'evil-ex-registers
        :desc "Snippet"                       "s"   #'yas-insert-snippet
        :desc "Unicode"                       "u"   #'unicode-chars-list-chars)

      ;;; <leader> n --- notes
      (:prefix-map ("n" . "notes")
        :desc "Browse notes"                 "." #'+default/browse-notes
        :desc "Search notes"                 "/" #'+default/org-notes-search
        :desc "Search notes for symbol"      "*" #'+default/search-notes-for-symbol-at-point
        :desc "Org agenda"                   "a" #'org-agenda
        :desc "Org capture"                  "c" #'org-capture
        :desc "Open deft"                    "d" #'deft
        :desc "Search org agenda headlines"  "h" #'+default/org-notes-headlines
        :desc "Org store link"               "l" #'org-store-link
        :desc "Tags search"                  "m" #'org-tags-view
        :desc "Find file in notes"           "n" #'+default/find-in-notes
        :desc "Browse notes"                 "N" #'+default/browse-notes
        :desc "Todo list"                    "t" #'org-todo-list
        :desc "View search"                  "v" #'org-search-view
        :desc "Org export to clipboard"        "y" #'+org/export-to-clipboard
        :desc "Org export to clipboard as RTF" "Y" #'+org/export-to-clipboard-as-rich-text

        (:when (featurep! :lang org +journal)
          (:prefix ("j" . "journal")
            :desc "New Entry"      "j" #'org-journal-new-entry
            :desc "Search Forever" "s" #'org-journal-search-forever)))

      ;;; <leader> o --- open
      (:prefix-map ("o" . "open")
        :desc "Org agenda"       "A"  #'org-agenda
        (:prefix ("a" . "org agenda")
          :desc "Agenda"         "a"  #'org-agenda
          :desc "Todo list"      "t"  #'org-todo-list
          :desc "Tags search"    "m"  #'org-tags-view
          :desc "View search"    "v"  #'org-search-view)
        :desc "Default browser"    "b"  #'browse-url-of-file
        :desc "Start debugger"     "d"  #'+debugger/start
        :desc "New frame"          "f"  #'make-frame
        :desc "REPL"               "r"  #'+eval/open-repl-other-window
        :desc "REPL (same window)" "R"  #'+eval/open-repl-same-window
        :desc "Dired"              "-"  #'dired-jump
        (:when (featurep! :ui neotree)
          :desc "Project sidebar"              "p" #'+neotree/open
          :desc "Find file in project sidebar" "P" #'+neotree/find-this-file)
        (:when (featurep! :ui treemacs)
          :desc "Project sidebar" "p" #'+treemacs/toggle
          :desc "Find file in project sidebar" "P" #'+treemacs/find-file)
        (:when (featurep! :term shell)
          :desc "Toggle shell popup"    "t" #'+shell/toggle
          :desc "Open shell here"       "T" #'+shell/here)
        (:when (featurep! :term term)
          :desc "Toggle terminal popup" "t" #'+term/toggle
          :desc "Open terminal here"    "T" #'+term/here)
        (:when (featurep! :term vterm)
          :desc "Toggle vterm popup"    "t" #'+vterm/toggle
          :desc "Open vterm here"       "T" #'+vterm/here)
        (:when (featurep! :term eshell)
          :desc "Toggle eshell popup"   "e" #'+eshell/toggle
          :desc "Open eshell here"      "E" #'+eshell/here)
        (:when (featurep! :tools macos)
          :desc "Reveal in Finder"           "o" #'+macos/reveal-in-finder
          :desc "Reveal project in Finder"   "O" #'+macos/reveal-project-in-finder
          :desc "Send to Transmit"           "u" #'+macos/send-to-transmit
          :desc "Send project to Transmit"   "U" #'+macos/send-project-to-transmit
          :desc "Send to Launchbar"          "l" #'+macos/send-to-launchbar
          :desc "Send project to Launchbar"  "L" #'+macos/send-project-to-launchbar)
        (:when (featurep! :tools docker)
          :desc "Docker" "D" #'docker))

      ;;; <leader> p --- project
      (:prefix-map ("p" . "project")
        :desc "Browse project"               "." #'+default/browse-project
        :desc "Browse other project"         ">" #'doom/browse-in-other-project
        :desc "Find file in project"         "/" #'projectile-find-file
        :desc "Find file in other project"   "?" #'doom/find-file-in-other-project
        :desc "Run cmd in project root"      "!" #'projectile-run-shell-command-in-root
        :desc "Add new project"              "a" #'projectile-add-known-project
        :desc "Switch to project buffer"     "b" #'projectile-switch-to-buffer
        :desc "Compile in project"           "c" #'projectile-compile-project
        :desc "Repeat last command"          "C" #'projectile-repeat-last-command
        :desc "Remove known project"         "d" #'projectile-remove-known-project
        :desc "Edit project .dir-locals"     "e" #'projectile-edit-dir-locals
        :desc "Find file in project"         "f" #'projectile-find-file
        :desc "Browse project"               "F" #'+default/browse-project
        :desc "Configure project"            "g" #'projectile-configure-project
        :desc "Invalidate project cache"     "i" #'projectile-invalidate-cache
        :desc "Kill project buffers"         "k" #'projectile-kill-buffers
        :desc "Find other file"              "o" #'projectile-find-other-file
        :desc "Switch project"               "p" #'projectile-switch-project
        :desc "Find recent project files"    "r" #'projectile-recentf
        :desc "Run project"                  "R" #'projectile-run-project
        :desc "Save project files"           "s" #'projectile-save-project-buffers
        :desc "Pop up scratch buffer"        "x" #'doom/open-project-scratch-buffer
        :desc "Switch to scratch buffer"     "X" #'doom/switch-to-project-scratch-buffer
        :desc "List project tasks"           "t" #'+default/project-tasks
        :desc "Test project"                 "T" #'projectile-test-project)

      ;;; <leader> q --- quit/session
      (:prefix-map ("q" . "quit/session")
        :desc "Kill Emacs (and daemon)"      "K" #'save-buffers-kill-emacs
        :desc "Quit Emacs"                   "q" #'save-buffers-kill-terminal
        :desc "Quit Emacs without saving"    "Q" #'evil-quit-all-with-error-code
        :desc "Quick save current session"   "s" #'doom/quicksave-session
        :desc "Restore last session"         "l" #'doom/quickload-session
        :desc "Save session to file"         "S" #'doom/save-session
        :desc "Restore session from file"    "L" #'doom/load-session
        :desc "Restart & restore Emacs"      "r" #'doom/restart-and-restore
        :desc "Restart Emacs"                "R" #'doom/restart
        :desc "Restart emacs server"         "d" #'+default/restart-server)

      ;;; <leader> r --- remote
      (:when (featurep! :tools upload)
        (:prefix-map ("r" . "remote")
          :desc "Upload local"               "u" #'ssh-deploy-upload-handler
          :desc "Upload local (force)"       "U" #'ssh-deploy-upload-handler-forced
          :desc "Download remote"            "d" #'ssh-deploy-download-handler
          :desc "Diff local & remote"        "D" #'ssh-deploy-diff-handler
          :desc "Browse remote files"        "." #'ssh-deploy-browse-remote-handler
          :desc "Detect remote changes"      ">" #'ssh-deploy-remote-changes-handler))

      ;;; <leader> s --- snippets
      (:when (featurep! :editor snippets)
        (:prefix-map ("s" . "snippets")
          :desc "View snippet for mode"      "/" #'+snippets/find-for-current-mode
          :desc "View snippet (global)"      "?" #'+snippets/find
          :desc "Edit snippet"               "c" #'+snippets/edit
          :desc "View private snippet"       "f" #'+snippets/find-private
          :desc "Insert snippet"             "i" #'yas-insert-snippet
          :desc "New snippet"                "n" #'+snippets/new
          :desc "New snippet alias"          "N" #'+snippets/new-alias
          :desc "Reload snippets"            "r" #'yas-reload-all
          :desc "Create temporary snippet"   "s" #'aya-create
          :desc "Expand temporary snippet"   "e" #'aya-expand))

      ;;; <leader> t --- toggle
      (:prefix-map ("t" . "toggle")
        :desc "Big mode"                     "b" #'doom-big-font-mode
        (:when (featurep! :tools flycheck)
          :desc "Flycheck"                   "f" #'flycheck-mode)
        (:unless (featurep! :tools flycheck)
          :desc "Flymake"                    "f" #'flymake-mode)
        :desc "Frame fullscreen"             "F" #'toggle-frame-fullscreen
        :desc "Evil goggles"                 "g" #'evil-goggles-mode
        (:when (featurep! :ui indent-guides)
          :desc "Indent guides"              "i" #'highlight-indent-guides-mode)
        :desc "Indent style"                 "I" #'doom/toggle-indent-style
        :desc "Line numbers"                 "l" #'doom/toggle-line-numbers
        (:when (featurep! :lang org +present)
          :desc "org-tree-slide mode"        "p" #'+org-present/start)
        :desc "Read-only mode"               "r" #'read-only-mode
        (:when (featurep! :tools flyspell)
          :desc "Flyspell"                   "s" #'flyspell-mode)
        (:when (featurep! :lang org +pomodoro)
          :desc "Pomodoro timer"             "t" #'org-pomodoro)
        :desc "Word-wrap mode"               "w" #'+word-wrap-mode))
