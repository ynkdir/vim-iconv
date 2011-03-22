#!vim -u

set nocompatible
set nomore

if has('vim_starting')
  set loadplugins
  call feedkeys(":source " . expand('<sfile>:p') . "\<CR>")
  finish
endif

function! s:parse_str(hex)
  let n = str2nr(a:hex, 16)
  let s = []
  while 1
    call insert(s, n % 0x100, 0)
    let n = n / 0x100
    if n == 0
      break
    endif
  endwhile
  return s
endfunction

function! s:parse_unicode(hex)
  let u = map(split(a:hex, '+'), 'str2nr(v:val, 16)')
  return u
endfunction

function! s:parse_simple(fname, columns, scol, ucol)
  let map = []
  for line in readfile(a:fname)
    let line = substitute(line, '#.*$', '', '')
    let cols = split(line)
    if len(cols) == a:columns
      let s = s:parse_str(cols[a:scol])
      let u = s:parse_unicode(cols[a:ucol])
      call add(map, [s, u])
    endif
  endfor
  return map
endfunction

function! s:make_simple(mapfile)
  let name = s:encname(a:mapfile)
  let map = s:parse_simple(a:mapfile, 2, 0, 1)
  let out = []
  let decoding_table_maxlen = max(map(copy(map), 'len(v:val[0])'))
  let encoding_table_maxlen = max(map(copy(map), 'len(v:val[1])'))
  let out = []
  call add(out, 'let s:nsiconv = expand(''<sfile>:p:h:h:gs?[\\/]?#?:s?^.*#autoload\(#\|$\)??:s?$?#?'')')
  call add(out, 'let s:ns = expand(''<sfile>:p:r:gs?[\\/]?#?:s?^.*#autoload#??:s?$?#?'')')
  call add(out, '')
  call add(out, 'function {s:ns}import()')
  call add(out, '  return s:lib')
  call add(out, 'endfunction')
  call add(out, '')
  call add(out, 'let s:tablebase = {s:nsiconv}codecs#tablebase#import()')
  call add(out, '')
  call add(out, 'let s:lib = {}')
  call add(out, '')
  call add(out, 'let s:lib.Codec = {}')
  call add(out, 'call extend(s:lib.Codec, s:tablebase.Codec)')
  call add(out, printf('let s:lib.Codec.encoding = "%s"', toupper(name)))
  call add(out, '')
  call add(out, printf('let s:lib.Codec.decoding_table_maxlen = %d', decoding_table_maxlen))
  call add(out, printf('let s:lib.Codec.encoding_table_maxlen = %d', encoding_table_maxlen))
  call add(out, '')
  call add(out, 'let s:lib.Codec.decoding_table = {}')
  let set = {}
  for [s, u] in map
    let key = '"' . join(s, ',') . '"'
    let value = join(u, ',')
    if !has_key(set, key)
      let set[key] = 1
      call add(out, printf('let s:lib.Codec.decoding_table[%s] = [%s]', key, value))
    endif
  endfor
  call add(out, '')
  call add(out, 'let s:lib.Codec.encoding_table = {}')
  let set = {}
  for [s, u] in map
    let key = '"' . join(u, ',') . '"'
    let value = join(s, ',')
    if !has_key(set, key)
      let set[key] = 1
      call add(out, printf('let s:lib.Codec.encoding_table[%s] = [%s]', key, value))
    endif
  endfor
  call writefile(out, '_' . tolower(name) . '.vim')
endfunction

function! s:encname(mapfile)
  let name = fnamemodify(a:mapfile, ':r')
  let name = substitute(name, '-', '_', 'g')
  return name
endfunction

function! s:download(url)
  tabnew
  if !filereadable(fnamemodify(a:url, ":t"))
    edit `=a:url`
    write %:p:t
  endif
  quit
endfunction

