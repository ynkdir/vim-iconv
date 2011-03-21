source <sfile>:p:h/test.vim
function! _convert(utf8, enc)
  let mb = iconv#iconvb(a:utf8, "utf-8", a:enc)
  let utf8 = iconv#iconv(mb, a:enc, "utf-8")
  return a:utf8 ==# utf8
endfunction
INFO iconv test

OK iconv#iconv("hello", "ascii", "ascii") ==# "hello"
OK iconv#iconv("hello", "iso-8859-1", "iso-8859-1") ==# "hello"
OK iconv#iconv("hello", "iso-8859-2", "iso-8859-2") ==# "hello"
OK iconv#iconv("hello", "iso-8859-3", "iso-8859-3") ==# "hello"
OK iconv#iconv("hello", "iso-8859-4", "iso-8859-4") ==# "hello"
OK iconv#iconv("hello", "iso-8859-5", "iso-8859-5") ==# "hello"
OK iconv#iconv("hello", "iso-8859-6", "iso-8859-6") ==# "hello"
OK iconv#iconv("hello", "iso-8859-7", "iso-8859-7") ==# "hello"
OK iconv#iconv("hello", "iso-8859-8", "iso-8859-8") ==# "hello"
OK iconv#iconv("hello", "iso-8859-9", "iso-8859-9") ==# "hello"
OK iconv#iconv("hello", "iso-8859-10", "iso-8859-10") ==# "hello"
OK iconv#iconv("hello", "iso-8859-11", "iso-8859-11") ==# "hello"
OK iconv#iconv("hello", "iso-8859-13", "iso-8859-13") ==# "hello"
OK iconv#iconv("hello", "iso-8859-14", "iso-8859-14") ==# "hello"
OK iconv#iconv("hello", "iso-8859-15", "iso-8859-15") ==# "hello"

INFO utf16
OK iconv#iconvb("ab", "utf-8", "utf-16") == [0xFE, 0xFF, 0, 0x61, 0, 0x62]
OK iconv#iconv([0xFE, 0xFF, 0, 0x61, 0, 0x62], "utf-16", "utf-8") ==# "ab"
OK iconv#iconv([0xFF, 0xFE, 0x61, 0, 0x62, 0], "utf-16", "utf-8") ==# "ab"
OK _convert("hello", "utf-16")
INFO utf16 surrogate pair
OK _convert("𠀋", "utf-16")
INFO utf16be
OK iconv#iconvb("ab", "utf-8", "utf-16be") == [0, 0x61, 0, 0x62]
OK _convert("hello", "utf-16be")
INFO utf16be surrogate pair
OK _convert("𠀋", "utf-16be")
INFO utf16le
OK iconv#iconvb("ab", "utf-8", "utf-16le") == [0x61, 0, 0x62, 0]
OK _convert("hello", "utf-16le")
INFO utf16be surrogate pair
OK _convert("𠀋", "utf-16be")
INFO utf32
OK iconv#iconvb("ab", "utf-8", "utf-32") == [0x00, 0x00, 0xFE, 0xFF, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00, 0x62]
OK iconv#iconv([0x00, 0x00, 0xFE, 0xFF, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00, 0x62], "utf-32", "utf-8") ==# "ab"
OK iconv#iconv([0xFF, 0xFE, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00, 0x62, 0x00, 0x00, 0x00], "utf-32", "utf-8") ==# "ab"
OK _convert("hello", "utf-32")
INFO utf32be
OK iconv#iconvb("ab", "utf-8", "utf-32be") == [0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00, 0x62]
OK _convert("hello", "utf-32be")
INFO utf32le
OK iconv#iconvb("ab", "utf-8", "utf-32le") == [0x61, 0x00, 0x00, 0x00, 0x62, 0x00, 0x00, 0x00]
OK _convert("hello", "utf-32le")

INFO cp932
OK iconv#iconv("hello", "cp932", "cp932") ==# "hello"
INFO cp932 JISX0208
OK _convert("こんにちは", "cp932")
INFO cp932ext
OK _convert("№", "cp932")

INFO euc-jp
OK iconv#iconv("hello", "euc-jp", "euc-jp") ==# "hello"
INFO JISX0201 hankaku kana
OK _convert("ｺﾝﾆﾁﾊ", "euc-jp")
INFO euc-jp JISX0208
OK _convert("こんにちは", "euc-jp")
INFO euc-jp JISX0212
OK _convert("№", "euc-jp")

"OK iconv#iconv("hello", "iso-2022-jp", "iso-2022-jp") ==# "hello"
"OK iconv#iconv("hello", "iso-2022-jp-1", "iso-2022-jp-1") ==# "hello"
"OK iconv#iconv("hello", "iso-2022-jp-3", "iso-2022-jp-3") ==# "hello"
"OK iconv#iconv("hello", "euc-jisx0213", "euc-jisx0213") ==# "hello"
"OK iconv#iconv("hello", "sjis", "sjis") ==# "hello"
"OK iconv#iconv("hello", "shift-jisx0213", "shift-jisx0213") ==# "hello"
"INFO euc-jp JISX0213
"OK _convert("こんにちは", "euc-jisx0213")
"INFO sjis JISX0201 hankaku kana
"OK _convert("ｺﾝﾆﾁﾊ", "sjis")
"INFO sjis JISX0208
"OK _convert("こんにちは", "sjis")
"INFO shift-jisx0213
"OK _convert("こんにちは", "shift-jisx0213")
