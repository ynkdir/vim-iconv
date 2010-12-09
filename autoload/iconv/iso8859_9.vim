" iso8859_9.h
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
" ISO-8859-9
"

function iconv#iso8859_9#new()
  return s:iso8859_9.new()
endfunction

let s:iso8859_9 = {}

function s:iso8859_9.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:iso8859_9.__init__()
  " pass
endfunction

function s:iso8859_9.mbtowc(mb)
  let c = a:mb[0]
  if c >= 0xd0
    return [1, [self.iso8859_9_2uni[c-0xd0]]]
  else
    return [1, [c]]
  endif
endfunction

function s:iso8859_9.wctomb(wc)
  if a:wc < 0x00d0
    return [a:wc]
  elseif a:wc >= 0x00d0 && a:wc < 0x0100
    let c = self.iso8859_9_page00[a:wc-0x00d0]
  elseif a:wc >= 0x0118 && a:wc < 0x0160
    let c = self.iso8859_9_page01[a:wc-0x0118]
  endif
  if c != 0
    return [c]
  endif
  throw 'ICONV: RET_ILUNI'
endfunction

function s:iso8859_9.flush()
  return []
endfunction

let s:iso8859_9.iso8859_9_2uni = [
\
\ 0x011e, 0x00d1, 0x00d2, 0x00d3, 0x00d4, 0x00d5, 0x00d6, 0x00d7,
\ 0x00d8, 0x00d9, 0x00da, 0x00db, 0x00dc, 0x0130, 0x015e, 0x00df,
\
\ 0x00e0, 0x00e1, 0x00e2, 0x00e3, 0x00e4, 0x00e5, 0x00e6, 0x00e7,
\ 0x00e8, 0x00e9, 0x00ea, 0x00eb, 0x00ec, 0x00ed, 0x00ee, 0x00ef,
\
\ 0x011f, 0x00f1, 0x00f2, 0x00f3, 0x00f4, 0x00f5, 0x00f6, 0x00f7,
\ 0x00f8, 0x00f9, 0x00fa, 0x00fb, 0x00fc, 0x0131, 0x015f, 0x00ff,
\]

let s:iso8859_9.iso8859_9_page00 = [
\ 0x00, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7,
\ 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0x00, 0x00, 0xdf,
\ 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7,
\ 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef,
\ 0x00, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7,
\ 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0x00, 0x00, 0xff,
\]

let s:iso8859_9.iso8859_9_page01 = [
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd0, 0xf0,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0xdd, 0xfd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xde, 0xfe,
\]

