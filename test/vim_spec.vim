
function! s:describe__DirectoryOperation()
  It should succeed directory operation

  let l:name = tempname()
  Should isdirectory(l:name) ==  0

  call mkdir(l:name, "p", 0700)
  Should isdirectory(l:name) !=  0

endfunction

function! s:describe__PathStringOperation()
  It should succeed path string operation

  Should simplify("test//data.txt") == "test/data.txt"
  Should simplify("test///data.txt") == "test/data.txt"
  Should simplify("test////data.txt") == "test/data.txt"
  Should fnamemodify("abc/test/data/", ":h") == "abc/test/"

endfunction

" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
