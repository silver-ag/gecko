#lang brag

program: /"\n"* (@transformation /"\n"*)*
transformation: transform | if-expr | map-expr | while-expr | invocation | subroutine | code-block | halt
transform: [regex-str] /ARROW to-string
if-expr: /IF regex-str /"\n" @transformation /"\n" @transformation
map-expr: /MAP regex-str /"\n" @transformation /"\n" to-string
while-expr: /WHILE regex-str /"\n" @transformation
subroutine: NAME /":" /"\n"* code-block
code-block: /"{" @program /"}"
invocation: NAME
regex-str: STRING | dot
to-string: STRING | dot
dot: DOT
halt: HALT