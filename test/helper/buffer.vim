" vim:set ts=8 sts=2 sw=2 tw=0:
let s:save_cpo=&cpo
set cpo&vim

command! WipeoutAllBuffers :execute "silent! bw! ".join(range(1, bufnr("$")), " ")

func! g:buffer_scope()
  return s:
endf

func! g:buffer_sid()
  return maparg('<SID>', 'n')
endf
nnoremap <SID>  <SID>

let &cpo=s:save_cpo
