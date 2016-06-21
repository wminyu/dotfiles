(require-package 'evil)
(require-package 'evil-surround)
(require-package 'evil-matchit)
(require-package 'evil-escape)
(require-package 'expand-region)
(require-package 'evil-mc)
(require-package 'evil-leader)
(require-package 'neotree)
(require-package 'vimish-fold)

(use-package evil
  :defer t
  :config
  (progn
    (evil-mode 1)
    (fset 'evil-visual-update-x-selection 'ignore) ;;粘贴板
    ;; (defun my-save-if-bufferfilename ()
      ;; (if (buffer-file-name)
      ;;     (progn
      ;;       (save-buffer)
      ;;       )
      ;;   (message "no file is associated to this buffer: do nothing")
      ;;   )
      ;; )
    ;; (add-hook 'focus-out-hook (lambda () (save-some-buffers t)))
    ;; (add-hook 'evil-insert-state-exit-hook 'my-save-if-bufferfilename)
    ))

(use-package evil-surround
  :defer t
  :init (global-evil-surround-mode 1))

(use-package evil-matchit
  :defer t
  :config (global-evil-matchit-mode 1))


(use-package evil-escape
  :defer t
  :init (evil-escape-mode 1)
  :diminish 'evil-escape-mode
  :config
  (progn
    (setq-default evil-escape-key-sequence "jj")
    (setq-default evil-escape-delay 0.3)
    (setq evil-escape-excluded-major-modes '(dired-mode
                                             neotree-mode
                                             magit-mode
                                             newsticker-treeview-mode
                                             newsticker-treeview-list-mode
                                             newsticker-treeview-item-mode))
    (setq evil-escape-inhibit-functions '(evil-visual-state-p evil-escape--is-magit-buffer))
    ))

(use-package evil-mc
  :defer t
  :diminish evil-mc-mode "ⓒ"
  :init (global-evil-mc-mode 1)
  ;; :config
  ;; (progn
  ;;   (dolist (buffer '("*helm-ag-edit*" "*Helm Swoop Edit*"))
  ;;     (when (get-buffer buffer)
  ;;       (with-current-buffer buffer
  ;;         (evil-mc-mode 1)))))
  :bind (:map evil-mc-key-map
              ("C-g" . evil-mc-undo-all-cursors)
              ))

(use-package evil-leader
  :defer t
  :init (global-evil-leader-mode)
  :config (evil-leader/set-leader ","))


(use-package neotree
  :defer t
  :bind ([f2] . neotree-toggle)
  :config
  (progn
    (add-hook 'neotree-mode-hook
              (lambda ()
                (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
                (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter)))
    ))

(use-package vimish-fold
  :defer t
  :init
  (progn
    (define-key evil-visual-state-map (kbd "za") 'vimish-fold)
    (define-key evil-normal-state-map (kbd "zc") 'vimish-fold-delete)
    ))

(use-package expand-region
  :defer t
  :bind (:map evil-visual-state-map
              ("v" . er/expand-region)))

;; (define-key evil-visual-state-map (kbd "za") 'vimish-fold)
;; (define-key evil-normal-state-map (kbd "zc") 'vimish-fold-delete)
(provide 'init-evil)
