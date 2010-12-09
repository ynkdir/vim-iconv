" iso8859_15.h
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
" ISO-8859-15
"

function iconv#iso8859_15#new()
  return s:iso8859_15.new()
endfunction

let s:iso8859_15 = {}

function s:iso8859_15.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:iso8859_15.__init__()
  " pass
endfunction

function s:iso8859_15.mbtowc(mb)
  let c = a:mb[0]
  if c >= 0xa0 && c < 0xc0
    return [1, [self.iso8859_15_2uni[c-0xa0]]]
  else
    return [1, [c]]
  endif
endfunction

function s:iso8859_15.wctomb(wc)
  if a:wc < 0x00a0
    return [a:wc]
  elseif a:wc >= 0x00a0 && a:wc < 0x00c0
    let c = self.iso8859_15_page00[a:wc-0x00a0]
  elseif a:wc >= 0x00c0 && a:wc < 0x0100
    let c = a:wc
  elseif a:wc >= 0x0150 && a:wc < 0x0180
    let c = self.iso8859_15_page01[a:wc-0x0150]
  elseif a:wc == 0x20ac
    let c = 0xa4
  endif
  if c != 0
    return [c]
  endif
  throw 'ICONV: RET_ILUNI'
endfunction

function s:iso8859_15.flush()
  return []
endfunction

let s:iso8859_15.iso8859_15_2uni = [
\
\ 0x00a0, 0x00a1, 0x00a2, 0x00a3, 0x20ac, 0x00a5, 0x0160, 0x00a7,
\ 0x0161, 0x00a9, 0x00aa, 0x00ab, 0x00ac, 0x00ad, 0x00ae, 0x00af,
\
\ 0x00b0, 0x00b1, 0x00b2, 0x00b3, 0x017d, 0x00b5, 0x00b6, 0x00b7,
\ 0x017e, 0x00b9, 0x00ba, 0x00bb, 0x0152, 0x0153, 0x0178, 0x00bf,
\]

let s:iso8859_15.iso8859_15_page00 = [
\ 0xa0, 0xa1, 0xa2, 0xa3, 0x00, 0xa5, 0x00, 0xa7,
\ 0x00, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
\ 0xb0, 0xb1, 0xb2, 0xb3, 0x00, 0xb5, 0xb6, 0xb7,
\ 0x00, 0xb9, 0xba, 0xbb, 0x00, 0x00, 0x00, 0xbf,
\]

let s:iso8859_15.iso8859_15_page01 = [
\ 0x00, 0x00, 0xbc, 0xbd, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0xa6, 0xa8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
\ 0xbe, 0x00, 0x00, 0x00, 0x00, 0xb4, 0xb8, 0x00,
\]

