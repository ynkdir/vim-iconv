" ascii.h
"
" Copyright (C) 1999-2001 Free Software Foundation, Inc.
" This file is part of the GNU LIBICONV Library.
"
" The GNU LIBICONV Library is free software; you can redistribute it
" and/or modify it under the terms of the GNU Library General Public
" License as published by the Free Software Foundation; either version 2
" of the License, or (at your option) any later version.
"
" The GNU LIBICONV Library is distributed in the hope that it will be
" useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
" Library General Public License for more details.
"
" You should have received a copy of the GNU Library General Public
" License along with the GNU LIBICONV Library; see the file COPYING.LIB.
" If not, write to the Free Software Foundation, Inc., 51 Franklin Street,
" Fifth Floor, Boston, MA 02110-1301, USA.
"

"
" ASCII
"

function iconv#ascii#new()
  return s:ascii.new()
endfunction

let s:ascii = {}

function s:ascii.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:ascii.__init__()
  " pass
endfunction

function s:ascii.mbtowc(mb)
  let c = a:mb[0]
  if c < 0x80
    return [1, [c]]
  endif
  throw 'ICONV: RET_ILSEQ'
endfunction

function s:ascii.wctomb(wc)
  if a:wc < 0x0080
    return [a:wc]
  endif
  throw 'ICONV: RET_ILUNI'
endfunction

function s:ascii.flush()
  return []
endfunction

