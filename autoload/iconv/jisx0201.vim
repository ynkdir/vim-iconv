" jisx0201.h
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
" JISX0201.1976-0
"

function iconv#jisx0201#new()
  return s:jisx0201.new()
endfunction

let s:jisx0201 = {}

function s:jisx0201.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:jisx0201.__init__()
  " pass
endfunction

function s:jisx0201.mbtowc(mb)
  let c = a:mb[0]
  if c < 0x80
    if c == 0x5c
      return [1, [0x00a5]]
    elseif c == 0x7e
      return [1, [0x203e]]
    else
      return [1, [c]]
    endif
  else
    if c >= 0xa1 && c < 0xe0
      return [1, [c + 0xfec0]]
    endif
  endif
  throw 'ICONV: RET_ILSEQ'
endfunction

function s:jisx0201.wctomb(wc)
  if a:wc < 0x0080 && !(a:wc == 0x5c || a:wc == 0x007e)
    return [a:wc]
  elseif a:wc == 0x00a5
    return [0x5c]
  elseif a:wc == 0x203e
    return [0x7e]
  elseif a:wc >= 0xff61 && a:wc < 0xffa0
    return [a:wc - 0xfec0]
  endif
  throw 'ICONV: RET_ILUNI'
endfunction

