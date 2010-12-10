" utf16le.h
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
" UTF-16LE
"

function iconv#utf16le#new()
  return s:utf16le.new()
endfunction

let s:utf16le = {}

function s:utf16le.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:utf16le.__init__()
  " pass
endfunction

function s:utf16le.mbtowc(mb)
  if len(a:mb) < 2
    throw "ICONV: RET_TOOFEW"
  endif
  let wc = a:mb[0] + (a:mb[1] * 0x100)
  if wc >= 0xd800 && wc < 0xdc00
    if len(a:mb) < 4
      throw "ICONV: RET_TOOFEW"
    endif
    let wc2 = a:mb[2] + (a:mb[3] * 0x100)
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

function s:utf16le.wctomb(wc)
  if !(a:wc >= 0xd800 && a:wc < 0xe000)
    if a:wc < 0x10000
      return [a:wc % 0x100, a:wc / 0x100]
    elseif a:wc < 0x110000
      let wc1 = 0xd800 + ((a:wc - 0x10000) / 0x400)
      let wc2 = 0xdc00 + ((a:wc - 0x10000) % 0x400)
      return [wc1 % 0x100, wc1 / 0x100, wc2 % 0x100, wc2 / 0x100]
    endif
  endif
  throw "ICONV: RET_ILUNI"
endfunction

function s:utf16le.flush()
  return []
endfunction

