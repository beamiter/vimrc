
;;; package --- summary:
;;; Commentary:
(require 'package)
;;; Code:
(setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")

                         ("org" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/org/")))
(package-initialize)
;;(package-refresh-contents)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile (require 'use-package))

;; Ensure install
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; Auto update
;; (unless (package-installed-p 'auto-package-update)
;;   (package-refresh-contents)
;;   (package-install 'auto-package-update))

;; themes
(use-package ample-theme)
(use-package doom-themes)
(use-package gruvbox-theme)
(use-package gruber-darker-theme)
(use-package leuven-theme)
(use-package moe-theme)
(use-package monokai-pro-theme)
(use-package monokai-theme)
(use-package spacemacs-theme
  :no-require t)
(use-package srcery-theme)
(use-package modus-themes
  :ensure
  :init
  ;; Add all your customizations prior to loading the themes
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs nil
        modus-themes-region '(bg-only no-extend))

  ;; Load the theme files before enabling a theme
  (modus-themes-load-themes)
  :config
  ;; Load the theme of your choice:
  ;; (modus-themes-load-operandi)
  (modus-themes-load-vivendi)
  :bind ("<f5>" . modus-themes-toggle))
;;
;; (load-theme 'monokai-pro-classic t)
(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode))
(setq evil-want-keybinding nil)
(use-package evil-nerd-commenter)
(use-package format-all)
(use-package magit)
(use-package rainbow-delimiters)
(use-package winum)
(use-package xclip)
(use-package helm-themes)
(use-package helm-rg)
(use-package helm-ag)
(use-package undo-fu)
(use-package all-the-icons)
(use-package general)
(use-package tree-sitter
  :after treemacs evil
  :hook (after-init . (lambda() (global-tree-sitter-mode 1))))
(use-package rust-mode)
(use-package lsp-julia
  :init
  (setq lsp-julia-format-indent 2))
(use-package julia-mode
  :init
  (setq julia-indent-offset 2))
(use-package flycheck
  :init (global-flycheck-mode))

(use-package evil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-fu)
  :config
  (evil-global-set-key 'normal (kbd "K") 'lsp-ui-peek-find-definitions)
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-modeline-diagnostics-scope :workspace)
  :config
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
  :bind-keymap
  ;; ("C-l" . lsp-command-map)
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
	       (c++-mode . lsp-deferred)
	       (julia-mode . lsp-deferred)
	       (rust-mode . lsp-deferred)
	       (prog-mode . rainbow-delimiters-mode)
	       ;; if you want which-key integration
	       (lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-defered))

;; optionally
(use-package lsp-ui
  :commands lsp-ui-mode
  :init
  (add-hook 'lsp-mode-hook 'lsp-ui-mode)
  :config
  (setq lsp-ui-peek-enable t)
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-imenu-enable nil)
  (setq lsp-ui-flycheck-enable nil)
  (setq lsp-ui-sideline-enable nil)
  (setq lsp-ui-sideline-delay 0.5)
  (setq lsp-ui-sideline-show-hover nil)
  (setq lsp-ui-sideline-show-diagnostics t)
  (setq lsp-ui-sideline-show-code-actions t)
  (setq lsp-ui-sideline-ignore-duplicate t))
;; if you are helm user
(use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user
;;(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;;(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

(use-package which-key
  :init
  :config
  (which-key-mode))

(use-package helm
  :hook (after-init . (lambda() (helm-mode 1))))

(use-package projectile
  :init
  (projectile-mode 1)
  :bind (:map projectile-mode-map
	            ("C-c p" . projectile-command-map)))

(general-define-key
 :prefix "SPC"
 :states '(normal visual treemacs emacs)
 "b" '(:ignore t :wk ("b" . "buffer"))
 "bf" 'format-all-buffer
 "bb" 'helm-buffers-list
 "c" '(:ignore t :wk ("c" . "comment"))
 "cl" 'evilnc-comment-or-uncomment-lines
 "cp" 'evilnc-comment-or-uncomment-paragraphs
 "cr" 'comment-or-uncomment-region
 "f" '(:ignore t :which-key ("f" . "file"))
 "ft" '(treemacs :which-key "treemacs")
 "ff" 'projectile-find-file
 "fm" 'lsp-format-buffer
 "g" '(:ignore t :wk ("g" . "git"))
 "gj" '(git-gutter:next-hunk :properties (:repeat t :jump t))
 "gk" '(git-gutter:previous-hunk :repeat t :jump t)
 "p" '(:keymap projectile-command-map :wk "projectile prefix")
 "s" '(:ignore t :wk ("s" . "search"))
 "sg" 'projectile-grep
 "sr" 'projectile-ripgrep
 "sa" 'projectile-ag
 "0"  'winum-select-window-0-or-10
 "1"  'winum-select-window-1
 "2"  'winum-select-window-2
 "3"  'winum-select-window-3
 "4"  'winum-select-window-4
 "5"  'winum-select-window-5
 "6"  'winum-select-window-6
 "7"  'winum-select-window-7
 "8"  'winum-select-window-8
 "9"  'winum-select-window-9)
(general-define-key
 :prefix "["
 :states '(normal visual treemacs emacs)
 "g"  'git-gutter:previous-hunk
 )
(general-define-key
 :prefix "]"
 :states '(normal visual treemacs emacs)
 "g"  'git-gutter:next-hunk
 )

(use-package company
  :config
  (setq company-minimum-prefix-length 1
	      company-idle-delay 0.1) ;; default is 0.2
  :bind (:map company-active-map
              ([tab]     . #'company-complete-common-or-cycle)
              ("TAB"     . #'company-complete-common-or-cycle)
              ("S-TAB"   . #'company-select-previous-or-abort)
              ([backtab] . #'company-select-previous-or-abort)
              ([S-tab]   . #'company-select-previous-or-abort))
  :hook (after-init . (lambda ()
			                  (global-company-mode))))

;; -------- avy --------
(use-package avy
  :config
  (define-key evil-normal-state-map (kbd "s") 'avy-goto-char-2))

(use-package helm-projectile
  :init
  (setq helm-projectile-fuzzy-match t)
  (helm-projectile-on))


;; -------- evil nerd commenter --------
(evilnc-default-hotkeys t t)

;; -------- git gutter --------
(use-package git-gutter
  :hook (after-init . (lambda ()
			                  (global-git-gutter-mode)))
  :config
  (global-set-key (kbd "C-x C-g") 'git-gutter)
  (global-set-key (kbd "C-x v =") 'git-gutter:popup-hunk)
  ;; Jump to next/previous hunk
  (global-set-key (kbd "C-x p") 'git-gutter:previous-hunk)
  (global-set-key (kbd "C-x n") 'git-gutter:next-hunk)
  (global-set-key (kbd "C-x k") 'git-gutter:previous-hunk)
  (global-set-key (kbd "C-x j") 'git-gutter:next-hunk)
  ;; Stage current hunk
  (global-set-key (kbd "C-x v s") 'git-gutter:stage-hunk)
  ;; Revert current hunk
  (global-set-key (kbd "C-x v r") 'git-gutter:revert-hunk)
  ;; Mark current hunk
  (global-set-key (kbd "C-x v SPC") #'git-gutter:mark-hunk))

;; -------- treemacs config --------
(use-package treemacs
  :defer t
  :init
  (defvar treemacs-no-load-time-warnings t)
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
          treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-move-forward-on-expand        nil
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-asc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-user-mode-line-format         nil
          treemacs-user-header-line-format       nil
          treemacs-width                         35
          treemacs-workspace-switch-cleanup      nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  (global-set-key (kbd "C-n") 'treemacs)

  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
	      ([f3]        . treemacs)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after treemacs evil)

(use-package treemacs-projectile
  :after treemacs projectile)

(use-package treemacs-icons-dired
  :after treemacs dired
  :config (treemacs-icons-dired-mode))

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once))

(use-package treemacs-magit
  :after treemacs magit)

(use-package treemacs-persp ;;treemacs-persective if you use perspective.el vs. persp-mode
  :after treemacs persp-mode ;;or perspective vs. persp-mode
  :config (treemacs-set-scope-type 'Perspectives))


(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-set-navigator t))

(use-package recentf
  :config
  (setq
   recentf-max-saved-items 10000
   recentf-max-menu-items 5000
   )
  (recentf-mode 1)
  (run-at-time nil (* 5 60) 'recentf-save-list)
  )

;; -------- other config --------
;; set scroll style
(setq scroll-conservatively 101)
(electric-pair-mode 1)
(menu-bar-mode -1)
(show-paren-mode 1)
(tool-bar-mode -1)
(winum-mode 1)
(xclip-mode 1)
(set-terminal-coding-system 'utf-8)
(modify-coding-system-alist 'process "*" 'utf-8)
(setq default-process-coding-system '(utf-8 . utf-8))
(global-set-key (kbd "<escape><escape><escape>") 'keyboard-escape-quit)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("4a201d19d8f7864e930fbb67e5c2029b558d26a658be1313b19b8958fe451b55" default))
 '(delete-selection-mode nil)
 '(display-line-numbers 'relative)
 '(helm-minibuffer-history-key "M-p")
 '(inhibit-startup-buffer-menu t)
 '(inhibit-startup-screen t)
 '(package-selected-packages
   '(subatomic256-theme xclip winum which-key use-package undo-fu treemacs-projectile treemacs-persp treemacs-magit treemacs-icons-dired treemacs-evil tree-sitter sublime-themes srcery-theme spacemacs-theme rust-mode rainbow-delimiters monokai-theme monokai-pro-theme moe-theme lsp-ui lsp-treemacs lsp-julia leuven-theme helm-themes helm-rg helm-projectile helm-lsp helm-ag gruvbox-theme gruber-darker-theme git-gutter general format-all flycheck evil-surround evil-nerd-commenter evil-collection doom-themes doom-modeline dashboard company ample-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:background nil)))))
