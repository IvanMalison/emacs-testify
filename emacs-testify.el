(defvar testify-project-file ".git" "The file that defines the project root")
(defvar testify-project-root nil)

(defun testify-project-root ()
  "Return the root of the project."
  (file-truename (or testify-project-root
                         (locate-dominating-file default-directory
                                                 testify-project-file))))

(defun testify-module-relative-path ()
  (file-relative-name (buffer-file-name) (testify-project-root)))


(defun testify-get-module-dot-path ()
  (replace-regexp-in-string "/" "."
                            (replace-regexp-in-string "\.py" ""
                                                      (testify-module-relative-path))))

(defun testify-get-test-name ()
  (save-excursion
    (re-search-backward "def \\(.*?\\)(")
    (message (match-string 1 nil))))

(defun testify-get-case-name ()
  (save-excursion
    (re-search-backward "class \\(.*?\\)(")
    (message (match-string 1 nil))))

(defun testify-run (module &optional case_info)
  (compile (concat "cd " (testify-project-root)
                   "; " "testify " module " " (or case_info ""))))

(defun testify-run-module ()
  (interactive)
  (testify-run (testify-get-module-dot-path)))

(defun testify-run-case ()
  (interactive)
  (testify-run (testify-get-module-dot-path) (testify-get-case-name)))

(defun testify-run-test ()
  (interactive)
  (testify-run (testify-get-module-dot-path)
               (concat (testify-get-case-name) "." (testify-get-test-name))))

(provide 'emacs-testify)
