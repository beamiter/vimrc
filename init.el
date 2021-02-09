(require 'package)
(setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
                         ("org"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/org//u")))
(package-initialize)

(defvar my/packages '(
                      all-the-icons
                      evil-leader
                      company
                      dap-mode
                      dashboard
                      evil
                      flycheck
                      ;helm-lsp
                      helm
                      ivy
                      ;lsp-ivy
                      lsp-pyright
                      lsp-python-ms
                      rust-mode
                      lsp-mode
                      lsp-treemacs
                      lsp-ui
                      magit
                      monokai-theme
                      project
                      projectile
                      undo-fu
                      undo-tree
                      use-package
                      which-key
                      ))
(setq package-selected-packages my/packages)
;(add-to-list 'my/packages 'monokai-theme)

;(defun my/packages-installed-p ()
  ;(cl-loop for pkg in my/packages
           ;when (not (package-installed-p pkg)) do (cl-return nil)
           ;finally (cl-return t)))
(defun my/packages-installed-p ()
  (cl-every 'package-installed-p my/packages))

(unless (my/packages-installed-p)
  (message "%s" "refreshing package database...")
  (package-refresh-contents)
  (dolist (pkg my/packages)
    (when (not (package-installed-p pkg))
      (package-install pkg))))

;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------


;; -------- startup --------
;(dashboard-setup-startup-hook)

;; -------- key binding --------
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")
(evil-mode 1)
(projectile-mode 1)
(which-key-setup-minibuffer)
(which-key-mode)

;; -------- key mapping --------
;; Allow C-h to trigger which-key before it is done automatically
(setq which-key-show-early-on-C-h t)
(setq which-key-idle-delay 1)
(define-key projectile-mode-map (kbd "C-c p") `projectile-command-map)
(evil-leader/set-key
  "ff" 'find-file
  "bb" 'switch-to-buffer
  "bk" 'kill-buffer
  "p"  'projectile-command-map)

;; -------- normal default --------
(setq make-backup-files nil)
(tool-bar-mode -1)
(menu-bar-mode -1)
;(scroll-bar-mode -1)
(electric-pair-mode 1)
(helm-mode 1)
(setq lsp-enable-file-watchers nil)
(setq lsp-rust-sysroot 1)

;; -------- themes --------
(load-theme 'monokai 1)

;; -------- ui --------
(setq lsp-ui-doc-enable nil)

;; -------- lsp --------
(global-company-mode 1)
(add-hook 'c++-mode-hook #'lsp-deferred)
;(add-hook 'rust-mode-hook #'lsp-deferred)
(use-package rust-mode
  :ensure t
  :hook (rust-mode . (lambda ()
                       (require 'rust-mode)
                       (lsp))))
;(require 'lsp-pyright)
;(add-hook 'python-mode-hook #'lsp-deferred)
(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred

;(require 'lsp-python-ms)
;(setq lsp-python-ms-auto-install-server t)
;(add-hook 'python-mode-hook #'lsp) ; or lsp-deferred
;(use-package lsp-python-ms
  ;:ensure t
  ;:init (setq lsp-python-ms-auto-install-server t)
  ;:hook (python-mode . (lambda ()
                          ;(require 'lsp-python-ms)
                          ;(lsp))))  ; or lsp-deferred

;(add-hook 'before-save-hook (lambda () (when (eq 'rust-mode major-mode)
                                           ;(lsp-format-buffer))))


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(display-line-numbers (quote relative))
 '(inhibit-startup-screen t)
 '(lsp-ui-sideline-actions-icon nil)
 '(package-selected-packages (quote (lsp-mode monokai-theme company))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
