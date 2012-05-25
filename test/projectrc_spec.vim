" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
call vspec#hint({'scope': 'projectrc#_scope()', 'sid': 'projectrc#_sid()'})

source helper/temp.vim
source helper/buffer.vim
source ../plugin/projectrc.vim

func! s:describe__OpenProject()
  It should open entry

  MakeTempDir  Sample
  let l:temp = Call("s:normalize_path", fnamemodify(g:temp_get(0),":p"))

  execute "ProjectrcOpen " . g:temp_get(0)
  Should Ref("s:rt").entries.get(g:temp_get(0)) != 0
  Should Ref("s:rt").path_link.search_entries(g:temp_get(0)) == [l:temp]

  execute "ProjectrcClose " . g:temp_get(0)

  WipeoutAllBuffers
  CleanTemp
endf

func! s:describe__OpenProjectWithScriptRan()
  It should open entry

  MakeTempDir  Sample
  MakeTempFile Sample/.project.vimrc

  execute "ProjectrcOpen " . g:temp_get(0)
  let l:entry = Ref("s:rt").entries.get(g:temp_get(0))
  Should l:entry['timestamp'] == getftime(g:temp_get(0))

  execute "ProjectrcClose " . g:temp_get(0)

  WipeoutAllBuffers
  CleanTemp
endf

func! s:describe__OpenProjectWhenBufferOpened()
  It should be default when buffer constructed

  MakeTempDir  Sample
  MakeTempFile Sample/.projectrc

  execute ":silent! edit " . g:temp_get(1)
  execute "ProjectrcOpen " . g:temp_get(0)
  let l:entry = Ref("s:rt").entries.get(g:temp_get(0))
  let l:buffer = getbufvar(g:temp_bufnr(1), "projectrc_buffer")

  Should l:buffer.ref_entries == [l:entry.path]
  Should l:entry.ref_buffers == [l:buffer.number]

  WipeoutAllBuffers

  Should l:entry.ref_buffers == []

  execute "ProjectrcClose " . g:temp_get(0)

  CleanTemp
endf

func! s:describe__CloseProject()
  It should close entry

  MakeTempDir  Sample

  execute "ProjectrcOpen " . g:temp_get(0)
  execute "ProjectrcClose " . g:temp_get(0)

  Should Ref("s:rt").entries.get(g:temp_get(0)) == 0
  Should Ref("s:rt").path_link.search_entries(g:temp_get(0)) == []

  WipeoutAllBuffers
  CleanTemp
endf

func! s:describe__OpenBufferWhenProjectOpened()
  It should be default when buffer constructed

  MakeTempDir  Sample
  MakeTempFile Sample/.projectrc

  execute "ProjectrcOpen " . g:temp_get(0)
  execute ":silent! edit " . g:temp_get(1)
  let l:entry = Ref("s:rt").entries.get(g:temp_get(0))
  let l:buffer = getbufvar(g:temp_bufnr(1), "projectrc_buffer")

  Should l:buffer.ref_entries == [l:entry.path]
  Should l:entry.ref_buffers == [l:buffer.number]

  execute "ProjectrcClose " . g:temp_get(0)

  Should l:buffer.ref_entries == []

  WipeoutAllBuffers
  CleanTemp
endf

func! s:describe__Buffer_OpenNOENT()
  It should empty buffer

  MakeTempName noent.txt

  execute ":silent! edit " . g:temp_get(0)
  let l:buffer = getbufvar(g:temp_bufnr(0), "projectrc_buffer")
  Should type(l:buffer) == type({})
  Should len(l:buffer) != 0

  WipeoutAllBuffers
  CleanTemp
endf
