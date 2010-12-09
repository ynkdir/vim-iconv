" iso8859_14.h
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
" ISO-8859-14
"

function iconv#iso8859_14#new()
  return s:iso8859_14.new()
endfunction

let s:iso8859_14 = {}

function s:iso8859_14.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:iso8859_14.__init__()
  " pass
endfunction

function s:iso8859_14.mbtowc(mb)
  let c = a:mb[0]
  if c >= 0xa0
    return [1, [self.iso8859_14_2uni[c-0xa0]]]
  else
    return [1, [c]]
  endif
endfunction

function s:iso8859_14.wctomb(wc)
  if a:wc < 0x00a0
    return [a:wc]
  elseif a:wc >= 0x00a0 && a:wc < 0x0100
    let c = self.iso8859_14_page00[a:wc-0x00a0]
  elseif a:wc >= 0x0108 && a:wc < 0x0128
    let c = self.iso8859_14_page01_0[a:wc-0x0108]
  elseif a:wc >= 0x0170 && a:wc < 0x0180
    let c = self.iso8859_14_page01_1[a:wc-0x0170]
  elseif a:wc >= 0x1e00 && a:wc < 0x1e88
    let c = self.iso8859_14_page1e_0[a:wc-0x1e00]
  elseif a:wc >= 0x1ef0 && a:wc < 0x1ef8
    let c = self.iso8859_14_page1e_1[a:wc-0x1ef0]
  endif
  if c != 0
    return [c]
  endif
  throw 'ICONV: RET_ILUNI'
endfunction

function s:iso8859_14.flush()
  return []
endfunction

let s:iso8859_14.iso8859_14_2uni = [
\
\ 0x00a0, 0x1e02, 0x1e03, 0x00a3, 0x010a, 0x010b, 0x1e0a, 0x00a7,
\ 0x1e80, 0x00a9, 0x1e82, 0x1e0b, 0x1ef2, 0x00ad, 0x00ae, 0x0178,
\
\ 0x1e1e, 0x1e1f, 0x0120, 0x0121, 0x1e40, 0x1e41, 0x00b6, 0x1e56,
\ 0x1e81, 0x1e57, 0x1e83, 0x1e60, 0x1ef3, 0x1e84, 0x1e85, 0x1e61,
\
\ 0x00c0, 0x00c1, 0x00c2, 0x00c3, 0x00c4, 0x00c5, 0x00c6, 0x00c7,
\ 0x00c8, 0x00c9, 0x00ca, 0x00cb, 0x00cc, 0x00cd, 0x00ce, 0x00cf,
\
\ 0x0174, 0x00d1, 0x00d2, 0x00d3, 0x00d4, 0x00d5, 0x00d6, 0x1e6a,
\ 0x00d8, 0x00d9, 0x00da, 0x00db, 0x00dc, 0x00dd, 0x0176, 0x00df,
\
\ 0x00e0, 0x00e1, 0x00e2, 0x00e3, 0x00e4, 0x00e5, 0x00e6, 0x00e7,
\ 0x00e8, 0x00e9, 0x00ea, 0x00eb, 0x00ec, 0x00ed, 0x00ee, 0x00ef,
\
\ 0x0175, 0x00f1, 0x00f2, 0x00f3, 0x00f4, 0x00f5, 0x00f6, 0x1e6b,
\ 0x00f8, 0x00f9, 0x00fa, 0x00fb, 0x00fc, 0x00fd, 0x0177, 0x00ff,
\]

let s:iso8859_14.iso8859_14_page00 = [
\ 0xa0, 0x00, 0x00, 0xa3, 0x00, 0x00, 0x00, 0xa7,
\ 0x00, 0xa9, 0x00, 0x00, 0x00, 0xad, 0xae, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb6, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7,
\ 0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf,
\ 0x00, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0x00,
\ 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0x00, 0xdf,
\ 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7,
\ 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef,
\ 0x00, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0x00,
\ 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0x00, 0xff,
\]

let s:iso8859_14.iso8859_14_page01_0 = [
\ 0x00, 0x00, 0xa4, 0xa5, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0xb2, 0xb3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\]

let s:iso8859_14.iso8859_14_page01_1 = [
\ 0x00, 0x00, 0x00, 0x00, 0xd0, 0xf0, 0xde, 0xfe,
\ 0xaf, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\]

let s:iso8859_14.iso8859_14_page1e_0 = [
\ 0x00, 0x00, 0xa1, 0xa2, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0xa6, 0xab, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0xb4, 0xb5, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb7, 0xb9,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0xbb, 0xbf, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0xd7, 0xf7, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0xa8, 0xb8, 0xaa, 0xba, 0xbd, 0xbe, 0x00, 0x00,
\]

let s:iso8859_14.iso8859_14_page1e_1 = [
\ 0x00, 0x00, 0xac, 0xbc, 0x00, 0x00, 0x00, 0x00,
\]
