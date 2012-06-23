echo "echo"

let s:context = projectrc#new_context()

func! s:context.on_link_vim(bufnum) dict
  let g:d_vim = get(g:, 'd_vim', [])
  call add(g:d_vim, 'test')
endf

func! s:context.on_link(bufnum) dict
  let g:debug_prj = 'link! '.a:bufnum
endf

func! s:context.on_unlink(bufnum) dict
  let g:debug_prj = 'unlink! '.a:bufnum
endf
