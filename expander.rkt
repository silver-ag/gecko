#lang br

(require (for-syntax racket/list))

(define-macro (gk-module-begin PARSE-TREE)
  #'(#%module-begin PARSE-TREE))

(provide (rename-out (gk-module-begin #%module-begin)))

(define-syntax (program stx)
  ;(write
  (datum->syntax
   stx
   `(begin
      (define state "")
      (define subroutines (make-hash '()))
      (subroutine "print" (display (format "~a\n" state)))
      ,@(rest (syntax->datum stx))
      (display (format "~a\n" state)))));)

(define-syntax (transform stx)
  (define dtm (syntax->datum stx))
  (define from (if (equal? (length dtm) 2)
                   ""
                   (second dtm)))
  (define to (if (equal? (length dtm) 2)
                 (second dtm)
                 (third dtm)))
  (datum->syntax
   stx
   `(set! state (regexp-rewrite ,to (regexp-match ,from state)))))

(define-syntax (if-expr stx)
  (define dtm (syntax->datum stx))
  ;(write
  (datum->syntax
   stx
   `(if (regexp-match ,(second dtm) state)
        ,(third dtm)
        ,(fourth dtm))));)

(define-syntax (map-expr stx)
  (define dtm (syntax->datum stx))
  (define capture-rx (second dtm))
  (define transform (third dtm))
  (define construct (fourth dtm))
  ;(write
  (datum->syntax
   stx
   `(begin
      (define capture (regexp-match ,capture-rx state))
      (define mapped-capture
        (map (λ (group)
               (define old-state (string-append "" state))
               (set! state group)
               ,transform
               (define result state)
               (set! state old-state)
               result)
             capture))
      (set! state (regexp-rewrite ,construct mapped-capture)))));)

(define-syntax (while-expr stx)
  (define dtm (syntax->datum stx))
  (define test-rx (second dtm))
  (define transform (third dtm))
  ;(write
  (datum->syntax
   stx
   `(let ()
      (define (loop-func test-rx operation)
        (if (regexp-match test-rx state)
            (begin
              (operation)
              (loop-func test-rx operation))
            (values)))
      (loop-func ,test-rx (λ () ,transform)))));)

(define (regexp-rewrite to from-matches)
  ;(write from-matches)
  (define replaced
    (regexp-replace*
     "\\\\[0-9]"
     (if (list? from-matches)
         (foldl (λ (group group-no running)
                  (regexp-replace* (format "\\\\~a" group-no) running group))
                to
                (map (λ (x) (if x x "")) from-matches)
                (build-list (length from-matches) (λ (x) x)))
         to)
     ""))
  (if (regexp-match "\\\\@" replaced)
      (regexp-replace* "\\\\@" replaced (read-line))
      replaced))

(define-syntax (subroutine stx)
  (define dtm (syntax->datum stx))
  (datum->syntax
   stx
   `(hash-set! subroutines ,(second dtm) (λ () ,(third dtm)))))

(define-syntax (code-block stx)
  (datum->syntax
   stx
   `(begin ,@(rest (syntax->datum stx)))))

(define-syntax (invocation stx)
  (datum->syntax
   stx
   `((hash-ref subroutines ,(second (syntax->datum stx))))))

(define (regex-str str)
  (if (equal? str 'dot)
      ".*" ;; dot
      (string-append "^" str "$"))) ;; match entire line by default - todo, some way to not do this?

(define (to-string str)
  (if (equal? str 'dot)
      "\\0"
      str))

(define (dot d)
  'dot)

(define-syntax (halt stx)
  (datum->syntax stx
   `(begin
      (display (format "~a\n" state))
      (exit))))

(provide program
         transform
         if-expr
         map-expr
         while-expr
         regexp-rewrite
         subroutine
         invocation
         code-block
         regex-str
         to-string
         dot
         halt
         define cons exit format begin set! string-append regexp-match display if map λ write second third let values quote make-hash hash-set! hash-ref #%app #%top #%datum)
