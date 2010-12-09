" iso2022_jp3.h
"
" Copyright (C) 1999-2004, 2008 Free Software Foundation, Inc.
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
" ISO-2022-JP-3
"

function iconv#iso2022_jp3#new()
  return s:iso2022_jp3.new()
endfunction

let s:iso2022_jp3 = {}

let s:iso2022_jp3.esc = 0x1b

let s:iso2022_jp3.state_ascii = 0
let s:iso2022_jp3.state_jisx0201roman = 1
let s:iso2022_jp3.state_jisx0201katakana = 2
let s:iso2022_jp3.state_jisx0208 = 3
let s:iso2022_jp3.state_jisx02131 = 4
let s:iso2022_jp3.state_jisx02132 = 5

let s:iso2022_jp3.istate = s:iso2022_jp3.state_ascii
let s:iso2022_jp3.ostate = s:iso2022_jp3.state_ascii
let s:iso2022_jp3.lasttwo = 0
let s:iso2022_jp3.prevstate = 0

function s:iso2022_jp3.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:iso2022_jp3.__init__()
  let self.istate = self.state_ascii
  let self.ostate = self.state_ascii
  let self.lasttwo = 0
  let self.prevstate = 0
  let self.ascii = iconv#ascii#new()
  let self.jisx0201 = iconv#jisx0201#new()
  let self.jisx0208 = iconv#jisx0208#new()
  let self.jisx0213 = iconv#jisx0213#new()
endfunction

function s:iso2022_jp3.mbtowc(mb)
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
      if a:mb[2] == char2nr('I')
        let self.istate = self.state_jisx0201katakana
        return [3, []]
      endif
      throw 'ICONV: RET_ILSEQ'
    endif
    if a:mb[1] == char2nr('$')
      if a:mb[2] == char2nr('@') || a:mb[2] == char2nr('B')
        let self.istate = self.state_jisx0208
        return [3, []]
      endif
      if a:mb[2] == char2nr('(')
        if len(a:mb) < 4
          throw "ICONV: RET_TOOFEW"
        endif
        if a:mb[3] == char2nr('O') || a:mb[3] == char2nr('Q')
          let self.istate = self.state_jisx02131
          return [4, []]
        endif
        if a:mb[3] == char2nr('P')
          let self.istate = self.state_jisx02132
          return [4, []]
        endif
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
  elseif self.istate == self.state_jisx0201katakana
    if c < 0x80
      return self.jisx0201.mbtowc([c+0x80])
    endif
    throw 'ICONV: RET_ILSEQ'
  elseif self.istate == self.state_jisx0208
    if a:mb[0] < 0x80 && a:mb[1] < 0x80
      return self.jisx0208.mbtowc(a:mb)
    endif
    throw 'ICONV: RET_ILSEQ'
  elseif self.istate == self.state_jisx02131 || self.istate == self.state_jisx02132
    if a:mb[0] < 0x80 && a:mb[1] < 0x80
      let wc = self.jisx0213.jisx0213_to_ucs4(
            \ ((self.istate-self.state_jisx02131+1)*0x100)+a:mb[0],a:mb[1])
      if wc
        if wc < 0x80
          let wc1 = self.jisx0213.jisx0213_to_ucs_combining[wc - 1][0]
          let wc2 = self.jisx0213.jisx0213_to_ucs_combining[wc - 1][1]
          let res = [wc1, wc2]
        else
          let res = [wc]
        endif
        return [2, res]
      endif
    endif
  endif

  throw "ICONV: abort"
endfunction

