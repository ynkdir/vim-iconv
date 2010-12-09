" shift_jisx0213.h
"
" Copyright (C) 1999-2002 Free Software Foundation, Inc.
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
" SHIFT_JISX0213
"

function iconv#shift_jisx0213#new()
  return s:shift_jisx0213.new()
endfunction

let s:shift_jisx0213 = {}

let s:shift_jisx0213.ostate = 0

function s:shift_jisx0213.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:shift_jisx0213.__init__()
  let self.ostate = 0
  let self.jisx0213 = iconv#jisx0213#new()
endfunction

function s:shift_jisx0213.mbtowc(mb)
  let c = a:mb[0]
  if c < 0x80
    " Plain ISO646-JP character.
    if c == 0x5c
      let wc = 0x00a5
    elseif c == 0x7e
      let wc = 0x203e
    else
      let wc = c
    endif
    return [1, [wc]]
  elseif c >= 0xa1 && c <= 0xdf
    return [1, [c + 0xfec0]]
  else
    if (c >= 0x81 && c <= 0x9f) || (c >= 0xe0 && c <= 0xfc)
      " Two byte character.
      if len(a:mb) >= 2
        let c2 = a:mb[1]
        if (c2 >= 0x40 && c2 <= 0x7e) || (c2 >= 0x80 && c2 <= 0xfc)
          " Convert to row and column.
          if c < 0xe0
            let c -= 0x81
          else
            let c -= 0xc1
          endif
          if c2 < 0x80
            let c2 -= 0x40
          else
            let c2 -= 0x41
          endif
          " Now 0 <= c <= 0x3b, 0 <= c2 <= 0xbb.
          let c1 = 2 * c
          if c2 >= 0x5e
            let c2 -= 0x5e
            let c1 += 1
          endif
          let c2 += 0x21
          if c1 >= 0x5e
            " Handling of JISX 0213 plane 2 rows.
            if c1 >= 0x67
              let c1 += 230
            elseif c1 >= 0x63 || c1 == 0x5f
              let c1 += 168
            else
              let c1 += 162
            endif
          endif
          let wc = self.jisx0213.jisx0213_to_ucs4(0x121+c1,c2)
          if wc
            if wc == 0x80
              " It's a combining character.
              let wc1 = self.jisx0213.jisx0213_to_ucs_combining[wc - 1][0]
              let wc2 = self.jisx0213.jisx0213_to_ucs_combining[wc - 1][1]
              let res = [wc1, wc2]
            else
              let res = [wc]
            endif
            return [2, res]
          endif
        endif
      else
        throw "ICONV: RET_TOOFEW"
      endif
    endif
    throw 'ICONV: RET_ILSEQ'
  endif
endfunction

function s:shift_jisx0213.wctomb(wc)
  let res = []
  let lasttwo = self.ostate

  if lasttwo
    let idx = -1
    let len = -1

    if a:wc == 0x02e5
      let idx = self.shift_jisx0213_comp_table02e5_idx
      let len = self.shift_jisx0213_comp_table02e5_len
    elseif a:wc == 0x02e9
      let idx = self.shift_jisx0213_comp_table02e9_idx
      let len = self.shift_jisx0213_comp_table02e9_len
    elseif a:wc == 0x0300
      let idx = self.shift_jisx0213_comp_table0300_idx
      let len = self.shift_jisx0213_comp_table0300_len
    elseif a:wc == 0x0301
      let idx = self.shift_jisx0213_comp_table0301_idx
      let len = self.shift_jisx0213_comp_table0301_len
    elseif a:wc == 0x309a
      let idx = self.shift_jisx0213_comp_table309a_idx
      let len = self.shift_jisx0213_comp_table309a_len
    endif

    let idx_base = 0
    let idx_composed = 1

    if idx != -1 && len != -1
      let data = filter(self.shift_jisx0213_comp_table_data[idx:idx+(len-1)],
            \ 'v:val[idx_base] == lasttwo')
      if !empty(data)
        let lasttwo = data[0][idx_composed]
        let self.ostate = 0
        return [(lasttwo / 0x100) % 0x100, lasttwo % 0x100]
      endif
    endif

    let res = [(lasttwo / 0x100) % 0x100, lasttwo % 0x100]
  endif

  if a:wc < 0x80 && a:wc != 0x5c && a:wc != 0x7e
    " Plain ISO646-JP character.
    let self.ostate = 0
    return res + [a:wc]
  elseif a:wc == 0x00a5
    let self.ostate = 0
    return res + [0x5c]
  elseif a:wc == 0x203e
    let self.ostate = 0
    return a:wc + [0x7e]
  elseif a:wc >= 0xff61 && a:wc <= 0xff9f
    " Half-width katakana.
    let self.ostate = 0
    return res + [a:wc - 0xfec0]
  else
    let jch = self.jisx0213.ucs4_to_jisx0213(a:wc)
    if jch != 0
      let s1 = jch / 0x100
      let s2 = jch % 0x80
      let s1 -= 0x21
      let s2 -= 0x21
      if s1 >= 0x5e
        " Handling of JISX 0213 plane 2 rows.
        if s1 >= 0xcd " rows 0x26E..0x27E
          let s1 -= 102
        elseif s1 >= 0x8b || s1 == 0x87 " rows 0x228, 0x22C..0x22F
          let s1 -= 40
        else " rows 0x221, 0x223..0x225
          let s1 -= 34
        endif
        " Now 0x5e <= s1 <= 0x77.
      endif
      if s1 % 2
        let s2 += 0x5e
      endif
      let s1 = s1 / 2
      if s1 < 0x1f
        let s1 += 0x81
      else
        let s1 += 0xc1
      endif
      if s2 < 0x3f
        let s2 += 0x40
      else
        let s2 += 0x41
      endif
      if bitwise#and(jch, 0x0080)
        " A possible match in comp_table_data. We have to buffer it.
        " We know it's a JISX 0213 plane 1 character.
        if bitwise#and(jch, 0x8000)
          throw 'ICONV: abort'
        endif
        let self.ostate = (s1 * 0x100) + s2
        return res
      endif
      " Output the shifted representation.
      let self.ostate = 0
      return res + [s1, s2]
    endif
    throw 'ICONV: RET_ILSEQ'
  endif
