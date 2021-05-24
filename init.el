;; Set up package.el to work with MELPA
(require 'package)
(setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
			 ("org" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/org/")))
(package-initialize)
;;(package-refresh-contents)

(unless (package-installed-p 'avy)
  (package-install 'avy))
(unless (package-installed-p 'company)
  (package-install 'company))
(unless (package-installed-p 'dashboard)
  (package-install 'dashboard))
(unless (package-installed-p 'evil)
  (package-install 'evil))
(unless (package-installed-p 'evil-leader)
  (package-install 'evil-leader))
(unless (package-installed-p 'evil-nerd-commenter)
  (package-install 'evil-nerd-commenter))
(unless (package-installed-p 'format-all)
  (package-install 'format-all))
(unless (package-installed-p 'git-gutter)
  (package-install 'git-gutter))
(unless (package-installed-p 'helm)
  (package-install 'helm))
(unless (package-installed-p 'lsp-mode)
  (package-install 'lsp-mode))
(unless (package-installed-p 'lsp-ui)
  (package-install 'lsp-ui))
(unless (package-installed-p 'magit)
  (package-install 'magit))
(unless (package-installed-p 'rainbow-delimiters)
  (package-install 'rainbow-delimiters))
;; Download use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(unless (package-installed-p 'which-key)
  (package-install 'which-key))
(unless (package-installed-p 'winum)
  (package-install 'winum))
(unless (package-installed-p 'xclip)
  (package-install 'xclip))

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (c++-mode . lsp-deferred)
	 (prog-mode . rainbow-delimiters-mode)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-defered))

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
;; if you are helm user
;;(use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user
;;(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
;;(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
					;(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; optional if you want which-key integration
(use-package which-key
  :config
  (which-key-mode))

;; (use-package helm
;;   :ensure t
;;   :hook (after-init . (lambda() (helm-mode 1))))

(use-package projectile
  :ensure t
  :init
  (projectile-mode 1)
  :bind (:map projectile-mode-map
	      ("C-c p" . projectile-command-map)))

(use-package evil-leader
  :config
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "bf" 'format-all-buffer
    "bb" 'ibuffer
    "ci" 'evilnc-comment-or-uncomment-lines
    "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
    "cc" 'evilnc-copy-and-comment-lines
    "cp" 'evilnc-comment-or-uncomment-paragraphs
    "cr" 'comment-or-uncomment-region
    "cv" 'evilnc-toggle-invert-comment-line-by-line
    "tt" 'treemacs
    "td" 'treemacs-display-current-project-exclusively
    "0"  'winum-select-window-0-or-10
    "1"  'winum-select-window-1
    "2"  'winum-select-window-2
    "3"  'winum-select-window-3
    "4"  'winum-select-window-4
    "5"  'winum-select-window-5
    "6"  'winum-select-window-6
    "7"  'winum-select-window-7
    "8"  'winum-select-window-8
    "9"  'winum-select-window-9
    "p"  'projectile-command-map)
  :ensure t
  :hook (after-init . (lambda ()
			(global-evil-leader-mode))))

;; -------- avy --------
(use-package avy
  :config
  (define-key evil-normal-state-map (kbd "s") 'avy-goto-char-2))

;; -------- evil nerd commenter --------
(evilnc-default-hotkeys)

;; -------- git gutter --------
(global-git-gutter-mode t)

;; set scroll style
(setq scroll-conservatively 101)
;; dashboard startup
(dashboard-setup-startup-hook)
(global-company-mode 1)
(menu-bar-mode -1)
(show-paren-mode 1)
(tool-bar-mode -1)
(winum-mode 1)
(xclip-mode 1)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(display-line-numbers 'relative)
 '(helm-minibuffer-history-key "M-p")
 '(package-selected-packages
   '(avy xclip winum which-key use-package rainbow-delimiters projectile magit lsp-ui helm format-all evil-surround evil-nerd-commenter evil-leader evil-collection dashboard company)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