function s:iso2022_jp3.wctomb(wc)
  let res = []
  let lasttwo = self.lasttwo

  if lasttwo
    let self.lasttwo = 0
    let idx = -1
    let len = -1

    if a:wc == 0x02e5
      let idx = s:iso2022_jp3.iso2022_jp3_comp_table02e5_idx
      let len = s:iso2022_jp3.iso2022_jp3_comp_table02e5_len
    elseif a:wc == 0x02e9
      let idx = s:iso2022_jp3.iso2022_jp3_comp_table02e9_idx
      let len = s:iso2022_jp3.iso2022_jp3_comp_table02e9_len
    elseif a:wc == 0x0300
      let idx = s:iso2022_jp3.iso2022_jp3_comp_table0300_idx
      let len = s:iso2022_jp3.iso2022_jp3_comp_table0300_len
    elseif a:wc == 0x0301
      let idx = s:iso2022_jp3.iso2022_jp3_comp_table0301_idx
      let len = s:iso2022_jp3.iso2022_jp3_comp_table0301_len
    elseif a:wc == 0x309a
      let idx = s:iso2022_jp3.iso2022_jp3_comp_table309a_idx
      let len = s:iso2022_jp3.iso2022_jp3_comp_table309a_len
    endif

    let idx_base = 0
    let idx_composed = 1

    if idx != 1 && len != -1
      let data = filter(self.iso2022_jp3_comp_table_data[idx:idx+(len-1)],
            \ 'v:val[idx_base] == lasttwo')
      if !empty(data)
        if self.ostate != self.state_jisx02131
          let self.ostate = self.state_jisx02131
          let res = [0x1b, 0x24, 0x28, 0x51]
        endif
        let lasttwo = data[0][idx_composed]
        return res + [(lasttwo / 0x100) % 0x100, lasttwo % 0x100]
      endif
    endif

    if self.prevstate != self.ostate
      if self.ostate != self.state_jisx0208
        throw 'ICONV: abort'
      endif
      let res = [0x1b, 0x24, 0x42]
    endif
    let res = res + [(lasttwo / 0x100) % 0x100, lasttwo % 0x100]
  endif

  " Try ASCII.
  try
    let mb = self.ascii.wctomb(a:wc)
    if mb[0] < 0x80
      if self.ostate != self.state_ascii
        let self.ostate = self.state_ascii
        let mb = [0x1b, 0x28, 0x42] + mb
      endif
      return res + mb
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
      return res + mb
    endif
  catch /^ICONV:/
    " pass
  endtry

  let jch = self.jisx0213.ucs4_to_jisx0213(a:wc)

  " Try JIS X 0208-1990 in place of JIS X 0208-1978 and JIS X 0208-1983.
  try
    let mb = self.jisx0208.wctomb(a:wc)
    if mb[0] < 0x80 && mb[1] < 0x80
      if bitwise#and(jch, 0x0080)
        let self.prevstate = self.ostate
        let self.lasttwo = bitwise#and(jch, 0x7f7f)
        let self.ostate = self.state_jisx0208
        return res
      else
        if self.ostate != self.state_jisx0208
          let self.ostate = self.state_jisx0208
          let mb = [0x1b, 0x24, 0x42] + mb
        endif
        return res + mb
      endif
    endif
  catch /^ICONV:/
    " pass
  endtry

  " Try JISX 0213 plane 1 and JISX 0213 plane 2.
  try
    if jch != 0
      if bitwise#and(jch, 0x8000)
        " JISX 0213 plane 2.
        if self.ostate != self.state_jisx02132
          let self.ostate = self.state_jisx02132
          let res = res + [0x1b, 0x24, 0x28, 0x50]
        endif
      else
        " JISX 0213 plane 1.
        if self.ostate != self.state_jisx02131
          let self.ostate = self.state_jisx02131
          let res = [0x1b, 0x24, 0x28, 0x51]
        endif
      endif
      if bitwise#and(jch, 0x0080)
        if bitwise#and(jch, 0x8000)
          throw 'ICONV: abort'
        endif
        let self.prevstate = self.ostate
        let self.lasttwo = bitwise#and(jch, 0x7f7f)
        return res
      endif
      return res + [(jch / 0x100) % 0x80, jch % 0x80]
    endif
  catch /^ICONV:/
    " pass
  endtry

  " Try JIS X 0201-1976 Katakana. This is not officially part of
  " ISO-2022-JP-3. Therefore we try it after all other attempts.
  try
    let mb = self.jisx0201.wctomb(a:wc)
    if mb[0] >= 0x80
      if self.ostate != self.state_jisx0201katakana
        let self.ostate = self.state_jisx0201katakana
        let res = [0x1b, 0x28, 0x49]
      endif
      return res + [mb[0]-0x80]
    endif
  catch /^ICONV:/
    " pass
  endtry

  throw 'ICONV: RET_ILUNI'
