" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
call vspec#hint({'scope': 'projectrc#_scope()', 'sid': 'projectrc#_sid()'})

source helper/temp.vim
source helper/buffer.vim

func! s:describe__PathOperation()
  It should succeed with path operation
  " s:normalize_path
  Should Call('s:normalize_path', '/test/test/') == '/test/test'
  Should Call('s:normalize_path', '/test/test') == '/test/test'
  Should Call('s:normalize_path', '/') == '/'
  Should Call('s:normalize_path', '//') == '/'
  " Should Call('s:normalize_path', '///') == '///' "FIXME
  Should Call('s:normalize_path', './') == '.'
  Should Call('s:normalize_path', './test/../test//abc.txt') == simplify('./test/../test//abc.txt')
  Should Call('s:normalize_path', './test/../test//abc//') == './test/abc'
endf

func! s:describe__VimListOperation()
  It should succeed with vim-list operation

  " s:put_value
  Should Call('s:put_value', [],        "a") == ["a"]
  Should Call('s:put_value', ["a","b"], "a") == ["a","b"]

  " s:remove_value
  Should Call('s:remove_value', ["a","b"], "a") == ["b"]
  Should Call('s:remove_value', ["b"],     "a") == ["b"]
  Should Call('s:remove_value', [],        "a") == []
endf

func! s:describe__VimBufferOperation()
  It should succeed with vim-buffer operation

  " s:get_named_buffers
  SetTempSourcePath data
  " TODO ファイルを作成しないオプションを作る
  MakeTempFile noexist_file.txt
  MakeTempFile existed_file.txt

  Should Call('s:get_named_buffers') == []

  execute ":silent! edit " . g:temp_get(0)
  execute ":silent! edit " . g:temp_get(1)
  Should Call('s:get_named_buffers') == [g:temp_bufnr(0), g:temp_bufnr(1)]

  WipeoutAllBuffers
  Should Call('s:get_named_buffers') == []

  CleanTemp
endf
