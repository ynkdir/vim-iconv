" utf32le.h
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
" UTF-32LE
"

function iconv#utf32le#new()
  return s:utf32le.new()
endfunction

let s:utf32le = {}

function s:utf32le.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:utf32le.__init__()
  " pass
endfunction

function s:utf32le.mbtowc(mb)
  if len(a:mb) < 4
    throw "ICONV: RET_TOOFEW"
  endif
  let wc = a:mb[0] + (a:mb[1] * 0x100) + (a:mb[2] * 0x10000) + (a:mb[3] * 0x1000000)
  if wc >= 0 && wc < 0x110000 && !(wc >= 0xd800 && wc < 0xe000)
    return [4, [wc]]
  else
    throw "ICONV: RET_ILSEQ"
  endif
endfunction

function s:utf32le.wctomb(wc)
  if a:wc >= 0 && a:wc < 0x110000 && !(a:wc >= 0xd800 && a:wc < 0xe000)
    return [a:wc % 0x100, a:wc / 0x100 % 0x100, a:wc / 0x10000 % 0x100, 0]
  endif
  throw "ICONV: RET_ILUNI"
endfunction

function s:utf32le.flush()
  return []
endfunction

