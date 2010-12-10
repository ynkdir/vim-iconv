" utf16.h
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
" UTF-16
"

function iconv#utf16#new()
  return s:utf16.new()
endfunction

let s:utf16 = {}

let s:utf16.istate = 0
let s:utf16.ostate = 0

function s:utf16.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:utf16.__init__()
  let self.istate = 0
  let self.ostate = 0
endfunction

function s:utf16.mbtowc(mb)
  if len(a:mb) < 2
    throw "ICONV: RET_TOOFEW"
  endif
  let wc = (self.istate ? a:mb[0] + (a:mb[1] * 0x100) : (a:mb[0] * 0x100) + a:mb[1])
  if wc == 0xfeff
    return [2, []]
  elseif wc == 0xfffe
    let self.istate = !self.istate
    return [2, []]
  elseif wc >= 0xd800 && wc < 0xdc00
    if len(a:mb) < 4
      throw "ICONV: RET_TOOFEW"
    endif
    let wc2 = (self.istate ? a:mb[2] + (a:mb[3] * 0x100) : (a:mb[2] * 0x100) + a:mb[3])
    if !(wc2 >= 0xdc00 && wc2 < 0xe000)
      throw "ICONV: RET_SHIFT_ILSEQ"
    endif
    let pwc = 0x10000 + ((wc - 0xd800) * 0x400) + (wc2 - 0xdc00)
    return [4, [pwc]]
  elseif wc >= 0xdc00 && wc < 0xe000
    throw "ICONV: RET_SHIFT_ILSEQ"
  else
    return [2, [wc]]
  endif
endfunction

function s:utf16.wctomb(wc)
  let res = []
  if a:wc != 0xfffe && !(a:wc >= 0xd800 && a:wc < 0xe000)
    if !self.ostate
      call add(res, 0xFE)
      call add(res, 0xFF)
    endif
    if a:wc < 0x10000
      call add(res, a:wc / 0x100)
      call add(res, a:wc % 0x100)
      let self.ostate = 1
      return res
    elseif a:wc < 0x110000
      let wc1 = 0xd800 + ((a:wc - 0x10000) / 0x400)
      let wc2 = 0xdc00 + ((a:wc - 0x10000) % 0x400)
      call add(res, wc1 / 0x100)
      call add(res, wc1 % 0x100)
      call add(res, wc2 / 0x100)
      call add(res, wc2 % 0x100)
      let self.ostate = 1
      return res
    endif
  endif
  throw "ICONV: RET_ILUNI"
endfunction

function s:utf16.flush()
  return []
endfunction

