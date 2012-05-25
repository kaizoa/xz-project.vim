" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
call vspec#hint({'scope': 'projectrc#_scope()', 'sid': 'projectrc#_sid()'})

source helper/temp.vim
source helper/buffer.vim

function! s:describe__OpenProject()

  MakeTempDir  Sample
  let l:tmp_abs = fnamemodify(g:temp_get(0),":p")

  execute "ProjectrcOpen " . g:temp_get(0)
  "Should Ref("s:projects").get(l:tmp_abs) != 0
  Should Call("s:projects.get", l:tmp_abs) != 0
  "Should Ref("s:path_link").search_projects(l:tmp_abs) == [l:tmp_abs]
  "echo Ref("s:projects").get(l:tmp_abs)
  "echo Ref("s:path_link")
  "echo Ref("s:path_link").search_projects(l:tmp_abs)

  execute "ProjectrcClose " . g:temp_get(0)

  WipeoutAllBuffers
  CleanTemp
endfunction
