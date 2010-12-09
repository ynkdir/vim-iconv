" euc_jp.h
"
" Copyright (C) 1999-2001, 2005 Free Software Foundation, Inc.
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
" EUC-JP
"

function iconv#euc_jp#new()
  return s:euc_jp.new()
endfunction

let s:euc_jp = {}

function s:euc_jp.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:euc_jp.__init__()
  let self.ascii = iconv#ascii#new()
  let self.jisx0201 = iconv#jisx0201#new()
  let self.jisx0208 = iconv#jisx0208#new()
  let self.jisx0212 = iconv#jisx0212#new()
endfunction

function s:euc_jp.mbtowc(mb)
  let c = a:mb[0]
  " Code set 0 (ASCII or JIS X 0201-1976 Roman)
  if c < 0x80
    return self.ascii.mbtowc(a:mb)
  endif
  " Code set 1 (JIS X 0208)
  if c >= 0xa1 && c < 0xff
    if len(a:mb) < 2
      throw "ICONV: RET_TOOFEW"
    endif
    if c < 0xf5
      let c2 = a:mb[1]
      if c2 >= 0xa1 && c2 < 0xff
        let buf = [c - 0x80, c2 - 0x80]
        return self.jisx0208.mbtowc(buf)
      else
        throw 'ICONV: RET_ILSEQ'
      endif
    else
      " User-defined range. See
      " Ken Lunde's "CJKV Information Processing", table 4-66, p. 206.
      let c2 = a:mb[1]
      if c2 >= 0xa1 && c2 < 0xff
        return [2, [0xe000 + 94*(c-0xf5) + (c2-0xa1)]]
      else
        throw 'ICONV: RET_ILSEQ'
      endif
    endif
  endif
  " Code set 2 (half-width katakana)
  if c == 0x8e
    if len(a:mb) < 2
      throw "ICONV: RET_TOOFEW"
    endif
    let c2 = a:mb[1]
    if c2 >= 0xa1 && c2 < 0xe0
      return [2, self.jisx0201.mbtowc([c2])[1]]
    else
      throw 'ICONV: RET_ILSEQ'
    endif
  endif
  " Code set 3 (JIS X 0212-1990)
  if c == 0x8f
    if len(a:mb) < 2
      throw "ICONV: RET_TOOFEW"
    endif
    let c2 = a:mb[1]
    if c2 >= 0xa1 && c2 < 0xff
      if len(a:mb) < 3
        throw "ICONV: RET_TOOFEW"
      endif
      if c2 < 0xf5
        let c3 = a:mb[2]
        if c3 >= 0xa1 && c2 < 0xff
          let buf = [c2-0x80, c3-0x80]
          return [3, self.jisx0212.mbtowc(buf)[1]]
        else
          throw 'ICONV: RET_ILSEQ'
        endif
      else
        " User-defined range. See
        " Ken Lunde's "CJKV Information Processing", table 4-66, p. 206.
        let c3 = a:mb[2]
        if c3 >= 0xa1 && c3 < 0xff
          return [3, [0xe3ac + 94*(c2-0xf5) + (c3-0xa1)]]
        else
          throw 'ICONV: RET_ILSEQ'
        endif
      endif
    else
      throw 'ICONV: RET_ILSEQ'
    endif
  endif
  throw 'ICONV: RET_ILSEQ'
endfunction

function s:euc_jp.wctomb(wc)

  " Code set 0 (ASCII or JIS X 0201-1976 Roman)
  try
    return self.ascii.wctomb(a:wc)
  catch /^ICONV:/
    " pass
  endtry

  " Code set 1 (JIS X 0208)
  try
    let buf = self.jisx0208.wctomb(a:wc)
    return [buf[0]+0x80, buf[1]+0x80]
  catch /^ICONV:/
    " pass
  endtry

  " Code set 2 (half-width katakana)
  try
    let buf = self.jisx0201.wctomb(a:wc)
    if buf[0] >= 0x80
      return [0x8e, buf[0]]
    endif
  catch /^ICONV:/
    " pass
  endtry

  " Code set 3 (JIS X 0212-1990)
  try
    let buf = self.jisx0212.wctomb(a:wc)
    return [0x8f, buf[0]+0x80, buf[1]+0x80]
  catch /^ICONV:/
    " pass
  endtry

  " Extra compatibility with Shift_JIS.
  if a:wc == 0x00a5
    return [0x5c]
  elseif a:wc == 0x203e
    return [0x7e]
  endif

  " User-defined range. See
  " Ken Lunde's "CJKV Information Processing", table 4-66, p. 206.
  if a:wc >= 0xe000 && a:wc < 0xe758
    if a:wc < 0xe3ac
      let c1 = (a:wc - 0xe000) / 94
      let c2 = (a:wc - 0xe000) % 94
      return [c1+0xf5, c2+0xa1]
    else
      let c1 = (a:wc - 0xe3ac) / 94
      let c2 = (a:wc - 0xe3ac) % 94
      return [0x8f, c1+0xf5, c2+0xa1]
    endif
  endif

  throw 'ICONV: RET_ILUNI'
endfunction

function s:euc_jp.flush()
  return []
endfunction

