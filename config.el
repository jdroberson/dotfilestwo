;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Jesse Roberson"
      user-mail-address "jessedanielroberson@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13)
      doom-big-font (font-spec :family "Fira Code" :size 16 :weight 'semi-light))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-zenburn)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
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
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


(setq default-directory "~/")

(use-package general)

(use-package company
  :custom
  (company-dabbrev-downcase nil)
  (company-dabbrev-ignore-case nil)
  (company-idle-delay 0.2)
  (company-tooltip-align-annotations t)
  :config
  (global-company-mode)
  :general
  (:keymaps
   'company-active-map
   "C-n" 'company-select-next
   "C-N" 'company-select-previous
   "C-p" 'company-select-previous
   "C-f" 'company-filter-candidates))

(use-package company-box
  :config
  (company-box-mode 1))

(use-package flycheck
  :config
  (global-flycheck-mode))

(defun disable-checkdoc ()
  (setq-local flycheck-disabled-checkers '(emacs-lisp-checkdoc)))
(add-hook 'org-src-mode-hook 'disable-checkdoc)

(use-package ivy
  :config
  (ivy-mode 1)
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-display-style 'fancy)
  (ivy-posframe-parameters '((alpha . 80))))

(use-package counsel
  :config
  (counsel-mode 1))

(use-package projectile
  :commands projectile-find-file projectile-switch-project projectile-switch-buffer
  :config
  (projectile-mode +1)
  :custom
  (project-completion-system 'ivy))

;;
;;
;; LSP
;;
;;

(use-package lsp-mode
  :commands lsp lsp-deferred
  :custom
  (read-process-output-max (* 1024 1024))
  :general
  (:states 'normal
   "C-, x" 'lsp-execute-code-action
   "g d" 'lsp-find-definition
   "M-RET" 'lsp-execute-code-action))

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-header t)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-doc-delay 1)
  (lsp-ui-doc-use-childframe t)
  :general
  (:states 'normal
   :prefix "C-,"
   "h" 'lsp-ui-doc-hide
   "d" 'lsp-describe-thing-at-point
   "U" 'lsp-ui-doc-unfocus-frame
   "F" 'lsp-ui-doc-focus-frame
   "u" 'lsp-find-references
   "l" 'flycheck-list-errors
   "n" 'flycheck-next-error
   "p" 'flycheck-previous-error))

(use-package lsp-ivy
  :commands lsp-ivy-workspace-symbol)

;;
;;
;; TS/JS
;;
;;
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (company-mode +1)
  )

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)

;; TSX
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "tsx" (file-name-extension buffer-file-name))
              (setup-tide-mode))))
;; enable typescript-tslint checker
(flycheck-add-mode 'typescript-tslint 'web-mode)

;; JS
(add-hook 'js2-mode-hook #'setup-tide-mode)
;; configure javascript-tide checker to run after your default javascript checker
;; (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)

;; JSX
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "jsx" (file-name-extension buffer-file-name))
              (setup-tide-mode))))
;; configure jsx-tide checker to run after your default jsx checker
(flycheck-add-mode 'javascript-eslint 'web-mode)
;; (flycheck-add-next-checker 'jsx-tide 'append)

(use-package tide
  :ensure t
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save))
  :general
  (:states 'normal
   "g d" 'tide-jump-to-definition
   "g b" 'tide-jump-back
   "C-, u" 'tide-references))

;;
;;
;; Editor Stuff
;;
;;

(use-package all-the-icons)
;; Modeline
(custom-set-variables
 '(doom-modeline-icon (display-graphic-p))
 '(doom-modeline-major-mode-icon t)
 '(doom-modeline-buffer-encoding nil)
 '(doom-modeline-workspace-name nil)
 '(doom-modeline-buffer-file-name-style 'file-name)
 '(doom-modeline-buffer-encoding nil))
