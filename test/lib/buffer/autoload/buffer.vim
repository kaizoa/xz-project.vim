" vim:set ts=8 sts=2 sw=2 tw=0:
let s:save_cpo=&cpo
set cpo&vim

func! buffer#wipeoutall()
  execute "silent! bw! ".join(range(1, bufnr("$")), " ")
endf

func! buffer#scope()
  return s:
endf

func! buffer#sid()
  return maparg('<SID>', 'n')
endf
nnoremap <SID>  <SID>

let &cpo=s:save_cpo
