" iso8859_1.h
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
" ISO-8859-1
"

function iconv#iso8859_1#new()
  return s:iso8859_1.new()
endfunction

let s:iso8859_1 = {}

function s:iso8859_1.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:iso8859_1.__init__()
  " pass
endfunction

function s:iso8859_1.mbtowc(mb)
  return [1, [a:mb[0]]]
endfunction

function s:iso8859_1.wctomb(wc)
  if a:wc < 0x0100
    return [a:wc]
  endif
  throw 'ICONV: RET_ILUNI'
endfunction

function s:iso8859_1.flush()
  return []
endfunction

