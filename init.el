(require 'package)
(setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
                         ("org"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/org//u")))
(package-initialize)

(defvar my/packages '(
                      ag
                      all-the-icons
                      avy
                      eglot
                      evil-easymotion
                      evil-leader
                      clang-format
                      company
                      company-lsp
                      dap-mode
                      dashboard
                      doom-themes
                      doom-modeline
                      evil
                      evil-collection
                      evil-nerd-commenter
                      flycheck
                      format-all
                      git-gutter
                      ;helm-lsp
                      helm
                      highlight-indent-guides
                      highlight-indentation
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
                      neotree
                      projectile
                      rainbow-delimiters
                      ripgrep
                      undo-fu
                      undo-tree
                      use-package
                      vimrc-mode
                      which-key
                      winum
                      xclip
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


;; -------- normal default --------
(setq evil-want-keybinding nil)
(setq make-backup-files nil)
(setq neo-window-width 50)
(setq scroll-conservatively 101)
;; set frame transparency
(set-frame-parameter nil 'alpha '(95 . 100))
(show-paren-mode 1)
(electric-pair-mode 1)
(menu-bar-mode -1)
;(scroll-bar-mode -1)
(tool-bar-mode -1)
(xclip-mode 1)
(xterm-mouse-mode t)

;; -------- startup --------
(dashboard-setup-startup-hook)

;; -------- key binding --------
(use-package evil-leader
  :config
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "af" 'format-all-buffer
    "bb" 'ibuffer
    "ci" 'evilnc-comment-or-uncomment-lines
    "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
    "ll" 'evilnc-quick-comment-or-uncomment-to-the-line
    "cc" 'evilnc-copy-and-comment-lines
    "cp" 'evilnc-comment-or-uncomment-paragraphs
    "cr" 'comment-or-uncomment-region
    "cv" 'evilnc-toggle-invert-comment-line-by-line
    "."  'evilnc-copy-and-comment-operator
    "\\" 'evilnc-comment-operator ; if you prefer backslash key
    "tt" 'treemacs
    "td" 'treemacs-display-current-project-exclusively
    "ws" 'evil-window-split
    "wv" 'evil-window-vsplit
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
                        (global-evil-leader-mode)
                        (evil-mode 1))))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;; winum
(setq winum-keymap
    (let ((map (make-sparse-keymap)))
      (define-key map (kbd "C-`") 'winum-select-window-by-number)
      (define-key map (kbd "M-0") 'winum-select-window-0-or-10)
      (define-key map (kbd "M-1") 'winum-select-window-1)
      (define-key map (kbd "M-2") 'winum-select-window-2)
      (define-key map (kbd "M-3") 'winum-select-window-3)
      (define-key map (kbd "M-4") 'winum-select-window-4)
      (define-key map (kbd "M-5") 'winum-select-window-5)
      (define-key map (kbd "M-6") 'winum-select-window-6)
      (define-key map (kbd "M-7") 'winum-select-window-7)
      (define-key map (kbd "M-8") 'winum-select-window-8)
      map))
(use-package winum)
(winum-mode)

;; global-set-key
(global-set-key (kbd "C-x C-b") 'ibuffer)
;(global-set-key [f3] 'neotree-toggle)
(global-set-key [f3] 'treemacs)

;; evil custome key maps
(define-key evil-normal-state-map (kbd "[c") 'git-gutter:previous-hunk)
(define-key evil-normal-state-map (kbd "]c") 'git-gutter:next-hunk)

;; customize the company select short cut
(with-eval-after-load "company"
  (define-key company-active-map (kbd "C-p") #'company-select-previous-or-abort)
  (define-key company-active-map (kbd "C-k") #'company-select-previous-or-abort)
  (define-key company-active-map (kbd "C-n") #'company-select-next-or-abort)
  (define-key company-active-map (kbd "C-j") #'company-select-next-or-abort))

(use-package projectile
  :config
  (define-key projectile-mode-map (kbd "C-c p") `projectile-command-map)
  :ensure t
  :hook (after-init . projectile-mode))

(use-package highlight-indent-guides
  :config
  (setq highlight-indent-guides-method 'character)
  ;(setq highlight-indent-guides-method 'column)
  (setq highlight-indent-guides-auto-enabled nil)
  (set-face-background 'highlight-indent-guides-odd-face "darkgray")
  (set-face-background 'highlight-indent-guides-even-face "dimgray")
  (set-face-foreground 'highlight-indent-guides-character-face "dimgray")
  :hook (prog-mode . highlight-indent-guides-mode))

(use-package helm
  :ensure t
  :hook (after-init . (lambda() (helm-mode 1))))

(use-package lsp-mode
  :config
  (setq lsp-enable-file-watchers nil)
  (setq lsp-rust-sysroot 1)
  :ensure t)

;; -------- themes --------
;(load-theme 'monokai 1)
(use-package all-the-icons)

(use-package doom-modeline
  :ensure t

  :config
  ;; How tall the mode-line should be. It's only respected in GUI.
  ;; If the actual char height is larger, it respects the actual height.
  (setq doom-modeline-height 25)
  ;; How wide the mode-line bar should be. It's only respected in GUI.
  (setq doom-modeline-bar-width 3)
  ;; The limit of the window width.
  ;; If `window-width' is smaller than the limit, some information won't be displayed.
  (setq doom-modeline-window-width-limit fill-column)
  ;; How to detect the project root.
  ;; The default priority of detection is `ffip' > `projectile' > `project'.
  ;; nil means to use `default-directory'.
  ;; The project management packages have some issues on detecting project root.
  ;; e.g. `projectile' doesn't handle symlink folders well, while `project' is unable
  ;; to hanle sub-projects.
  ;; You can specify one if you encounter the issue.
  ;(setq doom-modeline-project-detection 'project)
  (setq doom-modeline-buffer-file-name-style 'auto)
  ;; Whether display icons in the mode-line.
  ;; While using the server mode in GUI, should set the value explicitly.
  (setq doom-modeline-icon (display-graphic-p))
  ;; Whether display the icon for `major-mode'. It respects `doom-modeline-icon'.
  (setq doom-modeline-major-mode-icon t)
  ;; Whether display the colorful icon for `major-mode'.
  ;; It respects `all-the-icons-color-icons'.
  (setq doom-modeline-major-mode-color-icon t)
  ;; Whether display the icon for the buffer state. It respects `doom-modeline-icon'.
  (setq doom-modeline-buffer-state-icon t)
  ;; Whether display the modification icon for the buffer.
  ;; It respects `doom-modeline-icon' and `doom-modeline-buffer-state-icon'.
  (setq doom-modeline-buffer-modification-icon t)
  ;; Whether to use unicode as a fallback (instead of ASCII) when not using icons.
  (setq doom-modeline-unicode-fallback nil)
  ;; Whether display the minor modes in the mode-line.
  (setq doom-modeline-minor-modes nil)
  ;; If non-nil, a word count will be added to the selection-info modeline segment.
  (setq doom-modeline-enable-word-count nil)
  ;; Major modes in which to display word count continuously.
  ;; Also applies to any derived modes. Respects `doom-modeline-enable-word-count'.
  ;; If it brings the sluggish issue, disable `doom-modeline-enable-word-count' or
  ;; remove the modes from `doom-modeline-continuous-word-count-modes'.
  (setq doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode))
  ;; Whether display the buffer encoding.
  (setq doom-modeline-buffer-encoding t)
  ;; Whether display the indentation information.
  (setq doom-modeline-indent-info nil)
  ;; If non-nil, only display one number for checker information if applicable.
  (setq doom-modeline-checker-simple-format t)
  ;; The maximum number displayed for notifications.
  (setq doom-modeline-number-limit 99)
  ;; The maximum displayed length of the branch name of version control.
  (setq doom-modeline-vcs-max-length 12)
  ;; Whether display the workspace name. Non-nil to display in the mode-line.
  (setq doom-modeline-workspace-name t)
  ;; Whether display the perspective name. Non-nil to display in the mode-line.
  (setq doom-modeline-persp-name t)
  ;; If non nil the default perspective name is displayed in the mode-line.
  (setq doom-modeline-display-default-persp-name nil)
  ;; If non nil the perspective name is displayed alongside a folder icon.
  (setq doom-modeline-persp-icon t)
  ;; Whether display the `lsp' state. Non-nil to display in the mode-line.
  (setq doom-modeline-lsp t)
  ;; Whether display the GitHub notifications. It requires `ghub' package.
  (setq doom-modeline-github nil)
  ;; The interval of checking GitHub.
  (setq doom-modeline-github-interval (* 30 60))
  ;; Whether display the modal state icon.
  ;; Including `evil', `overwrite', `god', `ryo' and `xah-fly-keys', etc.
  (setq doom-modeline-modal-icon t)
  ;; Whether display the mu4e notifications. It requires `mu4e-alert' package.
  (setq doom-modeline-mu4e nil)
  ;; Whether display the gnus notifications.
  (setq doom-modeline-gnus t)
  ;; Wheter gnus should automatically be updated and how often (set to 0 or smaller than 0 to disable)
  (setq doom-modeline-gnus-timer 2)
  ;; Wheter groups should be excludede when gnus automatically being updated.
  (setq doom-modeline-gnus-excluded-groups '("dummy.group"))
  ;; Whether display the IRC notifications. It requires `circe' or `erc' package.
  (setq doom-modeline-irc t)
  ;; Function to stylize the irc buffer names.
  (setq doom-modeline-irc-stylize 'identity)
  ;; Whether display the environment version.
  (setq doom-modeline-env-version t)
  ;; Or for individual languages
  (setq doom-modeline-env-enable-python t)
  (setq doom-modeline-env-enable-ruby t)
  (setq doom-modeline-env-enable-perl t)
  (setq doom-modeline-env-enable-go t)
  (setq doom-modeline-env-enable-elixir t)
  (setq doom-modeline-env-enable-rust t)
  ;; Change the executables to use for the language version string
  (setq doom-modeline-env-python-executable "python") ; or `python-shell-interpreter'
  (setq doom-modeline-env-ruby-executable "ruby")
  (setq doom-modeline-env-perl-executable "perl")
  (setq doom-modeline-env-go-executable "go")
  (setq doom-modeline-env-elixir-executable "iex")
  (setq doom-modeline-env-rust-executable "rustc")
  ;; What to dispaly as the version while a new one is being loaded
  (setq doom-modeline-env-load-string "...")
  ;; Hooks that run before/after the modeline version string is updated
  (setq doom-modeline-before-update-env-hook nil)
  (setq doom-modeline-after-update-env-hook nil)

  :hook (after-init . doom-modeline-mode))

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-vibrant t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; -------- ui --------
(use-package lsp-ui
  :config
  (setq lsp-ui-doc-enable nil)
  :ensure t)

;; -------- key mapping --------
;; We should put it at the last to avoud bug
;; Allow C-h to trigger which-key before it is done automatically
(use-package which-key
  :config
  (setq which-key-show-early-on-C-h t)
  (setq which-key-idle-delay 1)
  :ensure t
  :hook (after-init . (lambda ()
                        (which-key-setup-minibuffer)
                        (which-key-mode)
                        )))

;; -------- lsp --------
(global-company-mode 1)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(add-hook 'c++-mode-hook #'lsp-deferred)
;(add-hook 'rust-mode-hook #'lsp-deferred)
(use-package rust-mode
  :config
  (setq rust-format-on-save t)
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

;; -------- treemacs config --------
(use-package treemacs
  :ensure t
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
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after treemacs evil
  :ensure t)

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

;;(use-package treemacs-icons-dired
;;  :after treemacs dired
;;  :ensure t
;;  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)

(use-package treemacs-persp ;;treemacs-persective if you use perspective.el vs. persp-mode
  :after treemacs persp-mode ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

;; -------- evil nerd commenter --------
(evilnc-default-hotkeys)

;; -------- git gutter --------
(global-git-gutter-mode t)

; -------- avy --------
(use-package avy
  :config
  (define-key evil-normal-state-map (kbd "s") 'avy-goto-char-2))


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(display-line-numbers (quote relative))
 '(evil-undo-system (quote undo-fu))
 '(helm-minibuffer-history-key "M-p")
 '(inhibit-startup-screen t)
 '(lsp-idle-delay 0.2)
 '(lsp-ui-sideline-actions-icon nil)
 '(package-selected-packages (quote (lsp-mode monokai-theme company)))
 '(treemacs-width 50))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
