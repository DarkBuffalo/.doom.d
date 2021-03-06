(require 'tldr)
(require 'request)
(require 'ov)
(require 'ob-typescript)
(require 'atomic-chrome)

(atomic-chrome-start-server)
(map! :map atomic-chrome-edit-mode-map
      :n "C-x C-s" #'+format/buffer)

(eval-after-load 'cider
  #'emidje-setup)

(setq frame-title-format '("%b – Emacs")
      doom-fallback-buffer-name "*emacs*"
      +doom-dashboard-name "*dashboard*")

(add-to-list '+format-on-save-enabled-modes 'clojure-mode t)
(add-to-list '+format-on-save-enabled-modes 'clojurescript-mode t)
(defun vterm--rename-buffer-as-title (title)
  (rename-buffer (format "vterm: %s" (projectile-project-name)) t))
(add-hook 'vterm-set-title-functions 'vterm--rename-buffer-as-title)

(load! "~/Developer/ts-react-redux-yasnippets/ts-react-redux-yasnippets.el")
(setq counsel-search-engine 'google)
(load! "~/Developer/asx/asx.el")
(load! "~/.doom.d/ra-emacs-lsp.el")
(load! "~/.doom.d/teletype.el")
(load! "~/.doom.d/jac.el")
(set-popup-rules!
  '(("^\\*AskStackExchange" :ignore t :select nil :quit t :size 0.5 :ttl 0)))
(setq browse-url-browser-function 'eww-browse-url)
(setq js-indent-level 2
      web-mode-code-indent-offset 2
      web-mode-css-indent-offset 2
      typescript-indent-level 2)
;;(add-hook 'after-init-hook #'global-emojify-mode)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((typescript . t)))

;; Nov
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
(setq nov-text-width 80)

(map! "C-K"    #'drag-stuff-up
      "C-J"  #'drag-stuff-down
      "C-H"  #'drag-stuff-left
      "C-L" #'drag-stuff-right)

(with-eval-after-load 'gif-screencast
  (setq gif-screencast-args '("-x"))) ;; To shut up the shutter sound of `screencapture' (see `gif-screencast-command').

;;(debug-on-variable-change 'vc-handled-backends)

;; (add-to-list 'tramp-default-proxies-alist
;;              '(nil "\\`root\\'" "/ssh:%h:"))
;; (add-to-list 'tramp-default-proxies-alist
;;              '((regexp-quote (system-name)) nil nil))

;; Fix for PDF-tools on MacOS
(setenv "PKG_CONFIG_PATH" "/usr/local/lib/pkgconfig:/usr/local/Cellar/libffi/3.2.1/lib/pkgconfig")



(defun ragone/fetch-password (&rest params)
  (require 'auth-source)
  (let ((match (car (apply 'auth-source-search params))))
    (if match
        (let ((secret (plist-get match :secret)))
          (if (functionp secret)
              (funcall secret)
            secret))
      (error "Password not found for %S" params))))

(setq treemacs-no-png-images t)

;; (use-package! flycheck-posframe
;;   :after flycheck
;;   :config (add-hook 'flycheck-mode-hook #'flycheck-posframe-mode))

(after! org-agenda
  (map! :map org-agenda-mode-map
        "C-c C-c" 'ragone/agenda-set-category))

(after! calendar
  (map! :map calendar-mode-map
        "e" 'exco-calendar-show-day))

(map!
 "<home>" '+doom-dashboard/open
 :n "f" 'evil-avy-goto-char-timer
 :leader
 :desc "RSS" :n "ar" '=rss
 :desc "IRC" :n "ai" '=irc
 :desc "Passwords" :n "ap" 'pass
 :desc "Notes" :n "ad" 'ragone-deft-or-close
 :desc "Email" :n "ae" '=mu4e
 :desc "Agenda" :n "aa" 'ragone/agenda)

(setq rustic-lsp-server 'rust-analyzer)
(setq lsp-rust-server 'rust-analyzer)
;; (add-hook 'rust-mode-hook 'cargo-minor-mode)
;; (add-to-list 'auto-mode-alist '("\\.ron\\'" . rust-mode))
;; (set-popup-rule! "^\\*Cargo" :ttl 0)

;; (map!
;;   "C-<f5>" #'terminal-here-launch
;;   "C-<f6>" #'terminal-here-project-launch)
;; (setq terminal-here-terminal-command '("termite"))

(map! "<f8>" 'gif-screencast-stop)

(setq ledger-clear-whole-transactions t
      ledger-reconcile-default-commodity "DKK"
      ledger-reports
      '(("account statement" "%(binary) reg --real [[ledger-mode-flags]] -f %(ledger-file) ^%(account)")
        ("balance sheet" "%(binary) --real [[ledger-mode-flags]] -f %(ledger-file) bal ^assets ^liabilities ^equity")
        ("budget" "%(binary) --empty -S -T [[ledger-mode-flags]] -f %(ledger-file) bal ^assets:bank ^assets:receivables ^assets:cash ^assets:budget")
        ("budget goals" "%(binary) --empty -S -T [[ledger-mode-flags]] -f %(ledger-file) bal ^assets:bank ^assets:receivables ^assets:cash ^assets:'budget goals'")
        ("budget obligations" "%(binary) --empty -S -T [[ledger-mode-flags]] -f %(ledger-file) bal ^assets:bank ^assets:receivables ^assets:cash ^assets:'budget obligations'")
        ("budget debts" "%(binary) --empty -S -T [[ledger-mode-flags]] -f %(ledger-file) bal ^assets:bank ^assets:receivables ^assets:cash ^assets:'budget debts'")
        ("cleared" "%(binary) cleared [[ledger-mode-flags]] -f %(ledger-file)")
        ("equity" "%(binary) --real [[ledger-mode-flags]] -f %(ledger-file) equity")
        ("income statement" "%(binary) --invert --real -S -T [[ledger-mode-flags]] -f %(ledger-file) bal ^income ^expenses -p \"this month\""))
      ledger-report-use-header-line nil)

(require 'deft)
(setq deft-directory "~/Dropbox/org"
      deft-recursive t
      deft-current-sort-method 'title
      deft-strip-summary-regexp ".*"
      deft-recursive-ignore-dir-regexp (concat "\\(?:"
                                               "\\."
                                               "\\|\\.\\."
                                               ;; org export dir
                                               "\\|\\.export"
                                               "\\)$")
      deft-use-filename-as-title t
      deft-filter-only-filenames t
      deft-note-mode nil ;Used for tracking the state of deft
      deft-extensions '("org"
                        "md"
                        "tex"
                        "txt"))

;; Replace directory slashes with icons
(defun ragone-parse-title (title)
  (replace-regexp-in-string "\/" (concat " " (all-the-icons-faicon "arrow-right") " ") title))

(advice-add #'deft-parse-title :filter-return #'ragone-parse-title)

(setq dired-listing-switches "-alh"
      dired-k-human-readable t)

(defvar ragone-wttrin-format 0)

(defun wttrin-fetch-raw-string ()
  "Get the weather information based on your QUERY."
  (let ((url-request-extra-headers '(("Accept-Language" . "en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4")
                                     ("User-Agent" . "curl"))))
    (ignore-errors
      (with-current-buffer (url-retrieve-synchronously (format "http://wttr.in/Copenhagen?force-ansi=true&%dFQn" ragone-wttrin-format) t nil 5)
        (goto-char (point-min))
        (re-search-forward "^$")
        (delete-region (point-min) (point))
        (decode-coding-string (buffer-string) 'utf-8)))))

(defun ragone-wttrin-next ()
  (interactive)
  (setq ragone-wttrin-format (mod (+ ragone-wttrin-format 1) 4))
  (+doom-dashboard/open (selected-frame)))

(defun ragone-wttrin-prev ()
  (interactive)
  (setq ragone-wttrin-format (mod (- ragone-wttrin-format 1) 4))
  (+doom-dashboard/open (selected-frame)))

(define-key! +doom-dashboard-mode-map
  [remap evil-backward-char] #'ragone-wttrin-prev
  [remap evil-forward-char] #'ragone-wttrin-next)

(defun wttrin-exit ()
  (interactive)
  (quit-window t))

(defun ragone-dashboard-widget-wttrin ()
  "Query weather of CITY-NAME via wttrin, and display the result in new buffer."
  (let* ((raw-string (or (wttrin-fetch-raw-string) ""))
         (strings (split-string (xterm-color-filter raw-string) "\n"))
         (max-length (max 30 (seq-max (mapcar #'length (seq-take strings 5))))))
    (insert (mapconcat (lambda (s) (ragone-center-format s max-length)) strings "\n"))))

(defun ragone-center-format (s max-length)
  "Center and format S."
  (ragone-center (format (format "%%-%ds" max-length) s)))

(defvar ragone-quotes-file "~/.doom.d/quotes.txt"
  "File to look for quotes")

(defvar ragone-quotes-file-seperator-regex "\n%\n"
  "Delimiter for seperating the line in `ragone-quotes-file'")

(defvar ragone-quotes-author-regex "^--"
  "Regex which indicates the author. Anything after this will be changed to face.")

(defun ragone/get-quote (&optional nth)
  "Get a random quote from `ragone-quotes-file'

Optionally get the NTH quote."
  (let* ((quotes (split-string
                  (with-temp-buffer
                    (insert-file-contents ragone-quotes-file)
                    (buffer-substring-no-properties
                     (point-min)
                     (point-max)))
                  ragone-quotes-file-seperator-regex t))
         (selected-quote (nth (or nth
                                  (random (length quotes)))
                              quotes)))
    (put-text-property (string-match ragone-quotes-author-regex selected-quote)
                       (length selected-quote) 'face 'font-lock-comment-face selected-quote)
    selected-quote))

(defvar ragone-countdown-file "countdown.org"
  "The file to use for the countdowns")

(defun ragone-get-event (headline)
  (let ((timestamp (org-element-property :scheduled headline))
        (title (org-element-property :title headline)))
    (if timestamp
        (let* ((days-to-event (org-time-stamp-to-now
                               (org-timestamp-format timestamp (org-time-stamp-format))))
               (format-string (concat "%s  %-35s %4d " (if (= 1 (abs days-to-event)) "day " "days"))))
          (propertize (+doom-dashboard--center
                       +doom-dashboard--width
                       (format format-string
                               (all-the-icons-faicon "flag" :v-adjust -0.02)
                               title
                               (- days-to-event)))
                      'face 'font-lock-comment-face)))))

(defun ragone/countdowns ()
  (let ((file (expand-file-name ragone-countdown-file org-directory)))
    (with-temp-buffer
      (insert-file-contents file)
      (let ((parsetree (org-element-parse-buffer 'headline)))
        (mapconcat 'identity (org-element-map parsetree 'headline 'ragone-get-event) "\n")))))

(defun ragone-center (s)
  (+doom-dashboard--center +doom-dashboard--width s))

(defun ragone-random-quote ()
  (mapconcat 'identity
             (mapcar 'ragone-center
                     (split-string (ragone/get-quote) "\n"))
             "\n"))

(defun ragone-dashboard-widget-quotes ()
  (insert "\n\n" (ragone-random-quote) "\n"))

(defun ragone-dashboard-widget-countdown ()
  (insert
   "\n"
   (ragone/countdowns)
   "\n"))

(setq +doom-dashboard-banner-padding '(0 . 0)
      +doom-dashboard-menu-sections
      '(("Agenda"
         :icon (all-the-icons-octicon "calendar" :face 'font-lock-keyword-face)
         :when (fboundp 'org-agenda)
         :face (:inherit (font-lock-keyword-face bold))
         :action ragone/agenda)
        ("Email"
         :icon (all-the-icons-octicon "mail" :face 'font-lock-keyword-face)
         :action =mu4e)
        ("RSS"
         :icon (all-the-icons-octicon "rss" :face 'font-lock-keyword-face)
         :action =rss)
        ("Notes"
         :icon (all-the-icons-octicon "light-bulb" :face 'font-lock-keyword-face)
         :action ragone-deft-or-close)
        ("Passwords"
         :icon (all-the-icons-octicon "lock" :face 'font-lock-keyword-face)
         :action pass)
        ("IRC"
         :icon (all-the-icons-faicon "comments" :face 'font-lock-keyword-face)
         :action =irc))
      +doom-dashboard-banner-file "emacs.png"
      +doom-dashboard-banner-dir "~/.doom.d/"
      +doom-dashboard-functions
      '(doom-dashboard-widget-banner
        doom-dashboard-widget-shortmenu
        ragone-dashboard-widget-wttrin
        ragone-dashboard-widget-countdown
        ragone-dashboard-widget-quotes))

(setq +workspaces-on-switch-project-behavior nil)
(set-popup-rules!
  '(("^\\*Warnings" :size 0.2 :ttl 3)))
(after! org
  (set-popup-rules! '(("^CAPTURE.*\\.org$" :size 0.2 :quit nil :select t)
                      ("^\\*Org Src"       :size 0.8 :quit nil :select t :autosave t :ttl nil)
                      ("^\\*Org Agenda" :side right :size 0.5 :select t :ttl nil))))

(add-hook! 'org-agenda-mode-hook
  (org-agenda-filter-apply (push "-personal" org-agenda-category-filter) 'category)
  (set-window-fringes nil nil nil fringes-outside-margins))

;;; Reasonable defaults

(setq shift-select-mode t)
(delete-selection-mode +1)

(require 'expand-region)
(use-package! expand-region
  :commands (er/contract-region er/mark-symbol er/mark-word)
  :config
  (defun doom*quit-expand-region ()
    "Properly abort an expand-region region."
    (when (memq last-command '(er/expand-region er/contract-region))
      (er/contract-region 0)))
  (advice-add #'evil-escape :before #'doom*quit-expand-region)
  (advice-add #'doom/escape :before #'doom*quit-expand-region))
(map! :nv "C-="  #'er/expand-region
      :nv "C--"  #'er/contract-region)

(add-hook! 'elfeed-show-mode-hook
  (setq line-spacing 0)
  (setq-local browse-url-browser-function 'eww-browse-url))

;; (use-package! ox-confluence
;;   :load-path "~/.doom.d/private/ox-confluence.el")

(require 'restclient)
(add-hook 'restclient-mode-hook
          (lambda ()
            (require 'js)
            (setq-local indent-line-function 'js-indent-line)))

(defun ragone/screenshot ()
  (interactive)
  (shell-command "scrot --select"))

(defun ragone/yank-image ()
  "Yank the image at point to the X11 clipboard as image/png."
  (interactive)
  (let ((image (get-text-property (point) 'display)))
    (if (eq (car image) 'image)
        (let ((data (plist-get (cdr image) ':data))
              (file (plist-get (cdr image) ':file)))
          (cond (data
                 (with-temp-buffer
                   (insert data)
                   (call-shell-region
                    (point-min) (point-max)
                    "xclip -i -selection clipboard -t image/png")))
                (file
                 (if (file-exists-p file)
                     (start-process
                      "xclip-proc" nil "xclip"
                      "-i" "-selection" "clipboard" "-t" "image/png"
                      "-quiet" (file-truename file))))
                (t
                 (message "The image seems to be malformed."))))
      (message "Point is not at an image."))))

(defun ragone/position-to-kill-ring ()
  "Copy to the kill ring a string in the format \"file-name:line-number\"
for the current buffer's file name, and the line number at point."
  (interactive)
  (kill-new
   (format "%s:%d" (file-relative-name buffer-file-name (projectile-project-root)) (save-restriction
                                                                                     (widen) (line-number-at-pos)))))

(defun ragone-htmlize-to-clipboard (html)
  "Copy HTML to clipboard. "
  (with-temp-buffer
    (insert html)
    (call-shell-region
     (point-min) (point-max)
     "wkhtmltoimage -f png - - | xclip -i -selection clipboard -t image/png")))

(defun ragone/htmlize ()
  "Convert the htmlized region to an image and copy to clipboard."
  (interactive)
  (let ((htmlize-pre-style t)
        (region-background (face-attribute 'region :background))
        (start (if (region-active-p)
                   (region-beginning) (point-min)))
        (end (if (region-active-p)
                 (region-end) (point-max))))
    (set-face-background 'region "unspecified")
    (unwind-protect
      (ragone-htmlize-to-clipboard
       (htmlize-region-for-paste start end))
      (set-face-background 'region region-background))))

(defun ragone/create-merge-request ()
  "Visit the current branch's MR on Gitlab."
  (interactive)
  (let* ((loader (make-progress-reporter "Creating"))
         (title (shell-command-to-string "git log -1 --pretty=%s"))
         (description (shell-command-to-string "git log -1 --pretty=%b"))
         (source-branch (magit-get-current-branch))
         (token (ragone/fetch-password :host "api.gitlab.com"))
         (remove-source-branch (y-or-n-p "Remove source branch?"))
         (target-branch (magit-read-branch "Target Branch?"))
         (urls '(("ezyVet" . "https://gitlab.com/api/v4/Dropbox/org/ezyvet%2Fezyvet/merge_requests")
                 ("EPIC Frontend" . "https://gitlab.com/api/v4/Dropbox/org/ezyvet%2Fepic%2Ffrontend/merge_requests")
                 ("EPIC Backend" . "https://gitlab.com/api/v4/Dropbox/org/ezyvet%2Fepic%2Fbackend/merge_requests")))
         (urlkey (completing-read "Select URL" '("ezyVet" "EPIC Frontend" "EPIC Backend")))
         (loading t)
         (data `(("title" . ,title)
                 ("description" . ,description)
                 ("source_branch" . ,source-branch)
                 ("target_branch" . ,target-branch))))
    (if remove-source-branch
        (add-to-list 'data '("remove_source_branch" . "true")))

    (request
     (cdr (assoc urlkey urls))
     :type "POST"
     :parser 'json-read
     :headers `(("PRIVATE-TOKEN" . ,token))
     :data data
     :error (cl-function
                (lambda (&key data &allow-other-keys)
                  (message data)
                  (print! (red "Failed Creating Merge Request"))))
     :complete (cl-function
                (lambda (&key data &allow-other-keys)
                  (browse-url (cdr (assoc 'web_url data)))
                  (let ((loading nil)))
                  (progress-reporter-done loader)
                  (print! (green "Merge Request Created!")))))
    (dotimes (k 100)
      (sit-for 0.01)
      (progress-reporter-update loader k))))

(defun ragone-kill-deft-buffers ()
  "Toggle Deft mode."
  (interactive)
  (save-excursion
    (dolist (buffer (buffer-list))
      (set-buffer buffer)
      (when (not (eq nil deft-note-mode))
        (kill-buffer buffer)))))

(defun ragone-deft-or-close ()
  "Kill all Deft buffers."
  (interactive)
  (if (or (eq major-mode 'deft-mode)
          (not (eq nil deft-note-mode)))
      (progn (ragone-kill-deft-buffers) (kill-buffer "*Deft*"))
    (deft)))

(defun ragone/agenda ()
  "My org agenda."
  (interactive)
  (org-agenda nil "n"))

(defun ragone/time--to-seconds (timestr)
  "Convert HH:MM notation to seconds"
  (let* ((matchindex (string-match "\\([0-9]+\\):\\([0-9]+\\)" timestr))
         (hours (string-to-number (match-string 1 timestr)))
         (minutes (string-to-number (match-string 2 timestr))))
    (+ (* 60 (* hours 60)) (* minutes 60))))

(defun ragone/time-to-hours (timestr)
  "Express time as hours in decimal notation"
  (format "%.3f" (/ (ragone/time--to-seconds timestr) 3600.0)))

(defun ragone/agenda-set-category ()
  "Set the category of the agenda item"
  (interactive)
  (let* ((hdmarker (or (org-get-at-bol 'org-hd-marker)
                       (org-agenda-error)))
         (buffer (marker-buffer hdmarker))
         (pos (marker-position hdmarker))
         (inhibit-read-only t)
         newhead)
    (org-with-remote-undo buffer
      (with-current-buffer buffer
        (widen)
        (goto-char pos)
        (org-show-context 'agenda)
        (org-set-property "CATEGORY" nil)))
    (org-agenda-redo)))

(defun ragone/sql-connect ()
  "Connect a mssql database in `sql-connection-alist'
  with `sql-connect', user should set `sql-connection-alist'
  before run this command."
  (interactive)
  (setq sql-product 'mysql)
  (let ((connect-name
         (completing-read "Which database do you want to connect to: "
                          (mapcar #'(lambda (x)
                                      (symbol-name (car x)))
                                  sql-connection-alist))))
    (sql-connect connect-name)))

(setq sql-mysql-options '("-A"))

(defun ragone/ediff-dotfile-and-template ()
  "ediff the current `dotfile' with the template"
  (interactive)
  (ediff-files
   "~/.doom.d/init.el"
   "~/.emacs.d/init.example.el"))

(set-irc-server! "chat.freenode.net"
                 `(:tls t
                   :nick "ragoneio"
                   :port 6697
                   :sasl-username "ragoneio"
                   :sasl-password (lambda (server)
                                    (ragone/fetch-password :host "chat.freenode.net"))
                   :channels ()))

;; (after! magit
;;   (transient-append-suffix 'magit-log nil
;;     '("-m" "Omit merge commits" "--no-merges")))

;; (defun ragone-glab-post (args)
;;   (message "%S" args)
;;   args)

;; (setq vc-handled-backends nil)
;; (when (string= system-type "darwin")
;;   (setq dired-use-ls-dired nil))
;; (after! magit
;;   ;; (advice-add #'forge--glab-post :filter-args #'ragone-glab-post)
;;   ;; Excluding index.js because of stack overflow error
;;   (setq magit-todos-exclude-globs '("index.js")))

;; ;; Fix dropdown arrows
(add-hook! 'magit-mode-hook
  (setq-local left-fringe-width 15))

(use-package! mu4e)

; iCal
(require 'mu4e-icalendar)
(mu4e-icalendar-setup)
(setq mu4e-icalendar-trash-after-reply t)

(set-email-account! "ragonedk@gmail.com"
                    '((mu4e-sent-folder                 . "/gmail/Sent")
                      (mu4e-trash-folder                . "/gmail/Trash")
                      (mu4e-drafts-folder               . "/gmail/Drafts")
                      (user-full-name                   . "Alex Ragone")
                      (user-mail-address                . "ragonedk@gmail.com")
                      (smtpmail-smtp-user               . "ragonedk@gmail.com")
                      (smtpmail-smtp-server             . "smtp.gmail.com")
                      (smtpmail-smtp-service            .  587)
                      (smtpmail-stream-type             . starttls)
                      (mu4e-get-mail-command            . "mbsync -c ~/.doom.d/mu4e/.mbsyncrc gmail")))

(set-email-account! "ara@planday.com"
                    '((mu4e-sent-folder                 . "/planday/Sent")
                      (mu4e-trash-folder                . "/planday/Trash")
                      (mu4e-drafts-folder               . "/planday/Drafts")
                      (user-full-name                   . "Alex Ragone")
                      (user-mail-address                . "ara@planday.com")
                      (smtpmail-smtp-user               . "ara@planday.com")
                      (smtpmail-smtp-server             . "smtp.office365.com")
                      (smtpmail-smtp-service            .  587)
                      (smtpmail-stream-type             . starttls)
                      (message-cite-style               . 'message-cite-style-outlook)
                      (mu4e-get-mail-command            . "mbsync -c ~/.doom.d/mu4e/.mbsyncrc work"))
                    t)

(setq message-yank-prefix ""
      message-yank-cited-prefix ""
      message-yank-empty-prefix ""
      message-citation-line-format "\n\n-----------------------\nOn %a, %b %d %Y, %N wrote:\n"
      message-citation-line-function 'message-insert-formatted-citation-line
      mu4e-update-interval 300) ; every 5 minutes

(defun ragone/capture-mail (buffer)
  "Captures the email as todo"
  (org-store-link t)
  (org-capture-string nil "e")
  (org-capture-finalize)
  (mu4e-view-mark-for-trash))

(defun ragone/capture-note (buffer)
  "Captures the email as a note"
  (org-store-link t)
  (org-capture-string nil "o")
  (org-capture-finalize)
  (mu4e-view-mark-for-trash))

(after! mu4e
  (add-to-list 'mu4e-headers-actions '("note" . ragone/capture-note))
  (add-to-list 'mu4e-view-actions '("note" . ragone/capture-note))
  (add-to-list 'mu4e-headers-actions '("todo" . ragone/capture-mail))
  (add-to-list 'mu4e-view-actions '("todo" . ragone/capture-mail)))

(defun no-auto-fill ()
  "Turn off auto-fill-mode."
  (auto-fill-mode -1))

(defun ragone/org-mu4e-compose ()
  (org-mu4e-compose-org-mode)
  (no-auto-fill))

(use-package! org-mu4e
  :hook ((org-mode mu4e-compose) . ragone/org-mu4e-compose))

(after! mu4e

  (setq mu4e-index-cleanup t
        mu4e-sent-messages-behavior 'sent
        mu4e-html2text-command "w3m -dump -T text/html")

  (add-to-list 'mu4e-bookmarks
               (make-mu4e-bookmark
                :name  "External"
                :query "NOT from:planday.com"
                :key ?e))

  (add-to-list 'mu4e-bookmarks
               (make-mu4e-bookmark
                :name  "Internal"
                :query "from:planday.com NOT from:ara@planday.com NOT from:ara@planday.com"
                :key ?i))

  (add-to-list 'mu4e-view-actions '("ViewInBrowser" . mu4e-action-view-in-browser) t)

  (setq mu4e-headers-include-related nil
        mu4e-headers-attach-mark '("a" . "@")
        ;;mu4e-view-use-gnus t
        mu4e-confirm-quit nil
        mu4e-headers-fields
        '((:flags      . 4)
          (:human-date . 12)
          (:from       . 25)
          (:subject    . nil))))

;;(require 'mu4e-icalendar)
;;(mu4e-icalendar-setup)
;; Optional
;;(setq mu4e-icalendar-trash-after-reply t)

(eval-after-load "org-mu4e"
  '(defun org~mu4e-mime-multipart (plain html &optional images)
     "Create a multipart/alternative with text/plain and text/html alternatives.
If the html portion of the message includes images, wrap the html
and images in a multipart/related part."
     (let* ((signature-raw (with-temp-buffer
                             (insert-file-contents "~/.doom.d/mu4e/signature-test.html")
                             (buffer-string)))
            (tmp-file (make-temp-name
                       (expand-file-name "mail"
                                         temporary-file-directory)))
            (citation-index (string-match "^-----------------------$" plain))
            (body (substring plain 0 citation-index))
            (citation (substring plain citation-index (length plain)))
            (html-content-body (org-export-string-as
                                 (concat "#+OPTIONS: toc:nil num:nil\n" body) 'html t))
            (html-content-citation (org-export-string-as
                                     (concat "#+OPTIONS: toc:nil num:nil\n" citation) 'html t))
            (signature-html-and-images
             (org~mu4e-mime-replace-images
              signature-raw
              tmp-file))
            (signature-html-images (cdr signature-html-and-images))
            (signature-html (car signature-html-and-images))
            (signature-images (mapconcat 'identity signature-html-images "\n")))
       (concat "<#multipart type=alternative><#part type=text/plain>"
               plain
               "<#multipart type=related>"
               "<#part type=text/html>"
               "<div style=\"font-size: 11.0pt; font-family: 'Calibri',sans-serif;\">"
               html-content-body
               images
               "</div>"
               signature-html
               (if citation-index
                 html-content-citation)
               signature-images
               "<#/multipart>\n"
               "<#/multipart>\n"))))

(defun ragone/mu4e-delete-citation ()
  (delete-region (point-min) (point-max)))
;; (add-hook 'mail-citation-hook #'ragone/mu4e-delete-citation)

(setq doom-theme 'doom-gruvbox
      doom-big-font (font-spec :size 30 :family "DejaVu Sans Mono")
      doom-modeline-height 40
      doom-font (font-spec :family "Fira Code Light"))

(add-hook! 'doom-load-theme-hook
  (set-face-attribute 'org-agenda-structure nil :inherit 'default :height 1.50)
  (set-face-attribute 'org-agenda-date-weekend nil :foreground "#504945" :height 1.00 :weight 'light)
  (set-face-attribute 'org-agenda-calendar-event nil :foreground "#fabd2f")
  (set-face-attribute 'org-agenda-date nil :foreground "#d5c4a1" :inherit 'default :height 1.25)
  (set-face-attribute 'org-agenda-date-today nil :slant 'normal :weight 'bold :height 1.25))

(require 'org-clock-convenience)

(defun ragone-refile-targets ()
  (deft-find-files org-directory))

(defun ragone-agenda-prefix ()
  (let* ((deadline (org-element-property :deadline (org-element-at-point)))
         (level (org-element-property :level (org-element-at-point)))
         (project-level (org-element-property :level (save-excursion
                                                       (bh/find-project-task t)
                                                       (org-element-at-point))))
         (adjusted (- level project-level))
         (category (org-entry-get (point) "CATEGORY")))
    (cond ((and deadline
                (not (bh/is-subproject-p)))
           (org-timestamp-format deadline "%x"))
          ((and (bh/is-subproject-p)
                (ragone/is-project-p))
           (ragone-agenda-make-prefix adjusted t))
          ((ragone/is-project-p)
           (concat category
                   ": "))
          (t (ragone-agenda-make-prefix adjusted)))))

(defun ragone-agenda-make-prefix (level &optional subproject-p)
  (let ((adjusted (+ 11 level)))
    (concat (make-string adjusted ?\s)
            (char-to-string (org-bullets-level-char level))
            " ")))

(add-hook 'org-mode-hook 'org-indent-mode)

(after! org
  (setq
   org-link-file-path-type 'relative
   org-agenda-log-mode-items '(closed state)
   org-src-fontify-natively t
   org-journal-dir "~/Dropbox/org/journal/"
   org-journal-file-type 'weekly
   org-agenda-show-inherited-tags nil
   org-log-done 'time
   org-agenda-show-future-repeats 'next
   org-agenda-skip-timestamp-if-done t
   org-agenda-start-with-log-mode t
   org-agenda-prefix-format '((agenda . "%2i%-12:c%?-12t% s")
                              (todo . "%2i%-12:c")
                              (tags . "%2i%-12:c")
                              (search . "%2i%-12:c"))
   org-agenda-skip-deadline-if-done t
   org-agenda-block-separator ?\u2550
   org-confirm-babel-evaluate nil
   org-agenda-category-icon-alist
     `(("inbox" ,(list (all-the-icons-faicon "angle-double-right" :face 'font-lock-keyword-face :height 0.9 :v-adjust 0.02)) nil nil :ascent center))
   org-agenda-span 5
   org-agenda-start-day nil
   org-stuck-projects '("" nil nil "")
   org-directory "~/Dropbox/org"
   +org-capture-todo-file "~/Dropbox/org/todo.org"
   +org-capture-notes-file "~/Dropbox/org/notes.org"
   org-refile-allow-creating-parent-nodes 'confirm
   org-tag-faces `(("meeting" :foreground ,(face-foreground 'font-lock-type-face))
                   ("email" :foreground ,(face-foreground 'font-lock-variable-name-face)))
   org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
     (sequence "NOTE(N)" "MEETING(M)")
     (sequence "WAITING(w@)" "DELEGATED(e@)" "LATER(l)" "|" "CANCELLED(c)"))
   ;; org-refile-targets
   ;; '((ragone-refile-targets :level . 0))
   ;; org-refile-use-outline-path 'full-file-path
   ;; org-outline-path-complete-in-steps nil
   org-todo-keyword-faces
   '(("WAITING" :foreground "#fabd2f" :weight bold)
     ("DELEGATED" :foreground "#fabd2f" :weight bold)
     ("NOTE" :foreground "#83a598" :weight bold)
     ("MEETING" :foreground "#83a598" :weight bold)
     ("LATER" :foreground "#83a598" :weight bold)
     ("NEXT" :foreground "#b8bb26" :weight bold))
   org-capture-templates
   '(("t" "Todo" entry
      (file+headline +org-capture-todo-file "Inbox")
      "* TODO %?" :prepend t :kill-buffer t)
     ("n" "Next" entry
      (file+headline +org-capture-todo-file "Inbox")
      "* NEXT %?" :prepend t :kill-buffer t)
     ("w" "Waiting" entry
      (file+headline +org-capture-todo-file "Inbox")
      "* WAITING %?" :prepend t :kill-buffer t)
     ("o" "Email Note" entry
      (file+headline +org-capture-notes-file "Inbox")
      "* NOTE %u %^{Content?} :email:\n%a" :prepend t :kill-buffer t)
     ("e" "Email" entry
      (file+headline +org-capture-todo-file "Inbox")
      "* %^{Type?|TODO|NEXT|WAITING|DELEGATED} %^{Content?} :email:\nSCHEDULED: %t\n%a" :prepend t :kill-buffer t)
     ("m" "Meeting Notes" entry
      (file+headline +org-capture-notes-file "Inbox")
      "* NOTE %u %? :meeting:\n** Present at meeting\n- [ ] \n** Agenda\n** Notes" :prepend t :kill-buffer t)
     ("N" "Notes" entry
      (file+headline +org-capture-notes-file "Inbox")
      "* NOTE %u %?\n%i" :prepend t :kill-buffer t))
   org-agenda-files (list org-directory)
   ;;org-agenda-file-regexp "\\`[^.].*\\.org'\\|[0-9]+$"
   ragone-org-deadline-prefix "%2i%-12(ragone-agenda-prefix)"
   org-agenda-custom-commands
   '(("n" "Agenda"
      ((agenda "")
       (todo ""
             ((org-agenda-overriding-header (concat (all-the-icons-faicon "chain-broken" :v-adjust 0.01) " Stuck Projects"))
              (org-agenda-skip-function #'ragone/should-skip)
              (org-agenda-prefix-format ragone-org-deadline-prefix)
              (org-agenda-sorting-strategy nil)))
       (todo "NEXT"
             ((org-agenda-overriding-header (concat (all-the-icons-faicon "bolt" :v-adjust 0.01) " Next Tasks"))
              (org-agenda-sorting-strategy
               '(priority-down category-up))))
       (todo "TODO"
             ((org-agenda-files '("~/Dropbox/org/todo.org" "~/Dropbox/org/notes.org"))
              (org-agenda-sorting-strategy
               '(priority-down category-up))
              (org-agenda-overriding-header (concat (all-the-icons-faicon "check-square-o" :v-adjust 0.01) " Tasks"))))
       (todo "WAITING|DELEGATED"
             ((org-agenda-overriding-header (concat (all-the-icons-faicon "hourglass" :v-adjust 0.01) " Waiting/Delegated"))
              (org-agenda-sorting-strategy '(priority-down category-up))))
       (todo "LATER"
             ((org-agenda-sorting-strategy
               '(priority-down category-up))
              (org-agenda-overriding-header (concat (all-the-icons-faicon "thumb-tack" :v-adjust 0.01) " Later"))))
       (todo "NOTE"
             ((org-agenda-overriding-header (concat (all-the-icons-faicon "sticky-note" :v-adjust 0.01) " Notes"))
              (org-agenda-max-entries 10)
              (org-agenda-sorting-strategy
               '(tsia-down)))))

      nil))))

;; FIXME Make this work for project subtasks?
;; (defun org-agenda-color-category (category forecolor)
;;   (let ((re (rx-to-string `(seq bol (0+ space) ,category (1+ space)))))
;;     (save-excursion
;;       (goto-char (point-min))
;;       (while (re-search-forward re nil t)
;;         (add-text-properties (match-beginning 0) (match-end 0)
;;                              (list 'face (list :foreground forecolor)))))))

;; (defun ragone/setup-agenda-color ()
;;   (org-agenda-color-category "api:" "#DD6F48"))

;; (add-hook 'org-agenda-finalize-hook #'ragone/setup-agenda-color)

(setq org-priority-faces '((?A . (:foreground "#fb4933" :weight bold))
                           (?B . (:foreground "#fabd2f"))
                           (?C . (:foreground "#b8bb26" :slant italic))))
(after! org-habit
  (setq
    org-habit-today-glyph ?‖
    org-habit-completed-glyph ?✓
    org-habit-show-habits-only-for-today nil))

(defun ragone/org-agenda-mode-fn ()
  (define-key org-agenda-mode-map
    (kbd "<S-up>") #'org-clock-convenience-timestamp-up)
  (define-key org-agenda-mode-map
    (kbd "<S-down>") #'org-clock-convenience-timestamp-down))
(add-hook 'org-agenda-mode-hook #'ragone/org-agenda-mode-fn)

;; (defvar ragone-org-mu4e-updated nil)
;; (defun ragone/update-mu4e-tags ()
;;   (unless ragone-org-mu4e-updated
;;     (setq ragone-org-mu4e-updated t)
;;     (unless (mu4e~proc-running-p)
;;       (mu4e~proc-start))
;;     (org-map-entries
;;      (lambda ()
;;        (when (ragone/is-project-p)
;;          (let* ((search (concat "flag:unread " (nth 4 (org-heading-components))))
;;                 (code (with-temp-buffer
;;                         (call-process "mu" nil (current-buffer) nil "find" search))))
;;            (if (= 0 code)
;;                (org-toggle-tag "unread" 'on)
;;              (org-toggle-tag "unread" 'off)))))
;;      t
;;      'agenda)))
;; (add-hook 'org-agenda-mode-hook #'ragone/update-mu4e-tags)
;; (add-hook 'mu4e-update-pre-hook (lambda () (setq ragone-org-mu4e-updated nil)))

(require 'org-static-blog)
(require 'org)
(setq org-static-blog-publish-title "ragone.io"
      org-static-blog-publish-url "https://ragone.io/"
      org-static-blog-publish-directory "~/Dropbox/org/blog/"
      org-static-blog-posts-directory "~/Dropbox/org/blog/posts/"
      org-static-blog-drafts-directory "~/Dropbox/org/blog/drafts/"
      org-export-with-toc nil
      org-static-blog-enable-tags t
      org-export-with-section-numbers nil
      org-static-blog-index-length 99
      org-static-blog-page-header
      "<meta  name=\"author\" content=\"ragone\" />
      <link href= \"static/style.css\" rel=\"stylesheet\" type=\"text/css\" />
      <link href= \"static/htmlize.css\" rel=\"stylesheet\" type=\"text/css\" />
      <meta http-equiv=\"content-type\" content=\"application/xhtml+xml; charset=UTF-8\" />
      <meta name=\"viewport\" content=\"initial-scale=1,width=device-width,minimum-scale=1\">"
      org-static-blog-page-preamble
      "<header>
        <a href=\"index.html\"><code>Alex Ragone</code></a>
        <nav>
          <a title=\"Projects\" href=\"tag-projects.html\">Projects</a>
          <a title=\"LinkedIn\" href=\"https://www.linkedin.com/in/alex-ragone\" target=\"_blank\" rel=\"noopener\">LinkedIn</a>
          <a title=\"Github\" href=\"https://github.com/ragone\" target=\"_blank\" rel=\"noopener\">Github</a>
        </nav>
      </header>")

(setq org-static-blog-page-postamble
      "<div id=\"archive\">
        <a href=\"archive.html\">archive</a>
        <a href=\"tags.html\">tags</a>
      </div>")

(defun org-static-blog-post-preamble (post-filename)
  (concat
   "<div class=\"headline\"> <h1 class=\"post-title\">"
   "<a href=\"" (org-static-blog-get-url post-filename) "\">" (org-static-blog-get-title post-filename) "</a>" "</h1>\n"
   (org-style-tags post-filename) "</div>"
   "<div class=\"post-date\">"
   (format-time-string "<%Y-%m-%d %a>" (org-static-blog-get-date post-filename))
   "</div>"))

(defun org-style-tags (post-filename)
  (let ((taglist-content ""))
    (when (and (org-static-blog-get-tags post-filename) org-static-blog-enable-tags)
      (setq taglist-content (concat "<div class=\"taglist\">"
                                    ":"))
      (dolist (tag (org-static-blog-get-tags post-filename))
        (setq taglist-content (concat taglist-content "<a href=\""
                                      "tag-" (downcase tag) ".html"
                                      "\">" tag "</a>:")))
      (setq taglist-content (concat taglist-content "</div>")))
    taglist-content))

(advice-add #'org-static-blog-publish
            :around (lambda (oldfun)
                      (setq org-html-htmlize-output-type 'css)
                      (funcall oldfun)
                      (setq org-html-htmlize-output-type 'inline-css)))

(defun org-static-blog-post-postamble (post-filename)
  "")

(defun org-static-blog-get-post-summary (post-filename)
  (concat
   "<div class=\"headline\"> <h2 class=\"post-title\">"
   "<a href=\"" (org-static-blog-get-url post-filename) "\">" (org-static-blog-get-title post-filename) "</a>" "</h2>\n"
   (org-style-tags post-filename) "</div>"
   "<div class=\"post-date\">" (format-time-string "<%Y-%m-%d %a>" (org-static-blog-get-date post-filename)) "</div>"))

(defun bh/is-project-p ()
  "Any task with a todo keyword subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (not (member (nth 2 (org-heading-components)) org-done-keywords))))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (let ((keyword (org-get-todo-state)))
            (when (and keyword
                       (not (member keyword (append '("LATER") org-done-keywords))))
              (setq has-subtask t)))))
      (and is-a-task has-subtask))))

(defun bh/is-project-subtree-p ()
  "Any task with a todo keyword that is in a project subtree.
Callers of this function already widen the buffer view."
  (let ((task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
    (save-excursion
      (bh/find-project-task)
      (if (equal (point) task)
          nil
        t))))

(defun bh/find-project-task (&optional top)
  "Move point to the parent (project) task if any"
  (save-restriction
    (widen)
    (let ((this-task (save-excursion (org-back-to-heading 'invisible-ok) (point)))
          (parent-task))
      (while (and (or top (not parent-task)) (org-up-heading-safe))
        (when (bh/is-project-p)
          (setq parent-task (point))))
      (if parent-task
          (progn
            (goto-char parent-task)
            parent-task)
        (goto-char this-task)
        this-task))))

(defun bh/is-task-p ()
  "Any task with a todo keyword and no subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task (not has-subtask)))))

(defun bh/is-subproject-p ()
  "Any task which is a subtask of another project"
  (let ((is-subproject)
        (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
    (save-excursion
      (while (and (not is-subproject) (org-up-heading-safe))
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq is-subproject t))))
    (and is-a-task is-subproject)))

(defun bh/list-sublevels-for-projects-indented ()
  "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
  This is normally used by skipping functions where this variable is already local to the agenda."
  (if (marker-buffer org-agenda-restrict-begin)
      (setq org-tags-match-list-sublevels 'indented)
    (setq org-tags-match-list-sublevels nil))
  nil)

(defun bh/list-sublevels-for-projects ()
  "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
  This is normally used by skipping functions where this variable is already local to the agenda."
  (if (marker-buffer org-agenda-restrict-begin)
      (setq org-tags-match-list-sublevels t)
    (setq org-tags-match-list-sublevels nil))
  nil)

(defvar bh/hide-scheduled-and-waiting-next-tasks t)

(defun bh/toggle-next-task-display ()
  (interactive)
  (setq bh/hide-scheduled-and-waiting-next-tasks (not bh/hide-scheduled-and-waiting-next-tasks))
  (when  (equal major-mode 'org-agenda-mode)
    (org-agenda-redo))
  (message "%s WAITING and SCHEDULED NEXT Tasks" (if bh/hide-scheduled-and-waiting-next-tasks "Hide" "Show")))

(defun bh/skip-stuck-projects ()
  "Skip trees that are not stuck projects"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                nil
              next-headline)) ; a stuck project, has subtasks but no next task
        nil))))

(defun bh/skip-non-stuck-projects-and-tasks ()
  (let ((next-heading (save-excursion (or (outline-next-heading) (point-max))))
        (this-headline (save-excursion (org-back-to-heading 'invisible-ok) (point))))
    (cond ((bh/is-project-p)
           (bh/skip-non-stuck-projects))
          ((and (bh/is-subproject-p)
                (not (member (org-get-todo-state) (list "LATER")))
                (bh/find-project-task) ; Is a subproject task
                (not (bh/skip-non-stuck-projects))) ; Parent is stuck
           nil)
          (t next-heading))))

(defun ragone/should-skip ()
  "Return non-nil if all the project subtasks are not stuck."
  (interactive)
  (let ((next-heading (save-excursion (or (outline-next-heading) (point-max))))
        (this-headline (org-element-at-point)))
    (save-restriction
      (save-excursion
        (org-narrow-to-subtree)
        (let* ((headlines (org-element-map (org-element-parse-buffer 'greater-element t)
                              'headline
                            #'identity))
               ;; Filter out element at point
               (direct-children (seq-filter (lambda (headline)
                                              (not (equal (org-element-property :begin this-headline)
                                                          (org-element-property :begin headline))))
                                            headlines)))
          (ragone/should-skip-children direct-children))))))

(defun ragone/should-skip-children (children)
  (widen)
  (if children
      ;; If there are any children, recursively see if any task in the subtree is stuck
      (if (seq-some (lambda (child)
                      (goto-char (org-element-property :begin child))
                      (not (ragone/should-skip)))
                    children)
          ;; If there are any task which should not be skipped, include it and continue.
          nil
        ;; Else we don't care about it
        next-heading)
    ;; No children, so check if it is a project task
    (if (ragone/find-project-task)
        (if (ragone/is-task-stuck)
            nil
          next-heading)
      next-heading)))

(defun ragone/is-project-p ()
  "Any task with a todo keyword subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (and (nth 2 (org-heading-components))
                          (not (member (nth 2 (org-heading-components)) org-done-keywords)))))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (let ((keyword (org-get-todo-state)))
            (when (and keyword
                       (not (member keyword (append '("LATER") org-done-keywords))))
              (setq has-subtask t)))))
      (and is-a-task has-subtask))))

(defun ragone/find-project-task ()
  "Move point to the parent (project) task if any"
  (save-restriction
    (widen)
    (let ((parent-task))
      (while (and (not parent-task)
                  (org-up-heading-safe))
        (when (ragone/is-project-p)
          (setq parent-task (point))))
      parent-task)))

(defun ragone/is-task-stuck ()
  "Return non-nil if the task at point is stuck"
  ;; (bh/list-sublevels-for-projects-indented)
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
          (this-headline (save-excursion (org-back-to-heading 'invisible-ok) (point))))
       (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
              (has-next))
          (save-excursion
            (forward-line 1)
            (while (and (not has-next)
                        (< (point) subtree-end)
                        (re-search-forward "^\\*+ NEXT\\|DELEGATED " subtree-end t))
              ;; Only skip if there is a deadline for delegated tasks
              (unless (and (member (org-get-todo-state) (list "DELEGATED"))
                           (not (org-element-property :deadline (org-element-at-point))))
                (setq has-next t))))
          (not has-next)))))

(defun bh/skip-non-stuck-projects (&optional sub-project-p)
  "Skip trees that are not stuck projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
          (this-headline (save-excursion (org-back-to-heading 'invisible-ok) (point))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next)
                          (< (point) subtree-end)
                          (re-search-forward "^\\*+ NEXT\\|DELEGATED " subtree-end t))
                ;; Only skip if there is a deadline for delegated tasks
                (unless (and (member (org-get-todo-state) (list "DELEGATED"))
                             (not (org-element-property :deadline (org-element-at-point))))
                  (setq has-next t))))
            (if has-next
                next-headline
              nil)) ; a stuck project, has subtasks but no next task
        next-headline))))

(defun bh/skip-non-projects ()
  "Skip trees that are not projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (if (save-excursion (bh/skip-non-stuck-projects))
      (save-restriction
        (widen)
        (let ((subtree-end (save-excursion (org-end-of-subtree t))))
          (cond
           ((bh/is-project-p)
            nil)
           ((and (bh/is-project-subtree-p) (not (bh/is-task-p)))
            nil)
           (t
            subtree-end))))
    (save-excursion (org-end-of-subtree t))))

(defun bh/skip-non-tasks ()
  "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((bh/is-task-p)
        nil)
       (t
        next-headline)))))

(defun bh/skip-project-trees-and-habits ()
  "Skip trees that are projects"
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-projects-and-habits-and-single-tasks ()
  "Skip trees that are projects, tasks that are habits, single non-project tasks"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((org-is-habit-p)
        next-headline)
       ((and bh/hide-scheduled-and-waiting-next-tasks
             (member "WAITING" (org-get-tags-at)))
        next-headline)
       ((bh/is-project-p)
        next-headline)
       ((and (bh/is-task-p) (not (bh/is-project-subtree-p)))
        next-headline)
       (t
        nil)))))

(defun bh/skip-project-tasks-maybe ()
  "Show tasks related to the current restriction.
When restricted to a project, skip project and sub project tasks, habits, NEXT tasks, and loose tasks.
When not restricted, skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
           (next-headline (save-excursion (or (outline-next-heading) (point-max))))
           (limit-to-project (marker-buffer org-agenda-restrict-begin)))
      (cond
       ((bh/is-project-p)
        next-headline)
       ((org-is-habit-p)
        subtree-end)
       ((and (not limit-to-project)
             (bh/is-project-subtree-p))
        subtree-end)
       ((and limit-to-project
             (bh/is-project-subtree-p)
             (member (org-get-todo-state) (list "NEXT")))
        subtree-end)
       (t
        nil)))))

(defun bh/skip-project-tasks ()
  "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       ((bh/is-project-subtree-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-non-project-tasks ()
  "Show project tasks.
Skip project and sub-project tasks, habits, and loose non-project tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
           (next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((bh/is-project-p)
        next-headline)
       ((org-is-habit-p)
        subtree-end)
       ((and (bh/is-project-subtree-p)
             (member (org-get-todo-state) (list "NEXT")))
        subtree-end)
       ((not (bh/is-project-subtree-p))
        subtree-end)
       (t
        nil)))))

(defun bh/skip-projects-and-habits ()
  "Skip trees that are projects and tasks that are habits"
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-non-subprojects ()
  "Skip trees that are not projects"
  (let ((next-headline (save-excursion (outline-next-heading))))
    (if (bh/is-subproject-p)
        nil
      next-headline)))

(defun bh/skip-projects ()
  "Skip projects"
  (let ((next-headline (save-excursion (outline-next-heading))))
    (if (not (bh/is-project-p))
        nil
      next-headline)))

(add-hook 'js2-mode-hook 'prettier-js-mode)
(add-hook 'typescript-mode-hook 'prettier-js-mode)
(require 'lsp-ui)
(setq lsp-ui-peek-fontify 'always)
(mapc (lambda (f) (set-face-foreground f "dim gray"))
      '(lsp-ui-sideline-code-action lsp-ui-sideline-current-symbol lsp-ui-sideline-symbol lsp-ui-sideline-symbol-info))

(add-to-list 'org-src-lang-modes '("react" . web))

; Web mode fix
(defun enable-minor-mode (my-pair)
  "Enable minor mode if filename match the regexp.  MY-PAIR is a cons cell (regexp . minor-mode)."
  (if (buffer-file-name)
      (if (string-match (car my-pair) buffer-file-name)
          (funcall (cdr my-pair)))))
(add-hook 'web-mode-hook #'(lambda ()
                            (enable-minor-mode
                             '("\\.tsx?\\'" . prettier-js-mode))))
