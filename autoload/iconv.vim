" This is a port of libiconv
" http://www.gnu.org/software/libiconv/
" Last Change:  2010-12-10
" Maintainer:   Yukihiro Nakadaira <yukihiro.nakadaira@gmail.com>
" License:      LGPL

function iconv#iconv(buf, from, to)
  return bytes#bytes2str(iconv#iconvb(a:buf, a:from, a:to))
endfunction

function iconv#iconvb(buf, from, to)
  let buf = bytes#tobytes(a:buf)
  return s:iconv(buf, a:from, a:to)
endfunction

function! s:iconv(in, from, to)
  let in = copy(a:in)

  let from_conv = s:alias[a:from]()
  let to_conv = s:alias[a:to]()

  let out = []

  while !empty(in)
    let [n, wc] = from_conv.mbtowc(in)

    for w in wc
      let mb = to_conv.wctomb(w)
      call extend(out, mb)
    endfor

    unlet in[:n-1]
  endwhile

  let mb = to_conv.flush()
  call extend(out, mb)

  return out
endfunction

let s:alias = {
      \ "ascii": function("iconv#ascii#new"),
      \ "utf-8": function("iconv#utf8#new"),
      \ "utf-16": function("iconv#utf16#new"),
      \ "utf-16be": function("iconv#utf16be#new"),
      \ "utf-16le": function("iconv#utf16le#new"),
      \ "utf-32": function("iconv#utf32#new"),
      \ "utf-32be": function("iconv#utf32be#new"),
      \ "utf-32le": function("iconv#utf32le#new"),
      \ "iso-8859-1": function("iconv#iso8859_1#new"),
      \ "iso-8859-2": function("iconv#iso8859_2#new"),
      \ "iso-8859-3": function("iconv#iso8859_3#new"),
      \ "iso-8859-4": function("iconv#iso8859_4#new"),
      \ "iso-8859-5": function("iconv#iso8859_5#new"),
      \ "iso-8859-6": function("iconv#iso8859_6#new"),
      \ "iso-8859-7": function("iconv#iso8859_7#new"),
      \ "iso-8859-8": function("iconv#iso8859_8#new"),
      \ "iso-8859-9": function("iconv#iso8859_9#new"),
      \ "iso-8859-10": function("iconv#iso8859_10#new"),
      \ "iso-8859-11": function("iconv#iso8859_11#new"),
      \ "iso-8859-13": function("iconv#iso8859_13#new"),
      \ "iso-8859-14": function("iconv#iso8859_14#new"),
      \ "iso-8859-15": function("iconv#iso8859_15#new"),
      \ "iso-2022-jp": function("iconv#iso2022_jp#new"),
      \ "iso-2022-jp-1": function("iconv#iso2022_jp1#new"),
      \ "iso-2022-jp-3": function("iconv#iso2022_jp3#new"),
      \ "euc-jp": function("iconv#euc_jp#new"),
      \ "euc-jisx0213": function("iconv#euc_jisx0213#new"),
      \ "sjis": function("iconv#sjis#new"),
      \ "shift-jisx0213": function("iconv#shift_jisx0213#new"),
      \ "cp932": function("iconv#cp932#new"),
      \ }

