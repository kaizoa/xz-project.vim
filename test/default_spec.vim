" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
call vspec#hint({'scope': 'projectrc#_scope()', 'sid': 'projectrc#_sid()'})

source helper/temp.vim
source helper/buffer.vim
source ../plugin/projectrc.vim

func! s:describe__DefaultSpec_ProjectrcProjects()
  It should be default when initial state.

  let l:entries = Ref("s:rt").entries

  Should l:entries != 0
  Should len(keys(l:entries))      == 4
  " fields
  Should type(l:entries['map'])    == type({})
  " methods
  Should type(l:entries['get'])    == type(function("tr"))
  Should type(l:entries['put'])    == type(function("tr"))
  Should type(l:entries['remove']) == type(function("tr"))
  " initial values
  "Should l:entries.map             == {}
endf

func! s:describe__DefaultSpec_ProjectrcPathLink()
  It should be default when initial state.

  let l:path_link = Ref("s:rt").path_link

  Should l:path_link != 0
  Should len(keys(l:path_link))     == 4
  " fields
  Should type(l:path_link['table']) == type({})
  " methods
  Should type(l:path_link['link_entry'])    == type(function("tr"))
  Should type(l:path_link['unlink_entry'])  == type(function("tr"))
  Should type(l:path_link['search_entries']) == type(function("tr"))
  " initial values
  Should l:path_link.table == {}
endf

func! s:describe__DefaultSpec_ProjectrcBuffer()
  It should be default when buffer constructed

  MakeTempFile NoExist.java

  " construction
  execute ":silent! edit " . g:temp_get(0)
  let l:buffer = getbufvar(g:temp_bufnr(0), "projectrc_buffer")

  Should l:buffer != 0
  Should len(keys(l:buffer))              == 6
  " fields
  Should type(l:buffer['number'])         == type(0)
  Should type(l:buffer['filepath'])       == type("")
  Should type(l:buffer['ref_entries'])   == type([])
  " methods
  Should type(l:buffer['link_entry'])   == type(function("tr"))
  Should type(l:buffer['unlink_entry']) == type(function("tr"))
  Should type(l:buffer['release'])        == type(function("tr"))
  " initial values
  Should l:buffer.number       == bufnr(g:temp_get(0))
  Should l:buffer.filepath     == fnamemodify(g:temp_get(0), ":p")
  Should l:buffer.ref_entries == []

  " destruction
  WipeoutAllBuffers

  CleanTemp
endf

func! s:describe__DefaultSpec_ProjectrcProject()
  It should be default when entry constructed

  MakeTempDir  Sample

  " construction
  execute "ProjectrcOpen " . g:temp_get(0)
  let l:temp = Call("s:normalize_path", fnamemodify(g:temp_get(0),":p"))
  let l:entry = Ref("s:rt").entries.get(g:temp_get(0))

  Should l:entry != 0
  Should len(keys(l:entry))             == 10
  " fields
  Should type(l:entry['path'])          == type("")
  Should type(l:entry['is_init'])       == type(0)
  Should type(l:entry['timestamp'])     == type(0)
  Should type(l:entry['ref_paths'])     == type([])
  Should type(l:entry['ref_buffers'])   == type([])
  " methods
  Should type(l:entry['init'])          == type(function("tr"))
  Should type(l:entry['release'])       == type(function("tr"))
  Should type(l:entry['link_path'])     == type(function("tr"))
  Should type(l:entry['link_buffer'])   == type(function("tr"))
  Should type(l:entry['unlink_buffer']) == type(function("tr"))
  " initial values
  Should l:entry['path']          == l:temp
  Should l:entry['is_init']       == 1
  Should l:entry['timestamp']     == 0
  Should l:entry['ref_paths']     == [l:temp]
  Should l:entry['ref_buffers']   == []

  " destruction
  execute "ProjectrcClose " . g:temp_get(0)

  WipeoutAllBuffers
  CleanTemp
endf