function! s:eucjptable()
  let x0201 = s:parse_simple('JIS0201.TXT', 2, 0, 1)
  let x0208 = s:parse_simple('JIS0208.TXT', 3, 1, 2)
  let x0212 = s:parse_simple('JIS0212.TXT', 2, 0, 1)
  let map = []
  for i in range(0x20)
    call add(map, [[i], [i]])
  endfor

  " TODO: make useful conversion table

  " ASCII
  for i in range(0x80)
    call add(map, [[i], [i]])
  endfor

  for [s, u] in x0201
    if s[0] >= 0x80
      call add(map, [[0x8E, s[0]], u])
    endif
  endfor

  for [s, u] in x0208
    call add(map, [[s[0] + 0x80, s[1] + 0x80], u])
  endfor

  for [s, u] in x0212
    call add(map, [[0x8f, s[0] + 0x80, s[1] + 0x80], u])
  endfor

  let out = []
  for [s, u] in map
    let euc = '0x' . join(map(s, 'printf("%02x", v:val)'), '')
    let uni = join(map(u, 'printf("0x%04x", v:val)'), '+')
    call add(out, printf('%s %s', euc, uni))
  endfor
  call writefile(out, 'EUC-JP.TXT')

  call s:make_simple('EUC-JP.TXT')
endfunction

function! s:main()
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-1.TXT")
  call s:make_simple("8859-1.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-2.TXT")
  call s:make_simple("8859-2.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-3.TXT")
  call s:make_simple("8859-3.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-4.TXT")
  call s:make_simple("8859-4.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-5.TXT")
  call s:make_simple("8859-5.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-6.TXT")
  call s:make_simple("8859-6.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-7.TXT")
  call s:make_simple("8859-7.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-8.TXT")
  call s:make_simple("8859-8.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-9.TXT")
  call s:make_simple("8859-9.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-10.TXT")
  call s:make_simple("8859-10.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-11.TXT")
  call s:make_simple("8859-11.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-13.TXT")
  call s:make_simple("8859-13.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-14.TXT")
  call s:make_simple("8859-14.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-15.TXT")
  call s:make_simple("8859-15.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-16.TXT")
  call s:make_simple("8859-16.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP437.TXT")
  call s:make_simple("CP437.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP737.TXT")
  call s:make_simple("CP737.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP775.TXT")
  call s:make_simple("CP775.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP850.TXT")
  call s:make_simple("CP850.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP852.TXT")
  call s:make_simple("CP852.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP855.TXT")
  call s:make_simple("CP855.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP857.TXT")
  call s:make_simple("CP857.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP860.TXT")
  call s:make_simple("CP860.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP861.TXT")
  call s:make_simple("CP861.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP862.TXT")
  call s:make_simple("CP862.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP863.TXT")
  call s:make_simple("CP863.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP864.TXT")
  call s:make_simple("CP864.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP865.TXT")
  call s:make_simple("CP865.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP866.TXT")
  call s:make_simple("CP866.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP869.TXT")
  call s:make_simple("CP869.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP874.TXT")
  call s:make_simple("CP874.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP932.TXT")
  call s:make_simple("CP932.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP936.TXT")
  call s:make_simple("CP936.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP949.TXT")
  call s:make_simple("CP949.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP950.TXT")
  call s:make_simple("CP950.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1250.TXT")
  call s:make_simple("CP1250.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1251.TXT")
  call s:make_simple("CP1251.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1252.TXT")
  call s:make_simple("CP1252.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1253.TXT")
  call s:make_simple("CP1253.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1254.TXT")
  call s:make_simple("CP1254.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1255.TXT")
  call s:make_simple("CP1255.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1256.TXT")
  call s:make_simple("CP1256.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1257.TXT")
  call s:make_simple("CP1257.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1258.TXT")
  call s:make_simple("CP1258.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/EBCDIC/CP037.TXT")
  call s:make_simple("CP037.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/EBCDIC/CP500.TXT")
  call s:make_simple("CP500.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/EBCDIC/CP875.TXT")
  call s:make_simple("CP875.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/EBCDIC/CP1026.TXT")
  call s:make_simple("CP1026.TXT")

  call s:download("http://www.unicode.org/Public/MAPPINGS/OBSOLETE/EASTASIA/JIS/JIS0201.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/OBSOLETE/EASTASIA/JIS/JIS0208.TXT")
  call s:download("http://www.unicode.org/Public/MAPPINGS/OBSOLETE/EASTASIA/JIS/JIS0212.TXT")
  call s:eucjptable()

  quit
endfunction

try
  call s:main()
endtry
