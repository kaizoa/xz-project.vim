" vim:set ts=8 sts=2 sw=2 tw=0:

let s:save_cpo=&cpo
set cpo&vim

command! -nargs=+ ProjectrcOpen  :call projectrc#cmd_Open(<f-args>)
command! -nargs=+ ProjectrcClose :call projectrc#cmd_Close(<f-args>)
command! ProjectrcDebug :call projectrc#debug()
command! ProjectrcDebugBuffer :call projectrc#debug_buffer()
command! ProjectrcLog :call s:show_log()

func! s:show_log()
  let logs = projectrc#log()
  for log in logs
    echo log
  endfor
endf

let &cpo=s:save_cpo
