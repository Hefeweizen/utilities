" Copyright (C) 2023 Hefeweizen (https://github.com/Hefeweizen)
" Permission to copy and modify is granted under the Apace License 2.0
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Usage:  set marks a & b in the position that you want the ToC.  The marks
" should have at least one line between them.
" Then, `:source table-of-contents.vim` (or whatever you've named this file)
"
" Only headers below 'b will be pulled in.
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" zero current toc
silent 'a+1,'b-1d

" copy md headers to toc body
silent 'b,$g/^#\{2,} /co'a
silent 'a,'b!tac

" duplicate header text as we'll need a copy for the link
silent 'a,'bs/# \(.*\)$/1. [\1]]\1/g

" link can't have spaces; it needs to be snake-case
silent 'a,'bs/\]\(.*\)/\=tr(submatch(1),' ','-')/

" set indentation
silent 'a,'bs/^#//
silent 'a,'bs/#/   /g

" trim extra characters
silent 'a,'bs/://g
silent 'a,'bs/\]\(.*\)/](#\1)/
silent 'a,'bs/[\.!?])$/)/

" set toc header
normal 'a
normal o## Table of Contents
normal o
