" vim:set ts=8 sts=2 sw=2 tw=0:
let s:save_cpo=&cpo
set cpo&vim

" TODO OS判定
let s:sep = "/"
let s:temp_src = ""
let s:temp_root = ""

func! s:copy_file(src, dist)
  return s:copy_file_unix(a:src, a:dist)
endf

func! s:copy_file_unix(src, dist)
  call system("cp ".a:src." ".a:dist)
  if v:shell_error
    return 1
  endif
  return 0
endf

func! s:remove_file(path, ...)
  let opt = a:0 > 0 ? a:1 : "" 
  return s:remove_file_unix(a:path, opt)
endf

func! s:remove_file_unix(path, option)
  let l:cmd = "rm"
  if a:option == "r"
    let l:cmd = l:cmd . " -r"
  endif
  call system(l:cmd . " " . a:path)
  if v:shell_error
    return 1
  endif
  return 0
endf

func! temp#set_src(...)
  if a:0 > 0
    let s:temp_src = a:1
  else
    let s:temp_src = ""
  endif
endf

func! temp#clean()
  if !empty(s:temp_root)
    call s:remove_file(s:temp_root, "r")
  endif
  let s:temp_src   = ""
  let s:temp_root  = ""
endf

func! temp#new(path)

  if empty(s:temp_root)
    let s:temp_root = tempname()
    call mkdir(s:temp_root, "p", 0700)
  endif

  " FIXME: スラッシュで終わるパスは例外にする
  let l:name = simplify(s:temp_root . s:sep . a:path)
  return l:name
endf

func! temp#new_file(path)
  let l:file = temp#new(a:path)
  let l:head = fnamemodify(l:file, ":h")
  if !isdirectory(l:head)
    call mkdir(l:head, "p")
  endif

  execute "redir > ".l:file
  :redir END

  if empty(s:temp_src) != 0
    let l:src = simplify(s:temp_src . s:sep . a:path)
    if filereadable(l:src)
      call s:copy_file(l:src, l:file)
      " FIXME: ignore error
    endif
  endif

  return l:file
endf

func! temp#new_dir(path)
  let l:dir = temp#new(a:path)
  if !isdirectory(l:dir)
    call mkdir(l:dir, "p")
  endif
  return l:dir
endf

func! temp#scope()
  return s:
endf

func! temp#sid()
  return maparg('<SID>', 'n')
endf
nnoremap <SID>  <SID>

let &cpo=s:save_cpo
