" vim:set ts=8 sts=2 sw=2 tw=0:
let s:save_cpo=&cpo
set cpo&vim

command! -nargs=* SetTempSourcePath :call s:set_temp_src(<f-args>)
command! -nargs=+ MakeTempName :call g:temp_new(<f-args>)
command! -nargs=+ MakeTempFile :call g:temp_new_file(<f-args>)
command! -nargs=+ MakeTempDir :call g:temp_new_dir(<f-args>)
command! CleanTemp :call s:clean_temp()

" TODO OS判定
let s:sep = "/"
let s:temp_src = ""
let s:temp_root = ""
let s:temp_files = []

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

func! s:set_temp_src(...)
  if a:0 > 0
    let s:temp_src = a:1
  else
    let s:temp_src = ""
  endif
endf

func! s:clean_temp()
  if !empty(s:temp_root)
    call s:remove_file(s:temp_root, "r")
  endif
  let s:temp_src   = ""
  let s:temp_root  = ""
  let s:temp_files = []
endf

func! g:temp_get(index)
  if a:index < len(s:temp_files)
    return s:temp_files[a:index]
  endif
  return ""
endf

func! g:temp_bufnr(indexOrPath)
  if type(a:indexOrPath) == type(0)
    return bufnr(g:temp_get(a:indexOrPath))
  elseif type(a:indexOrPath) == type("")
    return bufnr(a:indexOrPath)
  endif
  return 0
endf

func! g:temp_new(path)

  if empty(s:temp_root)
    let s:temp_root = tempname()
    call mkdir(s:temp_root, "p", 0700)
  endif

  " FIXME: スラッシュで終わるパスは例外にする
  let l:name = simplify(s:temp_root . s:sep . a:path)
  call add(s:temp_files, l:name)
  return l:name
endf

func! g:temp_new_file(path)
  let l:file = g:temp_new(a:path)
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

func! g:temp_new_dir(path)
  let l:dir = g:temp_new(a:path)
  if !isdirectory(l:dir)
    call mkdir(l:dir, "p")
  endif
  return l:dir
endf

func! g:temp_scope()
  return s:
endf

func! g:temp_sid()
  return maparg('<SID>', 'n')
endf
nnoremap <SID>  <SID>

let &cpo=s:save_cpo
