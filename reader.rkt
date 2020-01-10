#lang racket

(require brag/support)
(require "parser.rkt")

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokeniser port)))
  (datum->syntax
   #f
   `(module gk-mod mr/expander ,parse-tree)))

(define (make-tokeniser port)
  (define (next-token)
    (define gk-lexer
      (lexer-srcloc
       [(from/stop-before "//" "\n") (token 'COMMENT lexeme #:skip? #t)]
       [(char-set " \t") (token 'WS lexeme #:skip? #t)]
       ["if" (token 'IF lexeme)]
       ["map" (token 'MAP lexeme)]
       ["while" (token 'WHILE lexeme)]
       ["halt" (token 'HALT lexeme)]
       ["->" (token 'ARROW lexeme)]
       ["." (token 'DOT lexeme)]
       [(concatenation "\""
                       (repetition 0 +inf.0 (union (char-complement (char-set "\"\n")) (concatenation "\\" "\"")))
                       "\"")
        (token 'STRING (trim-ends "\"" lexeme "\""))]
       [(repetition 1 +inf.0 (char-complement (char-set " \t\n\"->:{}"))) (token 'NAME lexeme)]
       [any-char lexeme]))
    (gk-lexer port))
  next-token)

(provide read-syntax)
