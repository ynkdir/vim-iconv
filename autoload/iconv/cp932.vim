" cp932.h
"
" Copyright (C) 1999-2002, 2005 Free Software Foundation, Inc.
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
" CP932
"

function iconv#cp932#new()
  return s:cp932.new()
endfunction

let s:cp932 = {}

function s:cp932.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:cp932.__init__()
  let self.ascii = iconv#ascii#new()
  let self.jisx0201 = iconv#jisx0201#new()
  let self.jisx0208 = iconv#jisx0208#new()
  let self.cp932ext = iconv#cp932ext#new()
endfunction

function s:cp932.mbtowc(mb)
  let c = a:mb[0]
  if c < 0x80
    return self.ascii.mbtowc(a:mb)
  elseif c >= 0xa1 && c <= 0xdf
    return self.jisx0201.mbtowc(a:mb)
  else
    let s1 = c
    if (s1 >= 0x81 && s1 <= 0x9f && s1 != 0x87) || (s1 >= 0xe0 && s1 <= 0xea)
      if len(a:mb) < 2
        throw "ICONV: RET_TOOFEW"
      endif
      let s2 = a:mb[1]
      if (s2 >= 0x40 && s2 <= 0x7e) || (s2 >= 0x80 && s2 <= 0xfc)
        let t1 = (s1 < 0xe0) ? s1-0x81 : s1-0xc1
        let t2 = (s2 < 0x80) ? s2-0x40 : s2-0x41
        let buf = [0, 0]
        let buf[0] = 2*t1 + (t2 < 0x5e ? 0 : 1) + 0x21
        let buf[1] = (t2 < 0x5e ? t2 : t2-0x5e) + 0x21
        return self.jisx0208.mbtowc(buf)
      endif
    elseif (s1 == 0x87) || (s1 >= 0xed && s1 <= 0xee) || (s1 >= 0xfa)
      if len(a:mb) < 2
        throw "ICONV: RET_TOOFEW"
      endif
      return self.cp932ext.mbtowc(a:mb)
    elseif s1 >= 0xf0 && s1 <= 0xf9
      " User-defined range. See
      " Ken Lunde's "CJKV Information Processing", table 4-66, p. 206.
      if len(a:mb) < 2
        throw "ICONV: RET_TOOFEW"
      endif
      let s2 = a:mb[1]
      if (s2 >= 0x40 && s2 <= 0x7e) || (s2 >= 0x80 && s2 <= 0xfc)
        let wc = 0xe000 + 188*(s1 - 0xf0) + (s2 < 0x80 ? s2-0x40 : s2-0x41)
        return [2, [wc]]
      endif
    endif
    throw 'ICONV: RET_ILSEQ'
  endif
endfunction

function s:cp932.wctomb(wc)
  " Try ASCII.
  try
    return self.ascii.wctomb(a:wc)
  catch /^ICONV:/
    " pass
  endtry

  " Try JIS X 0201-1976 Katakana.
  try
    let buf = self.jisx0201.wctomb(a:wc)
    if buf[0] >= 0xa1 && buf[0] <= 0xdf
      return buf
    endif
  catch /^ICONV:/
    " pass
  endtry

  " Try JIS X 0208-1990.
  try
    let buf = self.jisx0208.wctomb(a:wc)
    let c1 = buf[0]
    let c2 = buf[1]
    if (c1 >= 0x21 && c1 <= 0x74) && (c2 >= 0x21 && c2 <= 0x7e)
      let t1 = (c1 - 0x21) / 2
      let t2 = (((c1 - 0x21) % 2) ? 0x5e : 0) + (c2 - 0x21)
      let buf[0] = (t1 < 0x1f) ? t1 + 0x81 : t1 + 0xc1
      let buf[1] = (t2 < 0x3f) ? t2 + 0x40 : t2 + 0x41
      return buf
    endif
  catch /^ICONV:/
    " pass
  endtry

  " Try CP932 extensions.
  try
    return self.cp932ext.wctomb(a:wc)
  catch /^ICONV:/
    " pass
  endtry

  " User-defined range. See
  " Ken Lunde's "CJKV Information Processing", table 4-66, p. 206.
  if a:wc >= 0xe000 && a:wc < 0xe758
    let c1 = (a:wc - 0xe000) / 188
    let c2 = (a:wc - 0xe000) % 188
    return [c1 + 0xf0, (c2 < 0x3f) ? c2+0x40 : c2+0x41]
  endif

  " Irreversible mappings.
  if a:wc == 0xff5e
    return [0x81, 0x60]
  endif
  if a:wc == 0x2225
    return [0x81, 0x61]
  endif
  if a:wc == 0xff0d
    return [0x81, 0x7c]
  endif
  if a:wc == 0xffe0
    return [0x81, 0x91]
  endif
  if a:wc == 0xffe1
    return [0x81, 0x92]
  endif

  throw 'ICONV: RET_ILUNI'
endfunction

function s:cp932.flush()
  return []
endfunction

