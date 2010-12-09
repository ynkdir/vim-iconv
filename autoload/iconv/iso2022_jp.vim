" iso2022_jp.h
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
" ISO-2022-JP
"

function iconv#iso2022_jp#new()
  return s:iso2022_jp.new()
endfunction

let s:iso2022_jp = {}

let s:iso2022_jp.esc = 0x1b

let s:iso2022_jp.state_ascii = 0
let s:iso2022_jp.state_jisx0201roman = 1
let s:iso2022_jp.state_jisx0208 = 2

let s:iso2022_jp.istate = s:iso2022_jp.state_ascii
let s:iso2022_jp.ostate = s:iso2022_jp.state_ascii

function s:iso2022_jp.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:iso2022_jp.__init__()
  let self.istate = self.state_ascii
  let self.ostate = self.state_ascii
  let self.ascii = iconv#ascii#new()
  let self.jisx0201 = iconv#jisx0201#new()
  let self.jisx0208 = iconv#jisx0208#new()
endfunction

function s:iso2022_jp.mbtowc(mb)
  let c = a:mb[0]
  if c == self.esc
    if len(a:mb) < 3
      throw "ICONV: RET_TOOFEW"
    endif
    if a:mb[1] == char2nr('(')
      if a:mb[2] == char2nr('B')
        let self.istate = self.state_ascii
        return [3, []]
      endif
      if a:mb[2] == char2nr('J')
        let self.istate = self.state_jisx0201roman
        return [3, []]
      endif
      throw 'ICONV: RET_ILSEQ'
    endif
    if a:mb[1] == char2nr('$')
      if a:mb[2] == char2nr('@') || a:mb[2] == char2nr('B')
        " We don't distinguish JIS X 0208-1978 and JIS X 0208-1983.
        let self.istate = self.state_jisx0208
        return [3, []]
      endif
      throw 'ICONV: RET_ILSEQ'
    endif
    throw 'ICONV: RET_ILSEQ'
  endif

  if self.istate == self.state_ascii
    if c < 0x80
      return self.ascii.mbtowc(a:mb)
    endif
    throw 'ICONV: RET_ILSEQ'
  elseif self.istate == self.state_jisx0201roman
    if c < 0x80
      return self.jisx0201.mbtowc(a:mb)
    endif
    throw 'ICONV: RET_ILSEQ'
  elseif self.istate == self.state_jisx0208
    if len(a:mb) < 2
      throw "ICONV: RET_TOOFEW"
    endif
    if a:mb[0] < 0x80 && a:mb[1] < 0x80
      return self.jisx0208.mbtowc(a:mb)
    endif
    throw 'ICONV: RET_ILSEQ'
  endif

  throw "ICONV: abort"
endfunction

function s:iso2022_jp.wctomb(wc)
  " Try ASCII.
  try
    let mb = self.ascii.wctomb(a:wc)
    if mb[0] < 0x80
      if self.ostate != self.state_ascii
        let self.ostate = self.state_ascii
        let mb = [0x1b, 0x28, 0x42] + mb
      endif
      return mb
    endif
  catch /^ICONV:/
    " pass
  endtry

  " Try JIS X 0201-1976 Roman.
  try
    let mb = self.jisx0201.wctomb(a:wc)
    if mb[0] < 0x80
      if self.ostate != self.state_jisx0201roman
        let self.ostate = self.state_jisx0201roman
        let mb = [0x1b, 0x28, 0x4a] + mb
      endif
      return mb
    endif
  catch /^ICONV:/
    " pass
  endtry

  " Try JIS X 0208-1990 in place of JIS X 0208-1978 and JIS X 0208-1983.
  try
    let mb = self.jisx0208.wctomb(a:wc)
    if mb[0] < 0x80 && mb[1] < 0x80
      if self.ostate != self.state_jisx0208
        let self.ostate = self.state_jisx0208
        let mb = [0x1b, 0x24, 0x42] + mb
      endif
      return mb
    endif
  catch /^ICONV:/
    " pass
  endtry

  throw 'ICONV: RET_ILUNI'
endfunction

function s:iso2022_jp.flush()
  let self.istate = self.state_ascii
  if self.ostate != self.state_ascii
    let self.ostate = self.state_ascii
    return [0x1b, 0x28, 0x42] " \x1b(B
  else
    return []
  endif
endfunction

