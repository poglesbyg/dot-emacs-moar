;; Turn off mouse interface early in startup to avoid momentary
;; display
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; No splash screen please ... jeez
(setq inhibit-startup-message t)

(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("tromey" . "http://tromey.com/elpa/") t)
(add-to-list 'package-archives
             '("MELPA" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

;; The packages you want installed. You can also install these
;; manually with M-x package-install
;; Add in your own as you wish:
(defvar my-packages
  '(;; makes handling lisp expressions much, much easier
    ;; Cheatsheet: http://www.emacswiki.org/emacs/PareditCheatsheet
    paredit
    autopair
    ;; integration with a Clojure REPL
    ;; https://github.com/clojure-emacs/cider
    cider

    ;; allow ido usage in as many contexts as possible. see
    ;; customizations/better-defaults.el line 47 for a description
    ;; of ido
    ido-ubiquitous

    ;; Enhances M-x to allow easier execution of commands. Provides
    ;; a filterable list of possible commands in the minibuffer
    ;; http://www.emacswiki.org/emacs/Smex
    smex

    ;; On OS X, an Emacs instance started from the graphical user
    ;; interface will have a different environment than a shell in a
    ;; terminal window, because OS X does not run a shell during the
    ;; login. Obviously this will lead to unexpected results when
    ;; calling external utilities like make from Emacs.
    ;; This library works around this problem by copying important
    ;; environment variables from the user's shell.
    ;; https://github.com/purcell/exec-path-from-shell
    exec-path-from-shell

    ;; project navigation
    projectile

    ;; colorful parenthesis matching
    rainbow-delimiters

    ;; edit html tags like sexps
    tagedit

    ;; git integration
    magit

    ;; hy-mode
    hy-mode

    ;; scala-mode
    scala-mode2))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; prolog mode
(require 'ediprolog)
(global-set-key [f10] 'run-prolog)
(setq auto-mode-alist
      (cons (cons "\\.pl" 'prolog-mode)
            auto-mode-alist))

;; Are we on a mac?
(setq is-mac (equal system-type 'darwin))

;; elisp files to make things clear
(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'better-defaults)

;; ruby on rails
(setq auto-mode-alist
      (cons (cons "\\.rb" 'ruby-mode)
            auto-mode-alist))
(add-to-list 'load-path "~/.emacs.d/emacs-rails-reloaded")
(require 'rails-autoload)

;; Themes
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(add-to-list 'load-path "~/.emacs.d/themes")
;; Uncomment this to increase font size
(set-face-attribute 'default nil :height 140)
(load-theme 'tomorrow-night-bright t)

;; clojure and lisp
(unless (package-installed-p 'cider)
  (package-install 'cider))
;; clojure
(add-to-list 'auto-mode-alist '("\\.edn$" . clojure-mode))
(unless (package-installed-p 'clojure-mode)
  (package-refresh-contents)
  (package-install 'clojure-mode))

;; cider
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
(setq cider-repl-pop-to-buffer-on-connect t)
(setq cider-popup-stacktraces t)
(setq cider-repl-popup-stacktraces t)
(setq cider-auto-select-error-buffer t)
(setq cider-repl-history-file "~/.emacs.d/cider-history")
(setq cider-repl-wrap-history t)

(add-hook 'cider-repl-mode-hook 'subword-mode)
(add-hook 'cider-repl-mode-hook 'paredit-mode)
(add-hook 'cider-repl-mode-hook 'rainbow-delimiters-mode)

(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)
(add-hook 'prolog-mode-hook           #'enable-paredit-mode)

;; Enable paredit for Clojure
(add-hook 'clojure-mode-hook 'enable-paredit-mode)

(require 'autopair)

  (defvar autopair-modes '(r-mode ruby-mode))
  (defun turn-on-autopair-mode () (autopair-mode 1))
  (dolist (mode autopair-modes) (add-hook (intern (concat (symbol-name mode) "-hook")) 'turn-on-autopair-mode))

  (require 'paredit)
  (defadvice paredit-mode (around disable-autopairs-around (arg))
    "Disable autopairs mode if paredit-mode is turned on"
    ad-do-it
    (if (null ad-return-value)
        (autopair-mode 1)
      (autopair-mode 0)
      ))

  (ad-activate 'paredit-mode)

;; This is useful for working with camel-case tokens, like names of
;; Java classes (e.g. JavaClassName)
(add-hook 'clojure-mode-hook 'subword-mode)

;; eldoc-mode shows documentation in the minibuffer when writing code
;; http://www.emacswiki.org/emacs/ElDoc
(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)

(autoload 'rust-mode "rust-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(setq visible-bell t
      font-lock-maximum-decoration t
      color-theme-is-global t
      truncate-partial-width-windows nil)

;; Highlight current line
(global-hl-line-mode 1)

(require 'key-bindings)

;; Seed the random-number generator
(random t)

;; Keep region when undoing in region
(defadvice undo-tree-undo (around keep-region activate)
  (if (use-region-p)
      (let ((m (set-marker (make-marker) (mark)))
            (p (set-marker (make-marker) (point))))
        ad-do-it
        (goto-char p)
        (set-mark m)
        (set-marker p nil)
        (set-marker m nil))
    ad-do-it))

;; Whitespace-style
(setq whitespace-style '(trailing lines space-before-tab
                                  indentation space-after-tab)
      whitespace-line-column 100)

;; Add Urban Dictionary to webjump (C-x g)
(eval-after-load "webjump"
  '(add-to-list 'webjump-sites '("Urban Dictionary" .
                                 [simple-query
                                  "www.urbandictionary.com"
                                  "http://www.urbandictionary.com/define.php?term="
                                  ""])))

;; Fix whitespace on save, but only if the file was clean
(global-whitespace-cleanup-mode)

;; Use normal tabs in makefiles
(add-hook 'makefile-mode-hook 'indent-tabs-mode)

;; A bit of misc cargo culting in misc.el
(setq xterm-mouse-mode t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ediprolog-program "/usr/local/bin/swipl")
 '(ediprolog-program-switches nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; Hy
(add-to-list 'load-path "~/.emacs.d/hy-mode")
(require 'hy-mode)
(add-to-list 'auto-mode-alist '("\\.hy\\'" . hy-mode))

;; Scala
(add-to-list 'load-path "~/.emacs.d/scala-mode")
(require 'scala-mode)
(add-to-list 'auto-mode-alist '("\\.scala\\'" . scala-mode))
(require 'scala-mode-auto)
(add-to-list 'auto-mode-alist '("~/.emacs.d/ensime") )
(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)
