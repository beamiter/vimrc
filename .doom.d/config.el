;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Yin Jian"
      user-mail-address "beamiter@163.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; doom-theme fit more for gui
(setq doom-theme 'base16-gruvbox-light-soft)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(set-terminal-coding-system 'utf-8)
(modify-coding-system-alist 'process "*" 'utf-8)
(setq default-process-coding-system '(utf-8 . utf-8))

(setq confirm-kill-emacs nil)

(setq lsp-lens-enable t)
(setq lsp-ui-sideline-enable nil)
(setq lsp-eldoc-enable-hover nil)
(setq lsp-ui-doc-show-with-mouse nil)
(setq lsp-ui-doc-show-with-cursor nil)
(setq lsp-ui-sideline-show-diagnostics nil)

;; Bellow is general configuration for julia.
; (setq lsp-julia-package-dir nil)
; (setq lsp-julia-default-environment "~/.julia/environments/v1.6")
; (setq lsp-enable-folding t)

(setq lsp-julia-package-dir nil)
; (setq lsp-julia-default-environment "~/.julia/environments/v1.6")
; (setq eglot-jl-language-server-project "~/.julia/environments/v1.6")
; (after! eglot-jl
 ; (setq eglot-jl-language-server-project eglot-jl-base))
(after! julia-mode
  (add-hook! 'julia-mode-hook
    (setq-local lsp-enable-folding t
                lsp-folding-range-limit 100)))

;; Example
; (after! evil
 ; (setq evil-magic nil))
; (add_hook! python-mode
 ; (setq python-shell-interpreter "bpython"))
; (set-hook! 'python-mode-hook python-indent-offset 2)
; (set-hook! python-mode python-indent-offset 2)
; (use-package! hl-todo
 ; :hook (prog-mode . hl-todo-mode)
; :init
; :config
; (setq hl-todo-highlight-punctuation ":"))

(use-package! github-theme)
(use-package! xclip)
(use-package! winum
 :config
 (winum-mode 1))

;; define-key, global-set-key, map!, undefine-key!, define-key!
(map! :leader
      :desc "format all buffer" "b f" #'format-all-buffer) ;; 'clang-format-buffer
(map! :leader
      :desc "comment-line" "c m" #'comment-line) ;; 'evilnc-comment-or-uncomment-lines
(map! :leader
      :desc "treemacs toggle" "f t" #'treemacs)
(map! :leader
  "1" 'winum-select-window-1
  "2" 'winum-select-window-2
  "3" 'winum-select-window-3
  "4" 'winum-select-window-4
  "5" 'winum-select-window-5
  "6" 'winum-select-window-6
  "7" 'winum-select-window-7
  "8" 'winum-select-window-8
  "9" 'winum-select-window-9)
(map! (:leader (:desc "treemacs select window" :g "0" #'treemacs-select-window)) )
