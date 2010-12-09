" euc_jisx0213.h
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
" EUC-JISX0213
"

function iconv#euc_jisx0213#new()
  return s:euc_jisx0213.new()
endfunction

let s:euc_jisx0213 = {}

let s:euc_jisx0213.ostate = 0

function s:euc_jisx0213.new()
  let obj = copy(self)
  call obj.__init__()
  return obj
endfunction

function s:euc_jisx0213.__init__()
  let self.ostate = 0
  let self.jisx0213 = iconv#jisx0213#new()
endfunction

function s:euc_jisx0213.mbtowc(mb)
  let c = a:mb[0]
  if c < 0x80
    " Plain ASCII character.
    return [1, [c]]
  else
    if (c >= 0xa1 && c <= 0xfe) || c == 0x8e || c == 0x8f
      " Two or three byte character.
      if len(a:mb) >= 2
        let c2 = a:mb[1]
        if c2 >= 0xa1 && c2 <= 0xfe
          if c == 0x8e
            " Half-width katakana.
            if c2 <= 0xdf
              return [2, [c2 + 0xfec0]]
            endif
          else
            let wc = 0
            if c == 0x8f
              " JISX 0213 plane 2.
              if len(a:mb) >= 3
                let c3 = a:mb[2]
                let wc = self.jisx0213.jisx0213_to_ucs4(0x200-0x80+c2,
                      \ bitwise#xor(c3, 0x80))
              else
                throw "ICONV: RET_TOOFEW"
              endif
            else
              " JISX 0213 plane 1.
              let wc = self.jisx0213.jisx0213_to_ucs4(0x100-0x80+c,
                    \ bitwise#xor(c2, 0x80))
            endif
            if wc
              if wc < 0x80
                " It's a combining character.
                let wc1 = self.jisx0213.jisx0213_to_ucs_combining[wc-1][0]
                let wc2 = self.jisx0213.jisx0213_to_ucs_combinint[wc-1][1]
                let res = [wc1, wc2]
              else
                let res = [wc]
              endif
              return [(c == 0x8f) ? 3 : 2, res]
            endif
          endif
        endif
      else
        throw "ICONV: RET_TOOFEW"
      endif
    endif
    throw 'ICONV: RET_ILSEQ'
  endif
endfunction

function s:euc_jisx0213.wctomb(wc)
  let res = []
  let lasttwo = self.ostate

  if lasttwo
    " Attempt to combine the last character with this one.
    let idx = -1
    let len = -1

    if a:wc == 0x02e5
      let idx = self.euc_jisx0213_comp_table02e5_idx
      let len = self.euc_jisx0213_comp_table02e5_len
    elseif a:wc == 0x02e9
      let idx = self.euc_jisx0213_comp_table02e9_idx
      let len = self.euc_jisx0213_comp_table02e9_len
    elseif a:wc == 0x0300
      let idx = self.euc_jisx0213_comp_table0300_idx
      let len = self.euc_jisx0213_comp_table0300_len
    elseif a:wc == 0x0301
      let idx = self.euc_jisx0213_comp_table0301_idx
      let len = self.euc_jisx0213_comp_table0301_len
    elseif a:wc == 0x309a
      let idx = self.euc_jisx0213_comp_table309a_idx
      let len = self.euc_jisx0213_comp_table309a_len
    endif

    let idx_base = 0
    let idx_composed = 1

    if idx != -1 && len != -1
      let data = filter(self.euc_jisx0213_comp_table_data[idx:idx+(len-1)],
            \ 'v:val[idx_base] == lasttwo')
      if !empty(data)
        let lasttwo = data[0][idx_composed]
        let self.ostate = 0
        return [(lasttwo / 0x100) % 0x100, lasttwo % 0x100]
      endif
    endif

    let res = [(lasttwo / 0x100) % 0x100, lasttwo % 0x100]
  endif

  if a:wc < 0x80
    " Plain ASCII character.
    let self.ostate = 0
    return res + [a:wc]
  elseif a:wc >= 0xff61 && a:wc <= 0xff9f
    " Half-width katakana.
    let self.ostate = 0
    return res + [0x8e, a:wc - 0xfec0]
  else
    let jch = self.jisx0213.ucs4_to_jisx0213(a:wc)
    if jch != 0
      if bitwise#and(jch, 0x0080)
        " A possible match in comp_table_data. We have to buffer it.
        " We know it's a JISX 0213 plane 1 character.
        if bitwise#and(jch, 0x8000)
          throw 'ICONV: abort'
        endif
        let self.ostate = bitwise#or(jch, 0x8080)
        return res
      endif
      if bitwise#and(jch, 0x8000)
        " JISX 0213 plane 2.
        let self.ostate = 0
        return res + [0x8f, bitwise#or(jch / 0x100, 0x80),
              \ bitwise#or(jch % 0x100, 0x80)]
      else
        " JISX 0213 plane 1.
        let self.ostate = 0
        return res + [bitwise#or(jch / 0x100, 0x80),
              \ bitwise#or(jch % 0x100, 0x80)]
      endif
    endif
    throw 'ICONV: RET_ILUNI'
  endif
endfunction

function s:euc_jisx0213.flush()
  let lasttwo = self.ostate
  if lasttwo
    let self.ostate = 0
    return [(lasttwo / 0x100) % 0x100, lasttwo % 0x100]
  else
    return []
  endif
endfunction

let s:euc_jisx0213.euc_jisx0213_comp_table02e5_idx = 0
let s:euc_jisx0213.euc_jisx0213_comp_table02e5_len = 1
let s:euc_jisx0213.euc_jisx0213_comp_table02e9_idx =
      \ s:euc_jisx0213.euc_jisx0213_comp_table02e5_idx +
      \ s:euc_jisx0213.euc_jisx0213_comp_table02e5_len
let s:euc_jisx0213.euc_jisx0213_comp_table02e9_len = 1
let s:euc_jisx0213.euc_jisx0213_comp_table0300_idx =
      \ s:euc_jisx0213.euc_jisx0213_comp_table02e9_idx +
      \ s:euc_jisx0213.euc_jisx0213_comp_table02e9_len
let s:euc_jisx0213.euc_jisx0213_comp_table0300_len = 5
let s:euc_jisx0213.euc_jisx0213_comp_table0301_idx =
      \ s:euc_jisx0213.euc_jisx0213_comp_table0300_idx +
      \ s:euc_jisx0213.euc_jisx0213_comp_table0300_len
let s:euc_jisx0213.euc_jisx0213_comp_table0301_len = 4
let s:euc_jisx0213.euc_jisx0213_comp_table309a_idx =
      \ s:euc_jisx0213.euc_jisx0213_comp_table0301_idx +
      \ s:euc_jisx0213.euc_jisx0213_comp_table0301_len
let s:euc_jisx0213.euc_jisx0213_comp_table309a_len = 14

let s:euc_jisx0213.euc_jisx0213_comp_table_data = [
\ [ 0xabe4, 0xabe5 ],
\ [ 0xabe0, 0xabe6 ],
\ [ 0xa9dc, 0xabc4 ],
\ [ 0xabb8, 0xabc8 ],
\ [ 0xabb7, 0xabca ],
\ [ 0xabb0, 0xabcc ],
\ [ 0xabc3, 0xabce ],
\ [ 0xabb8, 0xabc9 ],
\ [ 0xabb7, 0xabcb ],
\ [ 0xabb0, 0xabcd ],
\ [ 0xabc3, 0xabcf ],
\ [ 0xa4ab, 0xa4f7 ],
\ [ 0xa4ad, 0xa4f8 ],
\ [ 0xa4af, 0xa4f9 ],
\ [ 0xa4b1, 0xa4fa ],
\ [ 0xa4b3, 0xa4fb ],
\ [ 0xa5ab, 0xa5f7 ],
\ [ 0xa5ad, 0xa5f8 ],
\ [ 0xa5af, 0xa5f9 ],
\ [ 0xa5b1, 0xa5fa ],
\ [ 0xa5b3, 0xa5fb ],
\ [ 0xa5bb, 0xa5fc ],
\ [ 0xa5c4, 0xa5fd ],
\ [ 0xa5c8, 0xa5fe ],
\ [ 0xa6f5, 0xa6f8 ],
\]

