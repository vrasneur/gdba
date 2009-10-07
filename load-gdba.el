;;; gdb/gud stuff

(require 'gdb-ui)

;; no call to gdb-setup-windows!
(setq gdb-many-windows nil)

;; I don't like the gdb "many-windows" layout, so here is my own
;; +--------------------------+
;; |       source code        |
;; +--------------+-----------+
;; |  disassembly | registers |
;; +--------------+-----------+
;; |   gdb shell  |  locals   |
;; +--------------+-----------+
;; | stack frames |  breakpts |
;; +--------------+-----------+
(defun gdba-make-custom-gdb-layout ()
  (interactive)
  ;; all the buffers I want
  (gdb-display-assembler-buffer)
  (delete-other-windows)
  (gdb-display-registers-buffer)
  (gdb-display-locals-buffer)
  (delete-other-windows)
  (gdb-display-breakpoints-buffer)
  (gdb-display-stack-buffer)
  (delete-other-windows)
  ;; make the layout and set the windows/buffers accordingly
  (split-window nil (/ (* (window-height) 3) 4))
  (split-window nil (/ (* (window-height) 2) 3))
  (split-window nil (/ (window-height) 2))
  (switch-to-buffer
       (if gud-last-last-frame
	   (gud-find-file (car gud-last-last-frame))
	 (if gdb-main-file
	     (gud-find-file gdb-main-file)
	   ;; Put buffer list in window if we
	   ;; can't find a source file.
	   (list-buffers-noselect))))
  (setq gdb-source-window (selected-window))
  (other-window 1)
  (gdb-set-window-buffer (gdb-assembler-buffer-name))
  (split-window-horizontally (/ (* (window-width) 3) 4))
  (other-window 1)
  (gdb-set-window-buffer (gdb-registers-buffer-name))
  (other-window 1)
  (split-window-horizontally (/ (* (window-width) 2) 3))
  (other-window 1)
  (gdb-set-window-buffer (gdb-locals-buffer-name))
  (other-window 1)
  (split-window-horizontally (/ (window-width) 2))
  (gdb-set-window-buffer (gdb-stack-buffer-name))
  (other-window 1)
  (gdb-set-window-buffer (gdb-breakpoints-buffer-name))
  (select-window (get-buffer-window gud-comint-buffer)))

(defun gdba-delete-gdb-assembler-windows ()
  (interactive)
  (flet ((delete-gdb-window (gdb-key)
               (let* ((buffer (gdb-get-buffer gdb-key))
                      (window (and buffer (get-buffer-window buffer))))
                 (when window (delete-window window)))))
    (delete-gdb-window 'gdb-assembler-buffer)
    (delete-gdb-window 'gdb-registers-buffer)))

;; gdba launcher
(defun load-gdba (filenames)
  (interactive "sGDB filenames? ")
  (gdb (concat "gdb --annotate=3 " filenames))
  (gdba-make-custom-gdb-layout))
