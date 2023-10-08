" Copyright (C) 2023 Hefeweizen (https://github.com/Hefeweizen)
" Permission to copy and modify is granted under the Apace License 2.0
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Usage:  set marks a & b in the position that you want the ToC.
" Then, `:source table-of-contents.vim` (or whatever you've named this file)
"
" Only headers below 'b will be pulled in.
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

normal 'ak
normal o## Table of Contents
silent 'b,$g/^#/co'a
silent 'a,'b!tac
silent 'a,'bs/# \(.*\)$/1. [\1]]\1/g
silent 'a,'bs/\]\(.*\)/\=tr(submatch(1),' ','-')/
silent 'a,'bs/^#//
silent 'a,'bs/#/   /g
silent 'a,'bs/://g
silent 'a,'bs/\]\(.*\)/](#\1)/
silent 'a,'bs/[\.!?])$/)/
normal 'a
