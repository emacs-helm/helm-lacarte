;;; helm-lacarte.el --- helm interface to lacarte.el -*- lexical-binding: t -*-

;; Copyright (C) 2012 ~ 2017 Thierry Volpiatto <thierry.volpiatto@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This package needs lacarte.el available at
;; http://www.emacswiki.org/cgi-bin/wiki/download/lacarte.el.
;;
;; WARNING: Downloading packages from Emacswiki is UNSAFE as anybody
;; could have modified source code, so it is up to you to verify
;; lacarte.el contains safe source code.

(require 'lacarte)
(require 'helm-misc)
      
;;; Code:

(defun helm-lacarte-candidate-transformer (cands)
  (mapcar (lambda (cand)
            (let* ((item (car cand))
                   (match (string-match "[^>] \\((.*)\\)$" item)))
              (when match
                (put-text-property (match-beginning 1) (match-end 1)
                                   'face 'helm-M-x-key item))
              cand))
          cands))

(defclass helm-lacarte (helm-source-sync helm-type-command)
    ((candidates :initform 'helm-lacarte-get-candidates)
     (candidate-transformer :initform 'helm-lacarte-candidate-transformer)
     (candidate-number-limit :initform 9999)))

(defun helm-lacarte-get-candidates (&optional maps)
  "Extract candidates for menubar using lacarte.el.

Optional argument MAPS is a list specifying which keymaps to use: it
can contain the symbols `local', `global', and `minor', mean the
current local map, current global map, and all current minor maps."
  (with-helm-current-buffer
    ;; When a keymap doesn't have a [menu-bar] entry
    ;; the filtered map returned and passed to
    ;; `lacarte-get-a-menu-item-alist-22+' is nil, which
    ;; fails because this code is not protected for such case.
    (condition-case nil
        (lacarte-get-overall-menu-item-alist maps)
      (error nil))))

;;;###autoload
(defun helm-browse-menubar ()
  "Preconfigured helm to the menubar using lacarte.el."
  (interactive)
  (helm :sources (mapcar
                  (lambda (spec) (helm-make-source (car spec) 'helm-lacarte
                                   :candidates
                                   (lambda ()
                                     (helm-lacarte-get-candidates (cdr spec)))))
                  '(("Major Mode"  . (local))
                    ("Minor Modes" . (minor))
                    ("Global Map"  . (global))))
        :buffer "*helm lacarte*"))


(provide 'helm-lacarte)

;;; helm-lacarte.el ends here
