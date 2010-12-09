" utf8.h
"
" Copyright (C) 1999-2001, 2004 Free Software Foundation, Inc.
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
" UTF-8
"

function iconv#utf8#new()
  return s:utf8.new()
endfunction

let s:utf8 = {}

function s:utf8.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:utf8.__init__()
  " pass
endfunction

function! s:utf8.CheckByte(c)
  return (a:c >= 0x80) && ((a:c - 0x80) < 0x40)
endfunction

function s:utf8.mbtowc(mb)
  let c = a:mb[0]

  if c < 0x80
    return [1, [c]]
  elseif c < 0xc2
    throw 'ICONV: RET_ILSEQ'
  elseif c < 0xe0
    if !(self.CheckByte(a:mb[1]))
      throw 'ICONV: RET_ILSEQ'
    endif
    let wc = ((c % 0x20)*0x40) + (a:mb[1]-0x80)
    return [2, [wc]]
  elseif c < 0xf0
    if !( self.CheckByte(a:mb[1]) && self.CheckByte(a:mb[2])
          \ && (c >= 0xe1 || a:mb[1] >= 0xa0) )
      throw 'ICONV: RET_ILSEQ'
    endif
    let wc = ((c % 0x10)*0x1000) + ((a:mb[1]-0x80)*0x40) + (a:mb[2]-0x80)
    return [3, [wc]]
  elseif c < 0xf8
    if !( self.CheckByte(a:mb[1]) && self.CheckByte(a:mb[2])
          \ && self.CheckByte(a:mb[3])
          \ && (c >= 0xf1 || a:mb[1] >= 0x90) )
      throw 'ICONV: RET_ILSEQ'
    endif
    let wc = ((c % 0x08)*0x40000) + ((a:mb[1]-0x80)*0x1000) +
          \ ((a:mb[2]-0x80)*0x40) + (a:mb[3]-0x80)
    return [4, [wc]]
  elseif c < 0xfc
    if !( self.CheckByte(a:mb[1]) && self.CheckByte(a:mb[2])
          \ && self.CheckByte(a:mb[3]) && self.CheckByte(a:mb[4])
          \ && (c >= 0xf9 || a:mb[1] >= 0x88) )
      throw 'ICONV: RET_ILSEQ'
    endif
    let wc = ((c % 0x04)*0x1000000) + ((a:mb[1]-0x80)*0x40000) +
          \ ((a:mb[2]-0x80)*0x1000) + ((a:mb[3]-0x80)*0x40) +
          \ (a:mb[4]-0x80)
    return [5, [wc]]
  elseif c < 0xfe
    if !( self.CheckByte(a:mb[1]) && self.CheckByte(a:mb[2])
          \ && self.CheckByte(a:mb[3]) && self.CheckByte(a:mb[4])
          \ && self.CheckByte(a:mb[5])
          \ && (c >= 0xfd || a:mb[1] >= 0x84) )
      throw 'ICONV: RET_ILSEQ'
    endif
    let wc = ((c % 0x02)*0x40000000) + ((a:mb[1]-0x80)*0x1000000) +
          \ ((a:mb[2]-0x80)*0x40000) + ((a:mb[3]-0x80)*0x1000) +
          \ ((a:mb[4]-0x80)*0x40) + (a:mb[5]-0x80)
    return [6, [wc]]
  else
    throw 'ICONV: RET_ILSEQ'
  endif
endfunction

function s:utf8.wctomb(wc)
  let cnt = 0
  if a:wc < 0x80
    let cnt = 1
  elseif a:wc < 0x800
    let cnt = 2
  elseif a:wc < 0x10000
    let cnt = 3
  elseif a:wc < 0x200000
    let cnt = 4
  elseif a:wc < 0x4000000
    let cnt = 5
  elseif a:wc <= 0x7fffffff
    let cnt = 6
  else
    throw 'ICONV: RET_ILUNI'
  endif

  let wc = a:wc
  let r = []
  if cnt >= 6
    call insert(r, 0x80 + (wc % 0x40))
    let wc = (wc / 0x40) + 0x4000000
  endif
  if cnt >= 5
    call insert(r, 0x80 + (wc % 0x40))
    let wc = (wc / 0x40) + 0x200000
  endif
  if cnt >= 4
    call insert(r, 0x80 + (wc % 0x40))
    let wc = (wc / 0x40) + 0x10000
  endif
  if cnt >= 3
    call insert(r, 0x80 + (wc % 0x40))
    let wc = (wc / 0x40) + 0x800
  endif
  if cnt >= 2
    call insert(r, 0x80 + (wc % 0x40))
    let wc = (wc / 0x40) + 0xc0
  endif
  if cnt >= 1
    call insert(r, wc)
  endif
  return r
endfunction

function s:utf8.flush()
  return []
endfunction

