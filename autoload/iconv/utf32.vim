" utf32.h
"
" Copyright (C) 1999-2001, 2008 Free Software Foundation, Inc.
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
" UTF-32
"

function iconv#utf32#new()
  return s:utf32.new()
endfunction

let s:utf32 = {}

let s:utf32.istate = 0
let s:utf32.ostate = 0

function s:utf32.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:utf32.__init__()
  let self.istate = 0
  let self.ostate = 0
endfunction

function s:utf32.mbtowc(mb)
  if len(a:mb) < 4
    throw "ICONV: RET_TOOFEW"
  endif
  let wc = self.istate
        \ ? a:mb[0] + (a:mb[1] * 0x100) + (a:mb[2] * 0x10000) + (a:mb[3] * 0x1000000)
        \ : (a:mb[0] * 0x1000000) + (a:mb[1] * 0x10000) + (a:mb[2] * 0x100) + a:mb[3]
  if wc == 0x0000feff
    return [4, []]
  elseif wc == 0xfffe0000
    let self.istate = !self.istate
    return [4, []]
  else
    if wc >= 0 && wc < 0x110000 && !(wc >= 0xd800 && wc < 0xe000)
      return [4, [wc]]
    else
      throw "ICONV: RET_SHIFT_ILSEQ"
    endif
  endif
endfunction

function s:utf32.wctomb(wc)
  let res = []
  if a:wc >= 0 && a:wc < 0x110000 && !(a:wc >= 0xd800 && a:wc < 0xe000)
    if !self.ostate
      call add(res, 0x00)
      call add(res, 0x00)
      call add(res, 0xFE)
      call add(res, 0xFF)
    endif
    if a:wc >= 0 && a:wc < 0x110000
      call add(res, 0x00)
      call add(res, a:wc / 0x10000 % 0x100)
      call add(res, a:wc / 0x100 % 0x100)
      call add(res, a:wc % 0x100)
      let self.ostate = 1
      return res
    endif
  endif
  throw "ICONV: RET_ILUNI"
endfunction

function s:utf32.flush()
  return []
endfunction

