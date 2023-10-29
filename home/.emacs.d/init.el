;;; init.el ---  emacs init file

;;; Commentary:

;;; Code:

;; package
(add-to-list 'load-path (locate-user-emacs-file "lisp"))
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(when (and (= emacs-major-version 26) (< emacs-minor-version 3))
  (defvar gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))
(package-initialize)

(defvar use-package-enable-imenu-support t)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(use-package diminish
  :ensure t)

;; language
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-default 'buffer-file-coding-system 'utf-8-unix)

;; windows
(when (eq system-type 'windows-nt)
  (setq windows-bin-path '("c:\\msys64\\mingw64\\bin"
                           "c:\\cmigemo-mingw64\\bin"))
  (setenv "PATH" (concat (mapconcat 'identity windows-bin-path ";") ";"
                         (getenv "PATH")))
  (setq exec-path (append exec-path windows-bin-path)
        make-backup-files nil
        auto-save-default nil)

  ;; etc
  (scroll-bar-mode -1)
;  (setq url-proxy-services
;        '(("http" . "")
;          ("https" . "")))

  (setq default-frame-alist
        (append (list
                 '(font . "Migu 2M-14"))
                default-frame-alist))
  (set-face-font 'fixed-pitch "Migu 2M-14")
  (set-face-font 'variable-pitch "Migu 2M-14")

  (set-foreground-color "#d4d4d4")
  (set-background-color "#1e1e1e")
  )

;; org
(use-package org
  :custom
  (org-reverse-note-order t)
  (org-directory "~/org")
  (org-default-notes-file "notes.org")
  (org-agenda-files '("~/org"))
  (org-refile-targets '((org-agenda-files :maxlevel . 2)))
  (org-startup-truncated nil)
  (org-confirm-babel-evaluate nil)
  (org-log-done 'time)
  (org-use-speed-commands t)
  (org-startup-indented nil)
  (org-startup-folded 'content)
  (org-todo-keywords
   '((sequence "TODO(t)" "SOMEDAY(s)" "WAITING(w)" "|"
               "DONE(d)" "CANCELED(c)")))
  (org-capture-templates
   '(("i" "Inbox" entry (file+headline "~/org/gtd.org" "INBOX")
      "* %?\n %i\n %a" :prepend t)
     ("n" "Note" entry (file+headline "~/org/notes.org" "Notes")
      "* %?\nEntered on %U\n %i\n %a" :prepend t)))
  :preface
  (defun show-org-buffer (file)
    "Show an org-file FILE on the current buffer."
    (interactive)
    (if (get-buffer file)
        (let ((buffer (get-buffer file)))
          (switch-to-buffer buffer)
          (message "%s" file))
      (find-file (concat (file-name-as-directory org-directory) file))))
  :config
  (use-package ox-md)
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((shell . t)
                                 (python . t)
                                 (emacs-lisp . t)))
  :bind
  (("C-c c" . org-capture)
   ("C-c a" . org-agenda)
   ("C-c l" . org-store-link)
   ("C-M-^" . (lambda () (interactive) (show-org-buffer "notes.org"))))
  )

;; ivy
(use-package ivy
  :ensure t
  :diminish
  :custom (ivy-use-virtual-buffers t)
  :bind
  ("C-c C-r" . ivy-resume)
  :config
  (ivy-mode 1)
  )

(use-package ivy-rich
  :ensure t
  :config
  (ivy-rich-mode 1))

(use-package counsel
  :ensure t
  :diminish
  :custom
  (counsel-find-file-ignore-regexp (regexp-opt '("~" "#")))
  :config
  (counsel-mode 1)
  :bind
  ("M-x" . counsel-M-x)
  ("C-x C-r" . counsel-recentf))

(use-package swiper
  :disabled
  :ensure t
  :bind ("C-s" . swiper))

(use-package ivy-prescient
  :ensure t
  :after (ivy counsel)
  :config
  (ivy-prescient-mode 1)
  (prescient-persist-mode 1))

;; avy
(use-package avy
  :custom
  (avy-timeout-seconds 1)
  :bind
  ("C-;" . avy-goto-char-timer))

;; dired-x
(use-package dired-x
  :custom (dired-isearch-filenames t)
  :hook (dired-mode . dired-omit-mode)
  :bind ("C-x C-j" . dired-jump))

;; recentf
(use-package recentf
  :config
  (recentf-mode 1))

;; projectile
(use-package projectile
  :ensure t
  :diminish
  :custom
  (projectile-switch-project-action 'projectile-dired)
  :config
  (projectile-mode +1)
  (when (executable-find "ghq")
    (setq projectile-known-projects
          (mapcar
           (lambda (x) (abbreviate-file-name x))
           (split-string (shell-command-to-string "ghq list --full-path")))))
  :bind-keymap
  ("C-c p" . projectile-command-map))

;; quickrun
(use-package quickrun
  :ensure t
  :bind ("<f5>" . quickrun))

;; google
(use-package google-this
  :ensure t
  :bind
  ("C-c g" . google-this))

;; magit
(use-package magit
  :ensure t
  :config
  (remove-hook 'server-switch-hook 'magit-commit-diff)
  :custom
  (magit-display-buffer-function 'magit-display-buffer-fullframe-status-v1)
  :bind ("C-x g" . magit-status))

;; which key
(use-package which-key
  :ensure t
  :diminish which-key-mode
  :hook (after-init . which-key-mode))

;; go
(use-package go-mode
  :ensure t
  )

;; lsp
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook
  (go-mode . lsp-deferred)
  (sh-mode . lsp-deferred)
  )

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

;; dap
(use-package dap-mode
  :ensure t
  :after (lsp-mode
          treemacs)
  :custom
  (dap-auto-configure-features '(sessions locals breakpoints expressions repl controls tooltip))
  :config
  (dap-mode 1)
  (dap-auto-configure-mode 1)
  (require 'dap-hydra)
  (require 'dap-dlv-go)
  :bind
  ("C-c d" . dap-hydra/body)
  )

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
;; (defun lsp-go-install-save-hooks ()
;;   (add-hook 'before-save-hook #'lsp-format-buffer t t)
;;   (add-hook 'before-save-hook #'lsp-organize-imports t t))
;; (add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; company
(use-package company
  :ensure t
  :config
  ;; Optionally enable completion-as-you-type behavior.
  (setq company-idle-delay 0.5)
  (setq company-minimum-prefix-length 3))

;; yasnippet
(use-package yasnippet
  :ensure t
  :commands yas-minor-mode
  :hook (go-mode . yas-minor-mode))

;; shell script
(use-package sh-script
  :custom (sh-basic-offset 2)
  :interpreter ("bats" . sh-mode))

;; markdown-mode
(use-package org-table
  :diminish
  :hook ((markdown-mode . orgtbl-mode)))
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . gfm-mode)
  :custom
  (markdown-fontify-code-blocks-natively t)
  :preface
  (defun cleanup-org-tables ()
    (save-excursion
      (goto-char (point-min))
      (while (search-forward "-+-" nil t) (replace-match "-|-"))))
  :hook
  ((markdown-mode . (lambda() (add-hook 'after-save-hook 'cleanup-org-tables
                                        nil 'make-it-local)))))

;; yaml-mode
(use-package yaml-mode
  :ensure t)

;; editor-config
(use-package editorconfig
  :ensure t
  :diminish
  :config
  (editorconfig-mode 1))

;; japanese-holidays
(use-package japanese-holidays
  :ensure t
  :custom
  (calendar-week-start-day 1)
  :config
  (setq calendar-holidays (append japanese-holidays holiday-other-holidays))
  :hook ((calendar-today-visible . calendar-mark-holidays)
         (calendar-today-visible . calendar-mark-today)
         (calendar-today-visible . japanese-holiday-mark-weekend)
         (calendar-today-invisible . japanese-holiday-mark-weekend)))

;; mozc
(use-package mozc
  :ensure t
  :if (executable-find "mozc_emacs_helper")
  :custom (default-input-method "japanese-mozc")
  :config
  (use-package mozc-popup
    :ensure t
    :custom (mozc-candidate-style 'popup))
  (defun mozc-handle-event--around (orig-func &rest event)
    "Intercept keys muhenkan and zenkaku-hankaku, before passing keys to mozc-server."
    (if (member (car event) (list 'zenkaku-hankaku 'muhenkan))
        (progn
          (mozc-clean-up-session)
          (toggle-input-method))
      (apply orig-func event)))
  (advice-add 'mozc-handle-event :around #'mozc-handle-event--around)
  :bind
  ([zenkaku-hankaku] . 'toggle-input-method)
  ([muhenkan] . 'toggle-input-method)
  )

;; w32-ime
(use-package w32-ime
  :if (eq system-type 'windows-nt)
  :custom
  (default-input-method "W32-IME")
  (w32-ime-mode-line-state-indicator-list '("[--]" "[あ]" "[--]"))
  (w32-ime-mode-line-state-indicator "[--]")
  :init
  (add-hook 'minibuffer-setup-hook 'deactivate-input-method)
  (add-hook 'isearch-mode-hook
            '(lambda ()
               (deactivate-input-method)
               (setq w32-ime-composition-window (minibuffer-window))))
  (add-hook 'isearch-mode-end-hook
            '(lambda () (setq w32-ime-composition-window nil)))
  :config
  (w32-ime-initialize))

;; migemo
(use-package migemo
  :if (executable-find "cmigemo")
  :ensure t
;  :custom
;  (migemo-coding-system 'utf-8-unix)
;  (migemo-options '("-q" "-e"))
  :config
  (defvar migemo-dictionary
    "/usr/local/share/migemo/utf-8/migemo-dict")
  (when (eq system-type 'windows-nt)
    (setq migemo-dictionary
          "C:/cmigemo-mingw64/share/migemo/utf-8/migemo-dict"))
  )

;; isepll & flyspell
(use-package ispell
  :if (executable-find "aspell")
  :custom
  (ispell-local-dictionary "en_US")
  :config
  (add-to-list 'ispell-skip-region-alist '("[^\000-\377]+"))
  (use-package flyspell-mode
    :hook (markdown-mode text-mode)))

;; flycheck
(use-package flycheck
  :ensure t
  :config (global-flycheck-mode))

;; ripgrep
(use-package rg
  :ensure t
  :if (executable-find "rg")
  :custom
  (rg-command-line-flags '("--hidden" "--glob='!.git/'"))
  (rg-default-alias-fallback "everything")
  )
(use-package ripgrep
  :ensure t
  :if (executable-find "rg")
  :custom
  (ripgrep-arguments '("--hidden" "--glob='!.git/'"))
  )

(use-package highlight-indent-guides
  :ensure t
  :if (window-system)
  :diminish
  :custom
  (highlight-indent-guides-auto-enabled t)
  (highlight-indent-guides-responsive t)
  (highlight-indent-guides-method 'bitmap)
  (highlight-indent-guides-character 124)
  :hook
  ((prog-mode yaml-mode) . highlight-indent-guides-mode))

;; ui
(tool-bar-mode -1)
(setq inhibit-startup-message t)
(cond (window-system
       (set-frame-font "Monospace-16"))
      (t
       (menu-bar-mode -1)))

;; etc
;(define-key key-translation-map (kbd "C-h") (kbd "<DEL>"))
(savehist-mode 1)
;(ffap-bindings)
(setq kill-whole-line t)
(setq ring-bell-function 'ignore)
(setq-default tab-width 4
              indent-tabs-mode nil)
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq vc-follow-symlinks t)
;(set-face-background 'line-number "brightwhite")
;(set-face-foreground 'line-number "darkgray")

;; custom
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(dap-mode hcl-mode typescript-mode ivy-hydra counsel mozc-popup imenu-list idomenu imenu-anywhere ripgrep rg markdown-mode magit yaml-mode popwin smex quickrun ido-vertical-mode multi-term projectile use-package migemo)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(provide 'init)
;;; init.el ends here
