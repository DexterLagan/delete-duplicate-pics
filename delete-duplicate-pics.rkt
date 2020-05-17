#lang racket/gui

;;; purpose

; to delete duplicate Jpeg files created upon import from camera cards by Adobe Bridge

;;; versions

; v1.0 - initial release.

;;; consts

(define *version* "1.0")
(define *app-name* (string-append "Duplicate Pictures Remover v" *version*))

;;; defs

(define (msg-box msg)
  (void (message-box *app-name* (string-append msg " "))))

(define (confirm? msg)
  (message-box *app-name* (string-append msg " ") #f (list 'yes-no)))

(define (duplicate-pic? f)
  (regexp-match #rx" \\([1-9]\\)\\.[jpg|JPG]" (path->string f)))

;;; main

; ask user or use Camera Roll as default
(define camera-roll-path (build-path (find-system-path 'home-dir) "Pictures\\Camera Roll"))
(define search-path  
  (if (eq? 'yes (confirm? "Use Windows Camera Roll?"))
      camera-roll-path
      (get-directory "Please select pictures folder: " #f camera-roll-path)))
(unless search-path (exit 0))

; find duplicate files
(define duplicate-pics
  (find-files duplicate-pic? search-path))

; quit if no dupe found
(when (null? duplicate-pics)
  (msg-box "No duplicate found.")
  (exit 0))

; ask user for confirmation
(define answer
  (confirm? (string-append "Delete the following duplicates? \n"
                           (string-join (map path->string duplicate-pics) "\n"))))
(if (eq? answer 'yes)
    (begin (for-each delete-file duplicate-pics)
           (msg-box "Duplicates deleted."))
    (msg-box "Nothing done."))


; EOF