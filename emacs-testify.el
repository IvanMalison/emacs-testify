(defvar testify-project-file ".git" "The file that defines the project root")
(defvar testify-project-root nil)
(defvar testify-sandbox-directory nil)

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
    (match-string 1 nil)))

(defun testify-get-case-name ()
  (save-excursion
    (re-search-backward "^class \\(.*?\\)(")
    (match-string 1 nil)))

(defun testify-run (module &optional case_info)
  (compile (concat "cd " (testify-project-root)
                   (testify-sandbox-command) " && " "testify " module " " (or case_info ""))))

(defun testify-get-id-from-pgconf-dir (directory-name)
  (string-match "pgconf-\\(.*?\\)-\\(.*\\)/" directory-name)
  `(,(match-string 2 directory-name) . ,directory-name))

(defun testify-get-pgconf-names ()
  (mapcar 'testify-get-id-from-pgconf-dir
          (split-string (shell-command-to-string
                         (concat "ls -a " (testify-project-root) " | grep .pgconf")))))

(defun testify-sandbox-command ()
  (cond 
   (testify-sandbox-directory
    (concat " && source " testify-sandbox-directory "/" "environment.sh ;" "source " testify-sandbox-directory "/" "environ.sh "))
   ((not (string-match (testify-project-root) "yelp-main")) "")
   (t (progn
        (testify-set-sandbox)
        (testify-sandbox-command)))))

(defun testify-set-sandbox ()
  (interactive)
  (let* ((sandbox-ids-to-files (testify-get-pgconf-names))
         (sandbox-ids (delq nil (mapcar 'car sandbox-ids-to-files)))
         (selection (if (and (boundp 'ido-mode) ido-mode)
                        (ido-completing-read "Select a sandbox: " sandbox-ids)
                      (completing-read "Find file in project: " sandbox-ids))))
    (setq testify-sandbox-directory (cdr (assoc selection sandbox-ids-to-files)))))

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

