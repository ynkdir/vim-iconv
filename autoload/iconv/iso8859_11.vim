" iso8859_11.h
"
" Copyright (C) 1999-2004 Free Software Foundation, Inc.
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
" ISO-8859-11
"

function iconv#iso8859_11#new()
  return s:iso8859_11.new()
endfunction

let s:iso8859_11 = {}

function s:iso8859_11.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:iso8859_11.__init__()
  " pass
endfunction

function s:iso8859_11.mbtowc(mb)
  let c = a:mb[0]
  if c < 0xa1
    return [1, [c]]
  elseif c <= 0xfb && !(c >= 0xdb && c <= 0xde)
    return [1, [c + 0x0d60]]
  endif
  throw 'ICONV: RET_ILSEQ'
endfunction

function s:iso8859_11.wctomb(wc)
  if a:wc < 0x00a1
    return [a:wc]
  elseif a:wc >= 0x0e01 && a:wc <= 0x0e5b && !(a:wc >= 0x0e3b && a:wc <= 0x0e3e)
    return [a:wc-0x0d60]
  endif
  throw 'ICONV: RET_ILUNI'
endfunction

function s:iso8859_11.flush()
  return []
endfunction
