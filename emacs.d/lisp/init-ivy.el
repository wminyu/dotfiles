;;; init-ivy.el --- Initialize ivy configurations.	-*- lexical-binding: t -*-

;; Copyright (C) 2015-2019 lin.jiang

;; Author: lin.jiang <mail@honmaple.com>
;; URL: https://github.com/honmaple/dotfiles/tree/master/emacs.d

;; This file is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this file.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Ivy configurations.
;;

;;; Code:

(eval-when-compile (require 'init-basic))

;; 必须的,使用频率排序
(use-package smex
  :config
  (setq smex-save-file (concat maple-cache-directory "smex-items")))

(use-package wgrep
  :config
  (setq wgrep-auto-save-buffer t)
  :bind (:map wgrep-mode-map
              ("C-c C-c" . wgrep-finish-edit)))

(use-package ivy
  :diminish (ivy-mode)
  :hook (maple-init . ivy-mode)
  :defines
  (magit-completing-read-function
   projectile-completion-system)
  :config
  (setq enable-recursive-minibuffers t
        completing-read-function 'ivy-completing-read)

  (setq ivy-use-selectable-prompt t
        ivy-wrap t
        ivy-extra-directories nil
        ivy-fixed-height-minibuffer t
        ;; Don't use ^ as initial input
        ivy-initial-inputs-alist nil
        ;; disable magic slash on non-match
        ;; ~ to /home/user
        ivy-magic-tilde t
        ivy-use-virtual-buffers nil
        ivy-virtual-abbreviate 'full
        ;; ivy display
        ivy-count-format ""
        ivy-format-function 'maple/ivy-format-function
        ;; fuzzy match
        ivy-re-builders-alist
        '((counsel-ag . ivy--regex-plus)
          (t . ivy--regex-ignore-order)))

  ;; custom ivy display function
  (advice-add 'ivy-read :around #'maple/ivy-read-around)

  (defvar maple/ivy-format-padding nil)

  (defun maple/ivy-read-around (-ivy-read &rest args)
    "Advice ivy-read `-IVY-READ` `ARGS`."
    (let ((maple/ivy-format-padding (make-string (window-left-column) ?\s)))
      (setcar args (concat maple/ivy-format-padding (car args)))
      (apply -ivy-read args)))

  (defun maple/ivy-format-function (cands)
    "Transform CANDS into a string for minibuffer."
    (ivy--format-function-generic
     (lambda (str)
       (concat maple/ivy-format-padding (ivy--add-face str 'ivy-current-match)))
     (lambda (str)
       (concat maple/ivy-format-padding str))
     cands "\n"))

  ;; complete or done
  (defun maple/ivy-done()
    (interactive)
    (let ((dir ivy--directory))
      (ivy-partial-or-done)
      (when (string= dir ivy--directory)
        (ivy-insert-current)
        (when (and (eq (ivy-state-collection ivy-last) #'read-file-name-internal)
                   (setq dir (ivy-expand-file-if-directory (ivy-state-current ivy-last))))
          (ivy--cd dir)
          (setq this-command 'ivy-cd)))))

  (defun maple/ivy-backward-delete-char ()
    (interactive)
    (let ((dir ivy--directory)
          (p (and ivy--directory (= (minibuffer-prompt-end) (point)))))
      (ivy-backward-delete-char)
      (when p (insert (file-name-nondirectory (directory-file-name dir))))))

  (defun maple/ivy-c-h ()
    (interactive)
    (if (eq (ivy-state-collection ivy-last) #'read-file-name-internal)
        (if (string-equal (ivy--input) "")
            (counsel-up-directory)
          (delete-minibuffer-contents))
      (ivy-backward-delete-char)))

  ;; ivy-occur custom
  (defun maple/ivy-edit ()
    "Edit the current search results in a buffer using wgrep."
    (interactive)
    (run-with-idle-timer 0 nil 'ivy-wgrep-change-to-wgrep-mode)
    (ivy-occur))

  (defun maple/ivy-search-at-point (func)
    (let ((ivy-initial-inputs-alist (list (cons func (maple/region-string)))))
      (funcall func)))

  ;; custom find-file
  (defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
    "Create parent directory if not exists while visiting file."
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (if (y-or-n-p (format "Directory %s does not exist,do you want you create it? " dir))
            (make-directory dir)
          (keyboard-quit)))))

  ;; completion-system
  (with-eval-after-load 'evil
    (evil-set-initial-state 'ivy-occur-grep-mode 'normal)
    (evil-make-overriding-map ivy-occur-mode-map 'normal))

  (with-eval-after-load 'projectile
    (setq projectile-completion-system 'ivy))

  (with-eval-after-load 'magit
    (setq magit-completing-read-function 'ivy-completing-read))

  (use-package ivy-rich
    :hook (ivy-mode . ivy-rich-mode)
    :config
    (setq ivy-rich-path-style 'abbrev
          ivy-rich-switch-buffer-align-virtual-buffer t))

  (use-package ivy-xref
    :init
    (setq xref-show-xrefs-function #'ivy-xref-show-xrefs))

  :custom-face
  (ivy-highlight-face ((t (:background nil)))))

(use-package counsel
  :diminish (counsel-mode)
  :hook (ivy-mode . counsel-mode)
  :config
  (setq counsel-preselect-current-file t
        counsel-more-chars-alist '((t . 1)))

  (setq counsel-find-file-ignore-regexp "\\.\\(pyc\\|pyo\\)\\'")

  (defun maple/counsel-ag-directory()
    (interactive)
    (counsel-ag nil (read-directory-name "Search in directory: ")))

  ;; custom counsel-ag
  (defun maple/counsel-ag(-counsel-ag &optional initial-input initial-directory extra-ag-args ag-prompt)
    (funcall -counsel-ag
             (or initial-input (maple/region-string))
             (or initial-directory default-directory)
             extra-ag-args
             ag-prompt))

  (advice-add 'counsel-ag :around #'maple/counsel-ag)

  (use-package counsel-projectile
    :preface (setq projectile-keymap-prefix (kbd "C-c p")))

  :bind (("M-x" . counsel-M-x)
         ("C-x C-m" . counsel-M-x)
         ("M-y" . counsel-yank-pop)
         :map ivy-minibuffer-map
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         ("<tab>" . maple/ivy-done)
         ("TAB" . maple/ivy-done)
         ("C-c C-e" . maple/ivy-edit)
         ("C-h" . maple/ivy-c-h)
         ([escape] . minibuffer-keyboard-quit)
         ([backspace] . maple/ivy-backward-delete-char)
         :map counsel-find-file-map
         ([backspace] . maple/ivy-backward-delete-char)
         ("<tab>" . maple/ivy-done)
         ("TAB" . maple/ivy-done)
         ("C-<return>" . ivy-immediate-done)
         :map counsel-ag-map
         ("<tab>" . ivy-call)))

(use-package swiper
  :config
  (defun maple/swiper()
    (interactive)
    (maple/ivy-search-at-point 'swiper)))

(provide 'init-ivy)
;;; init-ivy.el ends here
