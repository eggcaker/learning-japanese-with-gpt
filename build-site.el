;;; build-site.el  -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 eggcaker
;;
;; Author: eggcaker <eggcaker@gmail.com>
;; Maintainer: eggcaker <eggcaker@gmail.com>
;; Created: April 30, 2023
;; Modified: April 30, 2023
;; Version: 0.0.1
;; Keywords: Symbol’s value as variable is void: finder-known-keywords
;; Homepage: https://github.com/eggcaker/build-site
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;
;;
;;; Code:

(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(
                         ("melpa" . "https://melpa.org/packages/")
                         ("nongnu-melpa" . "https://elpa.nongnu.org/nongnu/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ))

(add-to-list 'load-path (concat default-directory "./assets/lisp/"))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'org)
(package-install 'htmlize)

(require 'org)
(require 'htmlize)
(require 'ox-publish)
(require 'ox-html)

(org-babel-do-load-languages
 (quote org-babel-load-languages)
 (quote ((emacs-lisp . t)
         (ditaa . t)
         (python . t)
         (shell . t)
         (js . t)
         ;;(abc . t)
         (org . t)
         (plantuml . t)
         )))

(setq org-plantuml-exec-mode 'jar)
(setq plantuml-default-exec-mode 'jar)
(setq org-plantuml-executable-args '("-charset=UTF-8"))
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-selection-coding-system 'utf-16-le)
(set-keyboard-coding-system 'utf-8)
(set-language-environment "UTF-8")

(setq default-buffer-file-coding-system 'utf-8)
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; Load the publishing system
;; <!--<link rel=\"stylesheet\" href=\"https://cdn.simplecss.org/simple.min.css\" />
;; Customize the HTML output
(setq org-html-validation-link nil            ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      emacs-cc-html-head "<link rel=\"stylesheet\" href=\"style.css\" type=\"text/css\"/>"
      emacs-cc-html-preamble " <span id=\"table-of-content\"><h2 class=\"brand\"><a href=\"/learning-japanese-with-gpt\">HOME</a></h2></span>"
      emacs-cc-html-postamble (concat "<footer> <div class=\"generated\"> &copy; " (format-time-string "%Y" (current-time)) " <a href=\"/pages/about\">TZ</a>, built with %c </div> </footer>")
      emacs-cc-comments-html-postamble (concat "<script src=\"https://utteranc.es/client.js\" repo=\"eggcaker/eggcaker.github.io\" issue-term=\"pathname\" theme=\"github-light\" crossorigin=\"anonymous\" async></script> <footer> <div class=\"generated\"> &copy; " (format-time-string "%Y" (current-time)) " <a href=\"/pages/about\">TZ</a>, built with %c  </div> </footer>")
      org-ditaa-jar-path (if (eq system-type 'windows-nt) "c:/temp/ditaa.jar" "/tmp/ditaa.jar")
      org-plantuml-jar-path  (if (eq system-type 'windows-nt) "c:/temp/plantuml.jar" "/tmp/plantuml.jar")
      org-export-babel-evaluate t
      org-confirm-babel-evaluate nil
      org-html-doctype "html5")

(defun cc/org-publish-org-sitemap(title list)
  "Sitemap generation function."
  (concat "#+TITLE: Sitemap\n\n"
          (org-list-to-subtree list)))

(defun cc/org-publish-org-sitemap-format-entry (entry style project)
  (cond ((not (directory-name-p entry))
         (let* ((date (org-publish-find-date entry project)))
           (format "%s - [[file:%s][%s]]"

                   (format-time-string "%F" date) entry
                   (org-publish-find-title entry project))))
        ((eq style 'tree)
         (file-name-nondirectory (directory-file-name entry)))
        (t entry)))


(defun templated-html-create-sitemap-xml (output directory base-url &rest regexp)
  (let* ((rx (or regexp "\\.html")))
    (with-temp-file output
      (insert "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<urlset
      xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\"
      xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
      xsi:schemaLocation=\"http://www.sitemaps.org/schemas/sitemap/0.9
            http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd\">\n")
      (cl-loop for file in (directory-files-recursively directory rx)
            do (insert (format "<url>\n <loc>%s/%s</loc>\n <priority>0.5</priority>\n</url>\n"
                               base-url (file-relative-name file directory))))
      (insert "</urlset>"))))

;; Define the publishing project
(setq org-publish-project-alist
      `(
        ("commentless"
         :recursive t
         :base-directory "./"
         :base-extension "org"
         :exclude "\\.org"
         :include ,'("index.org")
         :publishing-function org-html-publish-to-html
         :publishing-directory "./_site"
         :html-head ,emacs-cc-html-head
         :description "Learning some thing with GPT."
         :language en
         :with-date nil
         :with-title t
         :headline-levels 4
         :with-author nil
         :with-creator nil
         :with-toc t
         :section-numbers nil
         :html-postamble ,emacs-cc-html-postamble
         :auto-sitemap nil
         :htmlized-source t
         :html-doctype "html5"
         :html-html5-fancy t
         :time-stamp-file t)


("lessons"
         :recursive t
         :base-directory "./lessons"
         :base-extension "org"
         :exclude "rss\\.org\\|sitemap\\.org\\|index\\.org\\|blogs\\.org"
         :publishing-function org-html-publish-to-html
         :publishing-directory "./_site"
         :html-head ,emacs-cc-html-head
         :description "This is my personal website, a place where to me to write anything I want."
         :language en
         :with-date nil
         :with-title t
         :headline-levels 4
         :with-author nil
         :with-creator nil
         :with-toc nil
         :section-numbers nil
         :html-preamble ,emacs-cc-html-preamble
         :html-postamble  ,emacs-cc-comments-html-postamble
         :auto-sitemap nil
         :sitemap-sort-files anti-chronologically
         :sitemap-format-entry cc/org-publish-org-sitemap-format-entry
         :htmlized-source t
         :html-doctype "html5"
         :html-html5-fancy t
         :sitemap-title "Learning Japanese with ChatGPT"
         :time-stamp-file t)

        ("images"
         :recursive t
         :base-directory "./lessons/images"
         :base-extension "txt\\|jpg\\|gif\\|png"
         :publishing-directory "./_site/images/"
         :publishing-function org-publish-attachment)

        ("static"
         :recursive nil
         :base-directory "./assets"
         :include ,'("style.css")
         :publishing-directory "./_site"
         :publishing-function org-publish-attachment)

        ))

(org-publish-all t)

(message "Build complete!")
;;; build-site.el ends here