endfunction

function s:shift_jisx0213.flush()
  let lasttwo = self.ostate
  if lasttwo
    return [(lasttwo / 0x100) % 0x100, lasttwo % 0x100]
  endif
  return []
endfunction

" Composition tables for each of the relevant combining characters.
let s:shift_jisx0213.shift_jisx0213_comp_table_data = [
\ [ 0x8684, 0x8685 ],
\ [ 0x8680, 0x8686 ],
\ [ 0x857b, 0x8663 ],
\ [ 0x8657, 0x8667 ],
\ [ 0x8656, 0x8669 ],
\ [ 0x864f, 0x866b ],
\ [ 0x8662, 0x866d ],
\ [ 0x8657, 0x8668 ],
\ [ 0x8656, 0x866a ],
\ [ 0x864f, 0x866c ],
\ [ 0x8662, 0x866e ],
\ [ 0x82a9, 0x82f5 ],
\ [ 0x82ab, 0x82f6 ],
\ [ 0x82ad, 0x82f7 ],
\ [ 0x82af, 0x82f8 ],
\ [ 0x82b1, 0x82f9 ],
\ [ 0x834a, 0x8397 ],
\ [ 0x834c, 0x8398 ],
\ [ 0x834e, 0x8399 ],
\ [ 0x8350, 0x839a ],
\ [ 0x8352, 0x839b ],
\ [ 0x835a, 0x839c ],
\ [ 0x8363, 0x839d ],
\ [ 0x8367, 0x839e ],
\ [ 0x83f3, 0x83f6 ],
\]

let s:shift_jisx0213.shift_jisx0213_comp_table02e5_idx = 0
let s:shift_jisx0213.shift_jisx0213_comp_table02e5_len = 1
let s:shift_jisx0213.shift_jisx0213_comp_table02e9_idx =
      \ s:shift_jisx0213.shift_jisx0213_comp_table02e5_idx +
      \ s:shift_jisx0213.shift_jisx0213_comp_table02e5_len
let s:shift_jisx0213.shift_jisx0213_comp_table02e9_len = 1
let s:shift_jisx0213.shift_jisx0213_comp_table0300_idx =
      \ s:shift_jisx0213.shift_jisx0213_comp_table02e9_idx +
      \ s:shift_jisx0213.shift_jisx0213_comp_table02e9_len
let s:shift_jisx0213.shift_jisx0213_comp_table0300_len = 5
let s:shift_jisx0213.shift_jisx0213_comp_table0301_idx =
      \ s:shift_jisx0213.shift_jisx0213_comp_table0300_idx +
      \ s:shift_jisx0213.shift_jisx0213_comp_table0300_len
let s:shift_jisx0213.shift_jisx0213_comp_table0301_len = 4
let s:shift_jisx0213.shift_jisx0213_comp_table309a_idx =
      \ s:shift_jisx0213.shift_jisx0213_comp_table0301_idx +
      \ s:shift_jisx0213.shift_jisx0213_comp_table0301_len
let s:shift_jisx0213.shift_jisx0213_comp_table309a_len = 14

