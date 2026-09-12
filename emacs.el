;; [[file:emacs.org::*Basic setup][Basic setup:1]]
(message "@rust-toolchain@")
(setq inhibit-startup-message t
      visible-bell t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(setq display-line-numbers-type 'relative)

(global-display-line-numbers-mode 1)
(use-package vterm
  :ensure t)
;; Stop the split screen when opening emacs with a filename argument
(add-hook 'emacs-startup-hook
          (lambda () (delete-other-windows)))
;; no indent-tabs-mode for me
(setq-default indent-tabs-mode nil)
;; Basic setup:1 ends here

;; [[file:emacs.org::*EVIL mode][EVIL mode:1]]
(use-package evil
  :ensure t ;; install the evil package if not installed
  :init ;; tweak evil's configuration before loading it
  (setq evil-respect-visual-line-mode t)
  (setq evil-search-module 'evil-search)
  (setq evil-ex-complete-emacs-commands nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-shift-round nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-keybinding nil)
  :config ;; tweak evil after loading it
  (evil-mode))
;; EVIL mode:1 ends here

;; [[file:emacs.org::*EVIL mode][EVIL mode:2]]
(use-package general
  :ensure t
  :config
  (general-auto-unbind-keys)
  (general-override-mode))
(general-create-definer my-leader-def
  ;; :prefix my-leader
  :prefix "SPC")
(my-leader-def 'normal 'global
  "g" '("Games" . (keymap))
  "g t" '("Tetris" . tetris))

(general-create-definer my-local-leader-def
  ;; :prefix my-local-leader
  :prefix "SPC m")
;; EVIL mode:2 ends here

;; [[file:emacs.org::*Rainbow delimiters and electric pairs][Rainbow delimiters and electric pairs:1]]
(use-package rainbow-delimiters
  :ensure t
  :init
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))
(add-hook 'prog-mode-hook #'electric-pair-mode)
;; Rainbow delimiters and electric pairs:1 ends here

;; [[file:emacs.org::*Please put the autosave and backup files somewhere where git won't get them][Please put the autosave and backup files somewhere where git won't get them:1]]
;; Put backup files neatly away
(let ((backup-dir "~/.local/state/emacs/backups")
      (auto-saves-dir "~/.local/state/emacs/auto-saves/"))
  (dolist (dir (list backup-dir auto-saves-dir))
    (when (not (file-directory-p dir))
      (make-directory dir t)))
  (setq backup-directory-alist `(("." . ,backup-dir))
        auto-save-file-name-transforms `((".*" ,auto-saves-dir t))
        auto-save-list-file-prefix (concat auto-saves-dir ".saves-")
        tramp-backup-directory-alist `((".*" . ,backup-dir))
        tramp-auto-save-directory auto-saves-dir))

(setq backup-by-copying t    ; Don't delink hardlinks
      delete-old-versions t  ; Clean up the backups
      version-control t      ; Use version numbers on backups,
      kept-new-versions 5    ; keep some new versions
      kept-old-versions 2)   ; and some old ones, too
;; Please put the autosave and backup files somewhere where git won't get them:1 ends here

;; [[file:emacs.org::*QOL editing and snippets][QOL editing and snippets:1]]
(use-package yasnippet
  :ensure t
  :demand t
  :general
  (:states '(insert normal)
           "M-+" 'yas-expand
           "M-*" 'yas-insert-snippet)
  :config
  (add-to-list 'yas-snippet-dirs "@snippets@")
  (add-to-list 'yas-snippet-dirs "~/Documents/Snippets")
  (setq yas-prompt-functions '(yas-completing-read-prompt))
  ;; Prevent field menu prompts from taking over the window layout
  (setq yas-triggers-in-field nil)
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet
  :config
  (yasnippet-snippets-initialize)
  (yas-reload-all))

(use-package yasnippet-capf
  :ensure t
  :after (yasnippet cape))
;; QOL editing and snippets:1 ends here

;; [[file:emacs.org::*Fold regions like in vim][Fold regions like in vim:1]]
(use-package vimish-fold
  :ensure
  :after evil)

(use-package evil-vimish-fold
  :ensure
  :after vimish-fold
  :init
  (setq evil-vimish-fold-mode-lighter " ⮒")
  (setq evil-vimish-fold-target-modes '(prog-mode conf-mode text-mode))
  :config
  (global-evil-vimish-fold-mode))
;; Fold regions like in vim:1 ends here

;; [[file:emacs.org::*Make popups more usable][Make popups more usable:1]]
(use-package popper
  :ensure t ; or :straight t
  :general
  (:states '(normal insert)
   ("C-`" 'popper-toggle
    "M-`"   'popper-cycle
    "C-M-`" 'popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "\\*Warnings\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          help-mode
          compilation-mode))
  (popper-mode +1)
  (popper-echo-mode +1))
;; Make popups more usable:1 ends here

;; [[file:emacs.org::*Theme][Theme:1]]
(load-theme 'modus-vivendi t)
;; Theme:1 ends here

;; [[file:emacs.org::*Org mode][Org mode:1]]
(setq org-latex-create-formula-image-program 'dvisvgm)
;; (setq org-format-latex-options
;;       (plist-put org-format-latex-options :scale 1.5))

;; Ensure babel languages are loaded after Org is ready
(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((dot . t)      ; activates dot
    (C . t)      ; activates dot
     (latex . t)))) ; activates latex
;; Org mode:1 ends here

;; [[file:emacs.org::*Hunspell][Hunspell:1]]
(setq
 ispell-program-name
 "@hunspell@")
;; Hunspell:1 ends here

;; [[file:emacs.org::*Graphviz][Graphviz:1]]
(defun my/fix-inline-images ()
  (org-redisplay-inline-images))
(add-hook 'org-babel-after-execute-hook 'my/fix-inline-images)
;; Graphviz:1 ends here

;; [[file:emacs.org::*Inkscape compat][Inkscape compat:1]]
(use-package ink
  :ensure nil
  :config
  (my-local-leader-def
    :states '(normal)
    :keymaps '(latex-mode-map org-mode-map)'
    "i" '("Inkscape figures" . (keymap))
    "i n" '("New figure (opens Inkscape)" . ink-make-figure)
    "i d" '("Duplicates figure (opens Inkscape)" . ink-duplicate-figure)
    "i e" '("Edits figure (opens Inkscape)" . ink-edit-figure)))
;; Inkscape compat:1 ends here

;; [[file:emacs.org::*$\LaTeX$ Templates][$\LaTeX$ Templates:1]]
(with-eval-after-load 'ox
  (setq org-export-allow-bind-keywords t)
  (setq org-export-with-title nil)
  (setq org-export-with-toc nil)

  (add-to-list 'org-export-options-alist
               '(:subject "SUBJECT" nil "" t))
  (add-to-list 'org-export-options-alist
               '(:notes-toc "NOTES_TOC" nil nil t))
  (add-to-list 'org-export-options-alist
               '(:notes-glossary "NOTES_GLOSSARY" nil nil t))
  (add-to-list 'org-export-options-alist
               '(:notes-todo "NOTES_TODO" nil nil t))
  (add-to-list 'org-export-options-alist
               '(:isdraft "ISDRAFT" nil nil t))
  (add-to-list 'org-export-options-alist
               '(:notes-widetitles "NOTES_WIDE_TITLES" nil t t))
  (add-to-list 'org-export-options-alist
               '(:notes-titlepage "NOTES_TITLEPAGE" nil nil t)))

(with-eval-after-load 'ox-latex
  (setq org-latex-compiler "lualatex"
        org-latex-pdf-process
        '("lualatex --shell-escape --interaction=nonstopmode --output-directory %o %f"
          "lualatex --shell-escape --interaction=nonstopmode --output-directory %o %f"))

  (add-to-list
   'org-latex-classes
   '("notes"
     "\\documentclass[11pt,a4paper]{article}
\\input{@template-dir@/notes.tex}
[no-default-packages]
[packages]
[extra]
\\AtEndDocument{\\input{@template-dir@/notes-footer.tex}}"
     ("\\section{%s}" . "\\section*{%s}")
     ("\\subsection{%s}" . "\\subsection*{%s}")
     ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))

  (defun my/org-notes-option-true-p (value)
    "Return non-nil when VALUE represents an enabled Org option."
    (member (downcase (format "%s" value))
            '("t" "true" "yes" "1")))

  (defun my/org-latex-notes-filter (output backend info)
    "Insert notes-template settings into exported LaTeX."
    (when (and (org-export-derived-backend-p backend 'latex)
               (string= (plist-get info :latex-class) "notes"))
      (let* ((subject    (org-latex-plain-text
                          (format "%s" (or (plist-get info :subject) ""))
                          info))
             (subtitle   (or (org-export-data (plist-get info :subtitle) info) ""))
             (toc        (my/org-notes-option-true-p (plist-get info :notes-toc)))
             (glossary   (my/org-notes-option-true-p (plist-get info :notes-glossary)))
             (todo       (my/org-notes-option-true-p (plist-get info :notes-todo)))
             (draft      (my/org-notes-option-true-p (plist-get info :isdraft)))
             (widetitles (my/org-notes-option-true-p (plist-get info :notes-widetitles)))
             (titlepage  (my/org-notes-option-true-p (plist-get info :notes-titlepage)))
             (settings
              (concat
               (format "\\def\\NotesSubject{%s}\n"   subject)
               (format "\\def\\NotesSubtitle{%s}\n"  subtitle)
               (format "\\NotesTOC%s\n"              (if toc        "true" "false"))
               (format "\\NotesGlossary%s\n"         (if glossary   "true" "false"))
               (format "\\NotesTodo%s\n"             (if todo       "true" "false"))
               (format "\\NotesDraft%s\n"            (if draft      "true" "false"))
               (format "\\NotesWideTitles%s\n"       (if widetitles "true" "false"))
               (format "\\NotesTitlePage%s\n"        (if titlepage  "true" "false"))
               "\\begin{document}")))
        (replace-regexp-in-string
         "\\\\begin{document}"
         settings
         output
         t
         t))))

  (add-hook 'org-export-filter-final-output-functions
            #'my/org-latex-notes-filter))
;; $\LaTeX$ Templates:1 ends here

;; [[file:emacs.org::*Literate C projects][Literate C projects:1]]
(require 'cl-lib)
      (require 'ob-C)
      (require 'ox-ascii)

      ;; ─── :function / :arguments execution ───────────────────────────────────────
      ;;
      ;; Appends a generated main() to a C block that defines a function, so it can
      ;; be evaluated without writing a test harness by hand.
      ;;
      ;; Usage:
      ;;   #+begin_src C :function add :arguments 2, 3 :results output :tangle no
      ;;   #include <stdio.h>
      ;;   int add(int a, int b) { printf("%d\n", a + b); return a + b; }
      ;;   #+end_src
      ;;
      ;; :arguments is a raw C argument list — any valid C expressions, comma-separated.

      (defun my/org-c--execute-function (original body params)
        (let ((fn   (cdr (assq :function  params)))
              (args (cdr (assq :arguments params))))
          (if (and fn args)
              (funcall original
                       (concat body
                               "\nint main(void)\n{\n    "
                               fn "(" (string-trim args) ");\n"
                               "    return 0;\n}\n")
                       params)
            (funcall original body params))))

      (advice-add 'org-babel-execute:C :around #'my/org-c--execute-function)

      ;; ─── :c_comment: prose-to-comment tangling ───────────────────────────────────
      ;;
      ;; my/org-tangle-c-project runs org-babel-tangle and then prepends a /*...*/
      ;; comment to each tangled C file whose source heading carries the :c_comment:
      ;; tag.  The comment text is the plain-text rendering of every paragraph that
      ;; appears directly under that heading, before its first C source block.
      ;; The heading title, property drawer, and any nested subheadings are excluded.
      ;;
      ;; Rules:
      ;;   - The tagged heading must contain at least one direct C block.
      ;;   - That block must have an explicit :tangle FILE target (not "yes" or "no"),
      ;;     either on the block itself or inherited from a property drawer.
      ;;   - At most one :c_comment: heading may target each output file.

      (defun my/org-c--section (headline)
        "Return the section node directly under HEADLINE, or nil."
        (cl-find-if (lambda (n) (eq (org-element-type n) 'section))
                    (org-element-contents headline)))

      (defun my/org-c--direct-c-block (section)
        "Return the first direct C src-block child of SECTION, or nil."
        (cl-find-if (lambda (n)
                      (and (eq (org-element-type n) 'src-block)
                           (string= (org-element-property :language n) "C")))
                    (org-element-contents section)))

    (defun my/org-c--prose-before (section block)
     "Return plain text of paragraphs in SECTION that precede BLOCK."
     (let ((org-text
            (mapconcat
             #'org-element-interpret-data
             (cl-loop for node in (org-element-contents section)
                      until (eq node block)
                      when  (eq (org-element-type node) 'paragraph)
                      collect node)
             "\n")))
       (string-trim
        (org-export-string-as org-text 'ascii nil
                              '(:with-title nil
                                :with-toc   nil
                                :with-tags  nil
                                :ascii-paragraph-spacing 0)))))

  (defun my/org-c--prose-before (section block)
    "Return plain text of paragraphs in SECTION that precede BLOCK."
    (let ((org-text
           (mapconcat
            #'org-element-interpret-data
            (cl-loop for node in (org-element-contents section)
                     until (eq node block)
                     when  (eq (org-element-type node) 'paragraph)
                     collect node)
            "\n")))
      (with-temp-buffer
        (string-trim
         (org-export-string-as org-text 'ascii nil
                               '(:with-title nil
                                 :with-toc   nil
                                 :with-tags  nil
                                 :ascii-paragraph-spacing 0))))))

  (defun my/org-c--format-comment (text)
    "Format TEXT as a /* ... */ block comment."
    (concat "/*\n"
            (mapconcat (lambda (line) (concat " * " line))
                       (split-string text "\n")
                       "\n")
            "\n */"))

  
(defun my/org-c--tangle-target (block)
  "Return the absolute tangle path for BLOCK, or nil if not tangled."
  (save-excursion
    (goto-char (org-element-property :begin block))
    (let ((target (cdr (assq :tangle (nth 2 (org-babel-get-src-block-info 'light))))))
      (cond
       ((or (null target) (string= target "no"))  nil)
       ((string= target "yes")
        (user-error "Use an explicit :tangle filename for :c_comment: headings"))
       (t (expand-file-name target (file-name-directory (buffer-file-name))))))))

(defun my/org-c--format-comment (text)
  "Format TEXT as a /* ... */ block comment."
  (concat "/*\n"
          (mapconcat (lambda (line) (concat " * " line))
                     (split-string text "\n")
                     "\n")
          "\n */"))

(defun my/org-c--collect-comments ()
  "Return an alist of (FILE . COMMENT) for every :c_comment: heading."
  (let (result)
    (org-element-map (org-element-parse-buffer) 'headline
      (lambda (headline)
        (when (member "c_comment" (org-element-property :tags headline))
          (let* ((title   (org-element-property :raw-value headline))
                 (section (my/org-c--section headline))
                 (block   (and section (my/org-c--direct-c-block section)))
                 (prose   (and section block
                               (my/org-c--prose-before section block)))
                 (file    (and block (my/org-c--tangle-target block))))
            (unless block
              (user-error ":c_comment: heading has no direct C block: %s" title))
            (unless file
              (user-error ":c_comment: heading has no :tangle target: %s" title))
            (when (assoc file result)
              (user-error "Two :c_comment: headings target the same file: %s" file))
            (when (and prose (not (string-empty-p prose)))
              (push (cons file (my/org-c--format-comment prose)) result))))))
    result))

(defun my/org-tangle-c-project ()
  "Tangle the current Org file and prepend :c_comment: prose as C comments."
  (interactive)
  (unless buffer-file-name
    (user-error "Save the Org file before tangling"))
  (let ((comments (my/org-c--collect-comments)))
    (org-babel-tangle)
    (pcase-dolist (`(,file . ,comment) comments)
      (unless (file-exists-p file)
        (user-error "Expected tangled file not found: %s" file))
      (with-temp-buffer
        (insert-file-contents file)
        (goto-char (point-min))
        (insert comment "\n\n")
        (write-region (point-min) (point-max) file nil 'silent)))))

(my-leader-def 'normal org-mode-map
  "mt"  '("Tangle"         . (keymap))
  "mtp" '("Tangle project" . my/org-tangle-c-project))
;; Literate C projects:1 ends here

;; [[file:emacs.org::*School sessions][School sessions:1]]
(require 'seq)

(defvar my/school-root (expand-file-name "~/Documents/School/"))

(defun my/school-notes-header ()
  (concat
   "#+title: ${1:`(read-string \"Title: \" (format-time-string \"%Y-%m-%d\"))`}\n"
   "#+author: ${2:`(read-string \"Author: \" user-full-name)`}\n"
   "#+date: `(format-time-string \"%Y-%m-%d\")`\n"
   "#+subject: %SUBJECT%\n"
   "#+latex_class: notes\n"
   "#+export_file_name: document/notes\n\n"
   "#+notes_toc: false\n"
   "#+notes_glossary: false\n"
   "#+notes_todo: false\n"
   "#+isdraft: true\n"
   "#+notes_titlepage: false\n"))

(defun my/school-notes-template ()
  (concat
   (my/school-notes-header)
   "\n* ${3:Notes}\n\n$0"))

(defun my/school-python-notes-template ()
  (concat
   (my/school-notes-header)
   "\n* ${3:Notes}\n\n"
   "* Code\n\n"
   "#+begin" "_src python :tangle code/main.py :mkdirp yes\n"
   "$0\n"
   "#+end" "_src"))

(defvar my/school-templates
  '(("Notes" . my/school-notes-template)
    ("Python notes" . my/school-python-notes-template)))

(defun my/school-subjects ()
  (when (file-directory-p my/school-root)
    (seq-filter
     (lambda (name)
       (file-directory-p (expand-file-name name my/school-root)))
     (directory-files my/school-root nil directory-files-no-dot-files-regexp))))

(defun my/school-read-subject ()
  (let ((subject
         (string-trim
          (completing-read "Subject: " (my/school-subjects) nil nil))))
    (when (or (string-empty-p subject)
              (string-match-p "[/\\\\]" subject))
      (user-error "Subject must be non-empty and contain no path separator"))
    subject))

(defun my/school-read-template ()
  (completing-read "Template: " (mapcar #'car my/school-templates) nil t))

(defun my/school-template-body (template subject)
  (replace-regexp-in-string
   "%SUBJECT%"
   subject
   (funcall (alist-get template my/school-templates nil nil #'string=))
   t
   t))

(defun my/school-session ()
  (interactive)
  (let* ((subject (my/school-read-subject))
         (template (my/school-read-template))
         (directory
          (expand-file-name
           (concat subject "/" (format-time-string "%y-%m-%d") "/")
           my/school-root))
         (notes-file (expand-file-name "notes.org" directory)))
    ;; Should be created automatically
    ;;(make-directory (expand-file-name "code" directory) t)
    (make-directory (expand-file-name "document" directory) t)
    (find-file notes-file)
    (when (= (buffer-size) 0)
      (yas-expand-snippet
       (my/school-template-body template subject)))))

(my-leader-def 'normal 'global
  "n" '("Notes" . (keymap))
  "n n" '("New school session" . my/school-session))
;; School sessions:1 ends here

;; [[file:emacs.org::*PDF Reader][PDF Reader:1]]
(use-package reader
  :ensure nil)
;; PDF Reader:1 ends here

;; [[file:emacs.org::*LSP][LSP:1]]
; Set nil as an addon
  (use-package lsp-mode
   :init
  ;(setq lsp-keymap-prefix "C-c l")
   (setq lsp-completion-provider :none)

   :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
          (rust-mode . lsp)
          (slint-mode . lsp)
          (nix-mode . lsp)
          (c-mode . lsp)
          ;; if you want which-key integration
          (lsp-mode . lsp-enable-which-key-integration))
   :commands lsp
   :config
   (my-leader-def 
     :states '(normal)
     :keymaps 'lsp-mode-map
     "l" '("LSP" . (keymap))
     "l w" '("Workspaces" . (keymap))
     "l w s" '("Start Server" . lsp)
     "l w r" '("Restart Server" . lsp-workspace-restart)
     "l w q" '("Shutdown Server" . lsp-workspace-shutdown)
     "l w d" '("Describe Session" . lsp-describe-session)
     "l w D" '("Disconnect Buffer From Server" . lsp-disconnect)
     "l =" '("Format" . (keymap))
     "l = =" '("Format Buffer" . lsp-format-buffer)
     "l = r" '("Format Region" . lsp-format-region)
     "l F" '("Folders" . (keymap))
     "l F a" '("Add To Workspaces" . lsp-workspace-folders-add)
     "l F r" '("Remove From Workspaces" . lsp-workspace-folders-remove)
     "l F b" '("Remove From Workspace Blocklist" . lsp-workspace-blocklist-remove)
     "l T" '("Toggle" . (keymap))
     "l T l" '("Toggle Lenses" . lsp-lens-mode)
     "l T L" '("Toggle Log IO" . lsp-toggle-trace-io)
     "l T h" '("Toggle Highlighting" . lsp-toggle-symbol-highlight)
     "l T S" '("Toggle Sideline" . lsp-ui-sideline-mode)
     "l T d" '("Toggle Docs pop-up" . lsp-ui-doc-mode)
     "l T s" '("Toggle Signature" . lsp-toggle-signature-auto-activate)
     "l T f" '("Toggle On Type Formatting" . lsp-toggle-on-type-formatting)
     "l T T" '("Toggle Treemacs Integration" . lsp-treemacs-sync-mode)
     "l g" '("Goto" . (keymap))
     "l g a" '("Find Symbol In Workspace" . xref-find-apropos)
     "l g d" '("Find Declarations" . lsp-find-declaration)
     "l g e" '("Show Errors" . lsp-treemacs-errors-list)
     "l g g" '("Find Definitions" . lsp-find-definition)
     "l g h" '("Call Hierarchy" . lsp-treemacs-call-hierarchy)
     "l g i" '("Find Implementations" . lsp-find-implementation)
     "l g r" '("Find References" . lsp-find-references)
     "l g t" '("Find Type Definition" . lsp-find-type-definition)
     "l h" '("Help" . (keymap))
     "l h g" '("Glance Symbol" . lsp-ui-doc-glance)
     "l h h" '("Describe Symbol At Point" . lsp-describe-thing-at-point)
     "l h s" '("Signature Help" . lsp-signature-activate)
     "l r" '("Refactor" . (keymap))
     "l r r" '("Rename" . lsp-rename)
     "l r o" '("Organize Imports" . lsp-organize-imports)
     "l a" '("Code Actions" . (keymap))
     "l a a" '("Code Actions" . lsp-execute-code-action)
     "l a h" '("Highlight Symbol" . lsp-document-highlight)
     "l G" '("Peek" . (keymap))
     "l G g" '("Peek Definitions" . lsp-ui-peek-find-definitions)
     "l G i" '("Peek Implementations" . lsp-ui-peek-find-implementation)
     "l G r" '("Peek References" . lsp-ui-peek-find-references)
     "l G s" '("Peek Workspace Symbol" . lsp-ui-peek-find-workspace-symbol)))

  ;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

  ;; optionally if you want to use debugger
(use-package dap-mode)
(use-package dap-gdb)
  ;; (use-package dap-LANGUAGE) to load the dap adapter for your language

  ;; optional if you want which-key integration
(use-package which-key
  :config
  (which-key-mode))
;; LSP:1 ends here

;; [[file:emacs.org::*Completion][Completion:1]]
(use-package corfu
   :ensure t
   :demand t
   :after yasnippet
   :general
   (:states 'insert :keymaps 'corfu-map
             "RET"     nil
             "TAB"     nil
             "C-j"     #'corfu-next
             "C-k"     #'corfu-previous
             "C-y"     #'corfu-insert
             "M-j"     #'corfu-scroll-down
             "M-k"     #'corfu-scroll-up
             "M-d"     #'corfu-info-documentation
             "M-l"     #'corfu-info-location
             "<escape>" #'corfu-quit)
   :init
   (setq corfu-auto t
         corfu-auto-delay 0
         corfu-auto-prefix 1
         corfu-quit-no-match 'separator
         corfu-popupinfo-delay 0
         text-mode-ispell-word-completion nil)
    
   :config
   (global-corfu-mode)
   (corfu-history-mode)
   (corfu-popupinfo-mode)
   (advice-add 'corfu--setup :after (lambda (&rest _) (evil-normalize-keymaps)))
   (advice-add 'corfu--teardown :after (lambda (&rest _) (evil-normalize-keymaps)))

   (define-key corfu-map (kbd "<RET>") nil))
;; Completion:1 ends here

;; [[file:emacs.org::*Completion][Completion:2]]
;; A few more useful configurations...
(use-package emacs
  :custom
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)
  (completion-cycle-threshold nil)      ; Always show all candidates in popup menu


  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p))
  ;; Add extensions
(use-package cape
  :bind ("C-c p" . cape-prefix-map)
  :after (corfu yasnippet)
  :init
  ;; Add merged CAPF for standard (non-LSP) buffers
  (add-hook 'completion-at-point-functions
            (cape-capf-super #'yasnippet-capf #'cape-history #'cape-file)
            -100) ; Higher priority
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  (add-hook 'completion-at-point-functions #'cape-keyword)
  (add-hook 'completion-at-point-functions #'cape-emoji)
  (add-hook 'completion-at-point-functions #'cape-dict)
  (add-hook 'completion-at-point-functions #'cape-history))
 ;(defun my/lsp-corfu-setup ()
 ;  (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
 ;        '(orderless))
 ;  (setq-local completion-at-point-functions
 ;              (list (cape-capf-super
 ;                     #'tempel-complete
 ;                     (cape-capf-noninterruptible #'lsp-completion-at-point)
 ;                     #'cape-dabbrev)
 ;                    #'cape-file)))
 ;(add-hook 'lsp-completion-mode-hook #'my/lsp-corfu-setup))
(defun my/lsp-corfu-setup ()
  (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
        '(orderless))
  (setq-local completion-at-point-functions
              (list (cape-capf-super
                     #'yasnippet-capf
                     #'lsp-completion-at-point
                     #'cape-dabbrev)
                    #'cape-file)))

(add-hook 'lsp-completion-mode-hook #'my/lsp-corfu-setup)
;; Completion:2 ends here

;; [[file:emacs.org::*Nix][Nix:1]]
(use-package nix-mode
  :mode "\\.nix\\'")
;; Nix:1 ends here

;; [[file:emacs.org::*Emacs lisp][Emacs lisp:1]]
(use-package parinfer-rust-mode
  :hook emacs-lisp-mode
  :init
  (setq parinfer-rust-auto-download t)
  (setq parinfer-rust-preferred-mode "paren")
  )
;; Emacs lisp:1 ends here

;; [[file:emacs.org::*Rust][Rust:1]]
(defun sp1ff/rust/mode-hook ()
  "My rust-mode hook"
  ;; Style per the Rust Style Guide:
  ;; <https://github.com/rust-lang-nursery/fmt-rfcs/blob/master/guide/guide.md>
  (setq dap-gdb-debug-program '("rust-gdb" "-i" "dap"))
  (setq indent-tabs-mode nil
        tab-width 4
        c-basic-offset 4
        fill-column 100))

(use-package rust-mode
  :ensure t
  :hook (rust-mode . sp1ff/rust/mode-hook)
  :config
  (let ((dot-cargo-bin (expand-file-name "@rust-toolchain@/bin/")))
    (setq rust-rustfmt-bin (concat dot-cargo-bin "rustfmt")
          rust-cargo-bin (concat dot-cargo-bin "cargo")
          rust-format-on-save nil))
  )
;; Rust:1 ends here

;; [[file:emacs.org::*Slint][Slint:1]]
(use-package slint-mode)
;; Slint:1 ends here

;; [[file:emacs.org::*Modern minibuffer packages][Modern minibuffer packages:1]]
;; The `vertico' package applies a vertical layout to the minibuffer.
;; It also pops up the minibuffer eagerly so we can see the available
;; options without further interactions.  This package is very fast
;; and "just works", though it also is highly customisable in case we
;; need to modify its behaviour.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:cff33514-d3ac-4c16-a889-ea39d7346dc5
(use-package vertico
  :ensure t
  :config
  (setq vertico-cycle t)
  (setq vertico-resize nil)
  (vertico-mode 1))

;; The `marginalia' package provides helpful annotations next to
;; completion candidates in the minibuffer.  The information on
;; display depends on the type of content.  If it is about files, it
;; shows file permissions and the last modified date.  If it is a
;; buffer, it shows the buffer's size, major mode, and the like.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:bd3f7a1d-a53d-4d3e-860e-25c5b35d8e7e
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

;; The `orderless' package lets the minibuffer use an out-of-order
;; pattern matching algorithm.  It matches space-separated words or
;; regular expressions in any order.  In its simplest form, something
;; like "ins pac" matches `package-menu-mark-install' as well as
;; `package-install'.  This is a powerful tool because we no longer
;; need to remember exactly how something is named.
;;
;; Note that Emacs has lots of "completion styles" (pattern matching
;; algorithms), but let us keep things simple.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:7cc77fd0-8f98-4fc0-80be-48a758fcb6e2
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)))

;; The `consult' package provides lots of commands that are enhanced
;; variants of basic, built-in functionality.  One of the headline
;; features of `consult' is its preview facility, where it shows in
;; another Emacs window the context of what is currently matched in
;; the minibuffer.  Here I define key bindings for some commands you
;; may find useful.  The mnemonic for their prefix is "alternative
;; search" (as opposed to the basic C-s or C-r keys).
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:22e97b4c-d88d-4deb-9ab3-f80631f9ff1d
(use-package consult
  :ensure t
  :config
  (my-leader-def
    :states '(normal)
    "f" '("Find" . (keymap))
    "f g" '("Recursive Grep" . 'consult-grep)
    "f f" '("Recursive File Name Search" . 'consult-find)
    "f o" '("Search Outline" . consult-outline)
    "f l" '("Grep Buffer" . consult-line)
    "f b" '("Find Buffer" . consult-buffer)))

  ;;:general ;; A recursive grep
  ;;("M-s M-g" 'consult-grep
  ;; ;; Search for files names recursively
  ;; "M-s M-f" 'consult-find
  ;; ;; search through the outline (headings) of the file
  ;; "M-s M-o" 'consult-outline
  ;; ;; Search the current buffer
  ;; "M-s M-l" 'consult-line
  ;; ;; Switch to another buffer, or bookmarked file, or recently
  ;; ;; opened file.
  ;; "M-s M-b" 'consult-buffer
  ;; "C-x b" 'consult-buffer))

;; The `embark' package lets you target the thing or context at point
;; and select an action to perform on it.  Use the `embark-act'
;; command while over something to find relevant commands.
;;
;; When inside the minibuffer, `embark' can collect/export the
;; contents to a fully fledged Emacs buffer.  The `embark-collect'
;; command retains the original behaviour of the minibuffer, meaning
;; that if you navigate over the candidate at hit RET, it will do what
;; the minibuffer would have done.  In contrast, the `embark-export'
;; command reads the metadata to figure out what category this is and
;; places them in a buffer whose major mode is specialised for that
;; type of content.  For example, when we are completing against
;; files, the export will take us to a `dired-mode' buffer; when we
;; preview the results of a grep, the export will put us in a
;; `grep-mode' buffer.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:61863da4-8739-42ae-a30f-6e9d686e1995
(use-package embark
  :ensure t
  :general
  (:states '(normal)
           "C-." 'embark-act)
   
  (:keymaps 'minibuffer-local-map
            "C-c C-c" #'embark-collect
            "C-c C-e" #'embark-export)
  :config
  (with-eval-after-load 'evil))
    
;;(define-key evil-normal-state-map (kbd "C-.") 'embark-act)
;;(define-key evil-visual-state-map (kbd "C-.") 'embark-act)
    ;;;; Add other states if necessary (insert, motion, etc.)
;;(evil-define-key 'normal 'global (kbd "C-.") 'embark-act)))


;; The `embark-consult' package is glue code to tie together `embark'
;; and `consult'.
(use-package embark-consult
  :ensure t)

;; The `wgrep' packages lets us edit the results of a grep search
;; while inside a `grep-mode' buffer.  All we need is to toggle the
;; editable mode, make the changes, and then type C-c C-c to confirm
;; or C-c C-k to abort.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:9a3581df-ab18-4266-815e-2edd7f7e4852
(use-package wgrep
  :ensure t
  :bind ( :map grep-mode-map
          ("e" . wgrep-change-to-wgrep-mode)
          ("C-x C-q" . wgrep-change-to-wgrep-mode)
          ("C-c C-c" . wgrep-finish-edit)))

;; The built-in `savehist-mode' saves minibuffer histories.  Vertico
;; can then use that information to put recently selected options at
;; the top.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:25765797-27a5-431e-8aa4-cc890a6a913a
(savehist-mode 1)

;; The built-in `recentf-mode' keeps track of recently visited files.
;; You can then access those through the `consult-buffer' interface or
;; with `recentf-open'/`recentf-open-files'.
;;
;; I do not use this facility, because the files I care about are
;; either in projects or are bookmarked.
(recentf-mode 1)
;; Modern minibuffer packages:1 ends here

;; [[file:emacs.org::*Direnv][Direnv:1]]
(use-package direnv
 :ensure t
 :config
 (direnv-mode))
;; Direnv:1 ends here
