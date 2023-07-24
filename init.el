;; (setq debug-on-error t)
(setq nxml-slash-auto-complete-flag 1)
;; (setq inhibit-startup-screen 1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(disable-theme 'tsdh-light)
;; (global-hl-line-mode t)
(column-number-mode t)
(jinx-mode 1)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(defalias 'yes-or-no-p #'y-or-n-p)
(setq-default fill-column 95)
(setq scroll-step 1
      pixel-scroll-precision-mode 1
      pixel-scroll-precision-large-scroll-height 5.0
      mouse-wheel-progressive-speed nil
      mouse-wheel-scroll-amount '(3 ((shift) . 2)))

(setq auto-save-interval 20)
(setq backup-directory-alist `((".*" . ,temporary-file-directory))
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
      create-lockfile nil)

(setq completion-styles '(basic orderless))
(setq nxml-child-indent 4 nxml-attribute-indent 4)

(recentf-mode 1)
(setq-default recentf-max-menu-items 25
              recentf-max-saved-items 25)

(set-face-attribute 'default nil :background "#f0fff0":height 120)
(set-face-attribute 'cursor nil :background "black")
(set-face-background 'cursor "black")


(setq which-key-lighter "")

(global-whitespace-mode 1)
(setq whitespace-style '(face trailing))
(show-paren-mode 1)
(setq show-paren-delay 0)
(setq ediff-window-setup-function #'ediff-setup-windows-plain)
(setq ediff-split-window-function #'split-window-horizontally)

(setq flymake-show-diagnostics-at-end-of-line t)

(if (executable-find "rg")
    (setq grep-command "rg -npS0")
  (setq grep-command "grep --color=auto -nrZHIe "))

(if (version< emacs-version "27")
    (add-hook 'focus-out-hook 'save-all-unsaved)
  (setq after-focus-change-function 'save-all-unsaved))


;; Keybinds
(global-set-key (kbd "C-c C-n")        #'global-display-line-numbers-mode)
;; (global-set-key (kbd "<escape>")       #'god-local-mode)
(global-set-key (kbd "C-x C-0")        #'delete-window)
(global-set-key (kbd "C-x C-1")        #'delete-other-windows)
(global-set-key (kbd "C-x C-2")        #'split-window-below)
(global-set-key (kbd "C-x C-3")        #'split-window-right)
(global-set-key (kbd "C-x 2")          #'split-and-follow-below)
(global-set-key (kbd "C-x 3")          #'split-and-follow-right)
(global-set-key (kbd "C-<tab>")        #'toggle-last-buffer)
(global-set-key (kbd "C-s")            #'my-consult-line)
;; (global-set-key (kbd "C-c d w")        #'delete-trailing-whitespace)
(global-set-key (kbd "C-x C-r")        #'consult-recent-file)
(global-set-key [(shift return)]       #'open-line-and-insert)
(global-set-key [(ctrl shift return)]  #'open-line-and-insert-above)
(global-set-key (kbd "C-c D")          #'crux-duplicate-current-line-or-region)
(global-set-key (kbd "C-c I")          #'crux-find-user-init-file)
(global-set-key (kbd "C-k")            #'crux-smart-kill-line)
(global-set-key (kbd "C-S-k")          #'crux-kill-whole-line)
;; (global-set-key (kbd "C-Del"           #'crux-kill-line-backwards)
(global-set-key (kbd "C-x C-b")        #'switch-to-buffer)
(global-set-key (kbd "C-x b")          #'list-buffers)
(global-set-key (kbd "C-x C-o")        #'other-window)
(global-set-key (kbd "C-x o")          #'delete-blank-lines)
(global-set-key (kbd "C-x 4 t")        #'crux-transpose-windows)
(global-set-key (kbd "C-c l p")        #'eww-live-preview)
(global-set-key (kbd "C-c C-q C-j")    #'vertico-quick-insert)
(global-set-key (kbd "C-x v =")        #'vc-ediff)






;; Functions
(defun toggle-comment-on-line ()
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))

(defun last-real-buffer (buffers)
  (if buffers
      (let ((name (buffer-name (car buffers))))
        (if (and (equal name (string-trim name "[ \*]+" "\*"))
                 (or (equal "vterm" (string-trim name "*" "*"))
                     (equal "shell" (string-trim name "*" "*"))))
            (car buffers)
          (last-real-buffer (cdr buffers))))
    nil))

(defun toggle-last-buffer ()
  (interactive)
  (switch-to-buffer (last-real-buffer (cdr (buffer-list)))))

(defun my-consult-line ()
  (interactive)
  (let ((completion-styles '(flex)))
    (call-interactively #'consult-line)))

(defun after-save-interactively-actions ()
  (when (memq this-command '(save-buffer save-some-buffers))
    (eww-refresh)
    (delete-trailing-whitespace)))

(add-hook 'after-save-hook #'after-save-interactively-actions)

(defvar eww-buffer-name nil)

(defun eww-refresh ()
  "Refresh the `eww` buffer."
  (interactive)
  (when (and (not (null eww-buffer-name)) (get-buffer eww-buffer-name))
    (with-current-buffer eww-buffer-name
      (eww-reload))))

(defun eww-live-preview ()
  "Open the current buffer in a vertical window to the right of the current buffer with `eww` if it is an HTML file."
  (interactive)
  (when (and buffer-file-name (string-equal (file-name-extension buffer-file-name) "html"))
    (let ((html-file-name (file-name-nondirectory buffer-file-name))
	  (original-window (selected-window)))
      (unless (and (not (null eww-buffer-name)) (get-buffer eww-buffer-name))
	(split-window-right)
	(other-window 1)
	(eww (concat "file://" buffer-file-name))
	(setq eww-buffer-name (format "eww live preview (%s)" html-file-name))
	(rename-buffer eww-buffer-name)
	(select-window original-window)
	(set-window-point original-window (point))))))


(require 'nxml-mode)
(define-key nxml-mode-map (kbd ">")    #'my-finish-element)

(defun my-in-start-tag-p ()
  ;; Check that we're at the end of a start tag. From the source code of
  ;; `nxml-balanced-close-start-tag`.
  (let ((token-end (nxml-token-before))
	(pos (1+ (point)))
	(token-start xmltok-start))
    (or (eq xmltok-type 'partial-start-tag)
	(and (memq xmltok-type '(start-tag empty-element partial-empty-element))
	     (>= token-end pos)))))

(defun my-finish-element ()
  (interactive)
  (if (my-in-start-tag-p)
      ;; If we're at the end of a start tag like `<foo`, complete this to
      ;; `<foo></foo>`, then move the point between the start and end tags.
      (nxml-balanced-close-start-tag-inline)
      ;; Otherwise insert an angle bracket.
      (insert ">")))


(defun my-nxml-newline ()
  "Insert a newline, indenting the current line and the newline appropriately in nxml-mode."
  (interactive)
  ;; Are we between an open and closing tag?
  (if (and (char-before) (char-after)
           (char-equal (char-before) ?>)
           (char-equal (char-after) ?<))
      ;; If so, indent it properly.
      (let ((indentation (current-indentation)))
	(newline)
	(newline)
	(indent-for-tab-command)
	(previous-line)
        (indent-for-tab-command)
        (end-of-line))
    ;; Otherwise just insert a regular newline.
    (newline)
    (indent-for-tab-command)))
(define-key nxml-mode-map (kbd "RET") 'my-nxml-newline)

(defun nxml-where ()
  "Display the hierarchy of XML elements the point is on as a
path. from http://www.emacswiki.org/emacs/NxmlMode"
  (interactive)
  (let ((path nil))
    (save-excursion
      (save-restriction
        (widen)
        (while (and (< (point-min) (point)) ;; No error if point is at beginning of buffer
                 (condition-case nil
                     (progn (nxml-backward-up-element) ;; Always returns nil
                       t)
                   (error nil)))
          (setq path (cons (xmltok-start-tag-local-name) path)))
        (if (called-interactively-p t)
            (message "/%s" (mapconcat 'identity path "/"))
          (format "/%s" (mapconcat 'identity path "/")))))))

(defun open-line-and-insert (arg)
  (interactive "P")
  (when (bound-and-true-p god-local-mode) (god-local-mode -1))
  (crux-smart-open-line arg))

(defun open-line-and-insert-above ()
  (interactive)
  (when (bound-and-true-p god-local-mode) (god-local-mode -1))
  (crux-smart-open-line-above))

(defun save-all-unsaved ()
  (interactive)
  (save-some-buffers 1))


(defface eval-result-overlay-face
  '((t :background "#f0fff0" (:slant italic)))
  "Face used to display evaluation results at the end of line."
  :group 'faces)

(defvar elisp--last-post-command-position 0
  "Holds the cursor position from the last run of post-command-hooks.")

(make-variable-buffer-local 'elisp--last-post-command-position)

(defun elisp--remove-overlay ()
  (unless (equal (point) elisp--last-post-command-position)
    (remove-overlays (point-min) (point-max) 'category 'eval-result))
  (setq elisp--last-post-command-position (point)))


(defvar eval-overlay-max-length 50)

(defun figo/eval-last-sexp (eval-last-sexp-arg-internal)
  (interactive "P")
  (let* ((res (prin1-to-string (eval-last-sexp eval-last-sexp-arg-internal)))
     (str (substring res 0 (min eval-overlay-max-length (length res))))
     (pt (save-excursion (move-end-of-line nil) (point)))
     (ov (make-overlay pt pt)))
    (overlay-put ov 'category 'eval-result)
    (overlay-put ov 'after-string
         (concat "" (propertize (concat " => " (if (string= "nil" str) "∅" str))
                     'face
                     'eval-result-overlay-face)))))

(global-set-key [remap eval-last-sexp] #'figo/eval-last-sexp)

(add-hook 'emacs-lisp-mode-hook
      (lambda () (add-to-list 'post-command-hook #'elisp--remove-overlay)))

(defun convert-number-to-decimal ()
  (interactive)
  (convert-number-at-point-or-region 10))

(defun convert-number-to-binary ()
  (interactive)
  ())

(defun convert-number-to-octal ()
  (interactive)
  ())

(defun convert-number-to-hex ()
  (interactive)
  ())

(defun decimal-to-binary-string (num)
  (let ((str ""))
    (while (> num 0)
      (setq str (concat (if (= 1 (logand num 1)) "1" "0") str))
      (setq num (lsh num -1)))
    (if (string= str "")
	(setq str "0"))
    str))

(defun convert-string-number-to-string (word)
  (number-to-string
   (string-to-number (replace-regexp-in-string "^[0]?[b|o|x]" "" word) (number-base-at-point word))))

(defun replace-thing (word beg end)
  (interactive)
  (save-restriction
    (narrow-to-region beg end)
    (goto-char (point-min))
    (while (search-forward word nil t)
      (replace-match (convert-string-number-to-string word)))))

(defun convert-number-at-point-or-region (base)
  "Samples of valid input:
    ffff
    0xffff
    #xffff
    xfff
    FFFF
    0xFFFF
    #xFFFF
    0b11011
    0101010
    0o173

  Test cases
   64*0xc8+#x12c 190*0x1f4+#x258
   100 200 300   400 500 600"
  (interactive)
  (if (region-active-p)
      (let* ((beg (region-beginning))
	     (end (region-end))
	     (word (buffer-substring beg end)))
	(replace-thing word beg end))
    (let* ((word (thing-at-point 'word))
	   (bounds (bounds-of-thing-at-point 'symbol))
	   (beg (car bounds))
	   (end (cdr bounds)))
      (replace-thing word beg end))))

(defun number-base-at-point (word)
  "Determine the base (binary, octal, hexadecimal, decimal) of the word under cursor or selected region."
  (interactive)
    (cond ((string-match-p "^0[bB][01]+$" word)
           2)
          ((string-match-p "^0[oO][0-7]+$" word)
           8)
          ((string-match-p "^[0][xX][0-9A-Fa-f]+$" word)
           16)
          ((string-match-p "^[+-]?[0-9]+$" word)
           10)
          (t
           (message "The word '%s' is not a recognized number format." word))))

(defun my-convert-number-format ()
  "Convert the number format of the word under cursor or selected region."
  (interactive)
  (let ((word (if (region-active-p)
                  (buffer-substring (region-beginning) (region-end))
                (thing-at-point 'word))))
    (unless (string-empty-p word)
      (let* ((options '(("Decimal to Binary" . "d2b")
                       ("Decimal to Hexadecimal" . "d2h")
                       ("Binary to Decimal" . "b2d")
                       ("Binary to Hexadecimal" . "b2h")
                       ("Hexadecimal to Decimal" . "h2d")
                       ("Hexadecimal to Binary" . "h2b")))
             (choice (completing-read "Choose the conversion option: " options))
             (result (cond ((equal choice "d2b") (number-to-string (string-to-number word 10) 2))
                           ((equal choice "d2h") (format "%x" (string-to-number word 10)))
                           ((equal choice "b2d") (number-to-string (string-to-number word 2) 10))
                           ((equal choice "b2h") (format "%x" (string-to-number word 2)))
                           ((equal choice "h2d") (number-to-string (string-to-number word 16) 10))
                           ((equal choice "h2b") (number-to-string (string-to-number word 16) 2))
                           (t word))))
        (when (region-active-p)
          (delete-region (region-beginning) (region-end)))
        (insert result)))))

(defun split-and-follow-below ()
  "Open a new window vertically."
  (interactive)
  (split-window-below)
  (other-window 1)
  (consult-buffer))

(defun split-and-follow-right ()
  "Open a new window horizontally."
  (interactive)
  (split-window-right)
  (other-window 1)
  (consult-buffer))

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa"  . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
(package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Packages
(use-package avy
  :config
  (global-set-key (kbd "C-;")   #'avy-goto-char)
  (global-set-key (kbd "C-'")   #'avy-goto-char-2)
  (global-set-key (kbd "C-:")   #'avy-goto-line))

(use-package consult)

(use-package crux)

(use-package docker
  :ensure t
  ;; :bind ("C-c d" . docker)
  )

(setq display-buffer-alist
      '(("\\*docker.*\\*"
         (display-buffer-reuse-window display-buffer-in-side-window)
         (window-height . 0.4)
         (side . bottom)
         (slot . -1))))

;; (use-package eglot
  ;; :ensure t
  ;; :hook
  ;; (haskell-mode . eglot-ensure)
  ;; :custom
  ;; (eglot-autoshutdown t)
  ;; (eglot-confirm-server-initiated-edits nil)
  ;; (eglot-echo-area-display-truncation-message nil))

(use-package lsp-mode
  :ensure t
  :hook (haskell-mode . lsp)
  :commands lsp)
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)
(use-package lsp-haskell
  :ensure t
  :config
 (setq lsp-haskell-server-path "haskell-language-server-wrapper")
 (setq lsp-haskell-server-args ())
   ;; Comment/uncomment this line to see interactions between lsp client/server.
 ;(setq lsp-log-io t)
 )


;; (use-package god-mode
  ;; :init
  ;; (god-mode-all 1)
  ;; :config
  ;; (define-key god-local-mode-map (kbd ".") #'repeat)
  ;; (define-key god-local-mode-map (kbd "i") #'god-local-mode)
  ;; (define-key god-local-mode-map (kbd "[") #'backward-paragraph)
  ;; (define-key god-local-mode-map (kbd "]") #'forward-paragraph)
  ;; (define-key god-local-mode-map (kbd "s") #'my-consult-line))



(use-package haskell-mode
  :init
  (add-hook 'haskell-mode-hook (lambda () (haskell-indentation-mode -1))))

(use-package helpful
  :ensure t
  :bind
  (([remap describe-command]  . helpful-command)
   ([remap describe-key]      . helpful-key)
   ([remap describe-variable] . helpful-variable)
   ([remap describe-function] . helpful-callable)
   ("C-h V" . describe-face)))

(use-package jinx
  :bind
  (("M-$" . jinx-correct)
   ("C-M-$" . jinx-languages))
  :init
  (dolist (hook '(text-mode-hook))
    (add-hook hook #'jinx-mode))
  (dolist (hook '(change-log-mode-hook log-edit-mode-hook sgml-mode-hook))
    (add-hook hook (lambda () (jinx-mode -1))))
  :config
  (set-face-attribute 'jinx-misspelled nil
              :underline '(:style wave :color "red")))


(use-package marginalia
  :after vertico
  :ensure t
  :config
  (setq marginalia-align 'center)
  (marginalia-mode))

(use-package orderless
  :custom
  ;; (completion-styles '(orderless))
  (completion-category-defaults nil)
  ;; (completion-category-overrides
   ;; '((file (styles basic-remote orderless)))))
  )

(use-package sly)


(use-package smartparens
  :defer 1
  :bind (
	:map smartparens-mode-map
	     ("C-M-a"     . sp-beginning-of-sexp)
	     ("C-M-e"     . sp-end-of-sexp)
	     ("C-<down>"  . sp-down-sexp)
	     ("C-<up>"    . sp-up-sexp)
	     ("M-<down>"  . sp-backward-down-sexp)
	     ("M-<up>"    . sp-backward-up-sexp)
	     ("M-["       . sp-backward-unwrap-sexp)
	     ("M-]"       . sp-unwrap-sexp)
	     ("C-<right>" . sp-forward-slurp-sexp)
	     ("C-<left>"  . sp-forward-barf-sexp)
	     ("M-<right>" . sp-backward-barf-sexp)
	     ("M-<left>"  . sp-backward-slurp-sexp)
	     ("C-M-t"     . sp-transpose-sexp)
	))


(use-package smartparens-config
  :ensure smartparens
  :config (progn (show-smartparens-global-mode t)))


(add-hook 'prog-mode-hook 'turn-on-smartparens-strict-mode)
(add-hook 'markdown-mode-hook 'turn-on-smartparens-strict-mode)

(use-package tagedit)

(use-package vertico
  :init
  (vertico-mode 1)
  :custom
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  (read-extended-command-predicate #'command-completion-default-include-p)
  (enable-resursive-minibuffers t)
  (completion-in-region-function #'consult-completion-in-region)
  :config
  (setq vertico-count 10
        vertico-resize 1))


;; Configure directory extension.
(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
         ("RET" . vertico-directory-enter)
         ("DEL" . vertico-directory-delete-char)
         ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package vterm
  :ensure t)

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (which-key-enable-god-mode-support)
  (setq which-key-idle-delay 1))

(use-package whitespace-cleanup-mode)
(whitespace-cleanup-mode 1)


;; (defun my-sgml-insert-gt ()
;;   "Inserts a `>' character and calls
;; `my-sgml-close-tag-if-necessary', leaving point where it is."
;;   (interactive)
;;   (insert ">")
;;   (save-excursion (my-sgml-close-tag-if-necessary)))

;; (defun my-sgml-close-tag-if-necessary ()
  ;; "Calls sgml-close-tag if the tag immediately before point is
;; an opening tag that is not followed by a matching closing tag."
  ;; (when (looking-back "<\\s-*\\([^</> \t\r\n]+\\)[^</>]*>")
    ;; (let ((tag (match-string 1)))
      ;; (unless (and (not (sgml-unclosed-tag-p tag))
           ;; (looking-at (concat "\\s-*<\\s-*/\\s-*" tag "\\s-*>")))
    ;; (sgml-close-tag)))))

;; (eval-after-load "sgml-mode"
;;   '(define-key sgml-mode-map ">" 'my-sgml-insert-gt))

;; Requires
(require 'whitespace)
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; extra
(defun my-frame-tweaks (&optional frame)
  "My personal frame tweaks."
  (unless frame
    (setq frame (selected-frame)))
  (when frame
    (with-selected-frame frame
      (when (display-graphic-p)
    (set-face-attribute 'cursor nil :background "#000000")))))

;; For the case that the init file runs after the frame has been created.
;; Call of emacs without --daemon option.
(my-frame-tweaks)
;; For the case that the init file runs before the frame is created.
;; Call of emacs with --daemon option.
(add-hook 'after-make-frame-functions #'my-frame-tweaks t)

(set-face-attribute 'cursor nil :background "black")
(set-face-background 'cursor "black")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(connection-local-criteria-alist
   '(((:application tramp) tramp-connection-local-default-system-profile
      tramp-connection-local-default-shell-profile)))
 '(connection-local-profile-alist
   '((tramp-connection-local-darwin-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o"
					"pid,uid,user,gid,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					"-o" "state=abcde" "-o"
					"ppid,pgid,sess,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etime,pcpu,pmem,args")
      (tramp-process-attributes-ps-format (pid . number) (euid . number) (user . string)
					  (egid . number) (comm . 52) (state . 5)
					  (ppid . number) (pgrp . number) (sess . number)
					  (ttname . string) (tpgid . number) (minflt . number)
					  (majflt . number) (time . tramp-ps-time)
					  (pri . number) (nice . number) (vsize . number)
					  (rss . number) (etime . tramp-ps-time)
					  (pcpu . number) (pmem . number) (args)))
     (tramp-connection-local-busybox-ps-profile
      (tramp-process-attributes-ps-args "-o"
					"pid,user,group,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					"-o" "stat=abcde" "-o"
					"ppid,pgid,tty,time,nice,etime,args")
      (tramp-process-attributes-ps-format (pid . number) (user . string) (group . string)
					  (comm . 52) (state . 5) (ppid . number)
					  (pgrp . number) (ttname . string)
					  (time . tramp-ps-time) (nice . number)
					  (etime . tramp-ps-time) (args)))
     (tramp-connection-local-bsd-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o"
					"pid,euid,user,egid,egroup,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
					"-o"
					"state,ppid,pgid,sid,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etimes,pcpu,pmem,args")
      (tramp-process-attributes-ps-format (pid . number) (euid . number) (user . string)
					  (egid . number) (group . string) (comm . 52)
					  (state . string) (ppid . number) (pgrp . number)
					  (sess . number) (ttname . string) (tpgid . number)
					  (minflt . number) (majflt . number)
					  (time . tramp-ps-time) (pri . number) (nice . number)
					  (vsize . number) (rss . number) (etime . number)
					  (pcpu . number) (pmem . number) (args)))
     (tramp-connection-local-default-shell-profile (shell-file-name . "/bin/sh")
						   (shell-command-switch . "-c"))
     (tramp-connection-local-default-system-profile (path-separator . ":")
						    (null-device . "/dev/null"))))
 '(docker-container-columns
   '(("Id" 16 "{{ json .ID }}" nil nil) ("Image" 15 "{{ json .Image }}" nil nil)
     ("Command" 30 "{{ json .Command }}" nil nil)
     ("Created" 25 "{{ json .CreatedAt }}" nil
      (lambda (x) (format-time-string "%F %T" (date-to-time x))))
     ("Status" 30 "{{ json .Status }}" nil nil) ("Ports" 10 "{{ json .Ports }}" nil nil)
     ("Names" 10 "{{ json .Names }}" nil nil)))
 '(package-selected-packages
   '(lsp-haskell lsp-ui lsp-mode jinx sly dired-git-info dired-git dired-git-mode docker orderless
		 whitespace-cleanup-mode whiespace-cleanup-mode whiespace-cleanup smartparens
		 haskell-mode avy vterm crux marginalia helpful consult vertico god-mode
		 counsel which-key use-package ivy-rich evil)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#fafafa" :foreground "#383a42" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight regular :height 120 :width normal :foundry "GOOG" :family "JetBrains Mono NL Slashed"))))
 '(cursor ((t (:background "black"))))
 '(flymake-end-of-line-diagnostics-face ((t (:underline t :slant oblique :weight bold :height 0.85))))
 '(font-lock-comment-face ((t (:foreground "gray57" :slant italic))))
 '(font-lock-string-face ((t (:foreground "dark green"))))
 '(highlight ((t (:background "gainsboro"))))
 '(lv-separator ((t (:background "gray"))))
 '(minibuffer-prompt ((t (:foreground "#0184bc" :box nil :weight bold))))
 '(region ((t (:extend t :background "gray"))))
 '(tab-line ((t (:background "grey85" :foreground "black" :height 0.9)))))
