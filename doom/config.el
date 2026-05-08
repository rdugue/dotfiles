;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-nord)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
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
;; remove fringes
(when (not (display-graphic-p))
  (set-fringe-mode 0)
  (setq-default indicate-empty-lines nil))

;; Set the primary coding font
(setq doom-font (font-spec :family "JetBrains Mono Nerd Font" :size 13 :weight 'semi-bold)
      ;; Set the variable pitch font (used for Org-mode headers/text)
      doom-variable-pitch-font (font-spec :family "JetBrains Mono Nerd Font" :size 16))

(setq org-capture-templates
      '(("d" "Daily Checklist" entry
         (file+headline "~/org/daily.org" "Checklist")
         "* TODO %? Daily Routine [/]\nSCHEDULED: %t\n:PROPERTIES:\n:RESET_CHECK_BOXES: t\n:END:\n- [ ] Task 1\n- [ ] Task 2\n- [ ] Task 3"
         :immediate-finish t)))

(use-package! ox-ipynb
  :after org
  :config
  ;; This ensures your code blocks use the right Jupyter kernel during export
  (setq org-babel-default-header-args:jupyter-python
        '((:session . "py")
          (:kernel . "python3"))))

(after! org
  (require 'org-checklist))

(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)      ; Adds standard Python support
     (jupyter . t))))  ; Adds Jupyter-specific support for ox-ipynb

;; 1. Define custom functions to split and instantly open vterm
(defun my/vterm-split-vertical ()
  "Split screen vertically and open a new vterm."
  (interactive)
  (split-window-right)
  (other-window 1)
  (vterm))

(defun my/vterm-split-horizontal ()
  "Split screen horizontally and open a new vterm."
  (interactive)
  (split-window-below)
  (other-window 1)
  (vterm))

;; 2. Map them to single sticky-friendly function keys
(map! :n "<f4>" #'+vterm/here                  ; F4: SPC o T — open vterm in current buffer (not popup)
      :n "<f5>" #'vterm                        ; F5: Open a full-window terminal (not a popup)
      :n "<f6>" #'my/vterm-split-vertical      ; F6: Tmux-style vertical split terminal
      :n "<f7>" #'my/vterm-split-horizontal    ; F7: Tmux-style horizontal split terminal
      :n "<f8>" #'other-window                 ; F8: Cycle cursor between the terminals
      :n "<f9>" #'delete-window)               ; F9: Close the current terminal pane

(defvar my/vterm-broadcast-mode nil
  "Variable to track if vterm broadcast is active.")

(defun my/vterm-broadcast-command (command)
  "Send COMMAND to all buffers in vterm-mode."
  (interactive "sCommand to broadcast: ")
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (derived-mode-p 'vterm-mode)
        (vterm-send-string command)
        (vterm-send-return)))))

;; Bind to F10 for easy, one-touch broadcasting
(map! :n "<f10>" #'my/vterm-broadcast-command)

;; =================================================================
;; =================================================================
;; THE MASTER MATRIX OVERRIDE
;; =================================================================
(defun my-apply-matrix-theme ()
  "Apply the Glass Matrix look across all buffers, icons, and sidebars."
  (let ((m-green "#00FF6A")
        (d-green "#004400")
        (l-green "#66FF99"))

    ;; 1. Force Terminal Transparency
    (unless (display-graphic-p)
      (set-face-background 'default "unspecified-bg")
      (set-face-background 'line-number "unspecified-bg"))

    (custom-set-faces!
      ;; --- Core UI ---
      `(default :background "unspecified-bg" :foreground ,m-green)
      `(line-number :foreground ,d-green :background "unspecified-bg")
      `(line-number-current-line :foreground ,m-green :background "unspecified-bg" :weight bold)
      `(fringe :background "unspecified-bg")

      ;; --- Nerd Icons: Force ALL colors to Matrix Green ---
      `(nerd-icons-green :foreground ,m-green)
      `(nerd-icons-blue :foreground ,m-green)
      `(nerd-icons-blue-alt :foreground ,m-green)
      `(nerd-icons-cyan :foreground ,m-green)
      `(nerd-icons-cyan-alt :foreground ,m-green)
      `(nerd-icons-red :foreground ,m-green)
      `(nerd-icons-red-alt :foreground ,m-green)
      `(nerd-icons-yellow :foreground ,m-green)
      `(nerd-icons-orange :foreground ,m-green)
      `(nerd-icons-purple :foreground ,m-green)
      `(nerd-icons-purple-alt :foreground ,m-green)
      `(nerd-icons-pink :foreground ,m-green)
      `(nerd-icons-silver :foreground ,m-green)
      `(nerd-icons-dsilver :foreground ,m-green)
      `(nerd-icons-l-green :foreground ,m-green)
      `(nerd-icons-d-green :foreground ,m-green)

      ;; --- Treemacs Specifics ---
      `(solaire-default-face :background "unspecified-bg")
      `(solaire-fringe-face :background "unspecified-bg")
      `(treemacs-window-background-face :background "unspecified-bg")
      `(treemacs-hl-line-face :background "#002200")
      `(treemacs-file-face :foreground ,m-green)
      `(treemacs-directory-face :foreground ,m-green :weight bold)
      `(treemacs-git-modified-face :foreground ,l-green)

      ;; --- Org-Mode & Syntax ---
      `(org-level-1 :foreground ,m-green :weight bold :height 1.3)
      `(org-level-2 :foreground ,l-green :weight bold :height 1.1)
      `(font-lock-keyword-face :foreground ,m-green :weight bold)
      `(font-lock-function-name-face :foreground ,m-green)
      `(font-lock-variable-name-face :foreground ,l-green)
      `(font-lock-string-face :foreground ,d-green)
      `(font-lock-comment-face :foreground "#2ECC71" :slant italic)

      ;; --- Dashboard & Vterm ---
      `(doom-dashboard-banner :background "unspecified-bg")
      `(doom-dashboard-menu-title :foreground ,l-green :background "unspecified-bg")
      `(doom-dashboard-menu-desc :foreground ,m-green :background "unspecified-bg")
      `(vterm-color-black :background "unspecified-bg"))))

;; --- Unified Treemacs Setup ---
(after! treemacs
  (setq treemacs-width 25)
  (treemacs-follow-mode 1)
  (treemacs-filewatch-mode 1)

  ;; 1. Load the icon library
  (require 'treemacs-nerd-icons)
  (setq treemacs-no-png-images t)

  ;; 2. Load the theme FIRST
  (treemacs-load-theme "nerd-icons")

  ;; 3. Apply our green overrides LAST so they stick
  (my-apply-matrix-theme))

;; Hooks to keep it green during use
(add-hook 'doom-load-theme-hook #'my-apply-matrix-theme)
(add-hook 'treemacs-mode-hook #'my-apply-matrix-theme)
(add-hook 'vterm-mode-hook #'my-apply-matrix-theme)

;; Run once on startup
(my-apply-matrix-theme)