endfunction

function s:iso2022_jp3.flush()
  let res = []
  let self.istate = self.state_ascii
  let lasttwo = self.lasttwo
  let self.lasttwo = 0
  let prevstate = self.prevstate
  let self.prevstate = 0
  if lasttwo
    if prevstate != self.ostate
      if self.ostate != self.state_jisx0208
        throw 'ICONV: abort'
      endif
      let res = [0x1b, 0x24, 0x42]
    endif
    let res = res + [(lasttwo / 0x100) % 0x100, lasttwo % 0x100]
  endif
  if self.ostate != self.state_ascii
    let self.ostate = self.state_ascii
    return res + [0x1b, 0x28, 0x42] " \x1b(B
  else
    return res + []
  endif
endfunction


let s:iso2022_jp3.iso2022_jp3_comp_table02e5_idx = 0
let s:iso2022_jp3.iso2022_jp3_comp_table02e5_len = 1
let s:iso2022_jp3.iso2022_jp3_comp_table02e9_idx =
      \ s:iso2022_jp3.iso2022_jp3_comp_table02e5_idx +
      \ s:iso2022_jp3.iso2022_jp3_comp_table02e5_len
let s:iso2022_jp3.iso2022_jp3_comp_table02e9_len = 1
let s:iso2022_jp3.iso2022_jp3_comp_table0300_idx =
      \ s:iso2022_jp3.iso2022_jp3_comp_table02e9_idx +
      \ s:iso2022_jp3.iso2022_jp3_comp_table02e9_len
let s:iso2022_jp3.iso2022_jp3_comp_table0300_len = 5
let s:iso2022_jp3.iso2022_jp3_comp_table0301_idx =
      \ s:iso2022_jp3.iso2022_jp3_comp_table0300_idx +
      \ s:iso2022_jp3.iso2022_jp3_comp_table0300_len
let s:iso2022_jp3.iso2022_jp3_comp_table0301_len = 4
let s:iso2022_jp3.iso2022_jp3_comp_table309a_idx =
      \ s:iso2022_jp3.iso2022_jp3_comp_table0301_idx +
      \ s:iso2022_jp3.iso2022_jp3_comp_table0301_len
let s:iso2022_jp3.iso2022_jp3_comp_table309a_len = 14

" Composition tables for each of the relevant combining characters.
let s:iso2022_jp3.iso2022_jp3_comp_table_data = [
\ [ 0x2b64, 0x2b65 ],
\ [ 0x2b60, 0x2b66 ],
\ [ 0x295c, 0x2b44 ],
\ [ 0x2b38, 0x2b48 ],
\ [ 0x2b37, 0x2b4a ],
\ [ 0x2b30, 0x2b4c ],
\ [ 0x2b43, 0x2b4e ],
\ [ 0x2b38, 0x2b49 ],
\ [ 0x2b37, 0x2b4b ],
\ [ 0x2b30, 0x2b4d ],
\ [ 0x2b43, 0x2b4f ],
\ [ 0x242b, 0x2477 ],
\ [ 0x242d, 0x2478 ],
\ [ 0x242f, 0x2479 ],
\ [ 0x2431, 0x247a ],
\ [ 0x2433, 0x247b ],
\ [ 0x252b, 0x2577 ],
\ [ 0x252d, 0x2578 ],
\ [ 0x252f, 0x2579 ],
\ [ 0x2531, 0x257a ],
\ [ 0x2533, 0x257b ],
\ [ 0x253b, 0x257c ],
\ [ 0x2544, 0x257d ],
\ [ 0x2548, 0x257e ],
\ [ 0x2675, 0x2678 ],
\]

