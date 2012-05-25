" vim:set ts=8 sts=2 sw=2 tw=0:

let s:save_cpo=&cpo
set cpo&vim

augroup Projectrc
  au! 
  au BufAdd * call projectrc#au_BufAdd(str2nr(expand("<abuf>")))
  au BufWipeout  * call projectrc#au_BufWipeout(str2nr(expand("<abuf>")))
augroup END

let s:rt = {
  \'workingset' : 'default',
  \'entries'    : { "map"   : {} },
  \'path_link'  : { "table" : {} },
  \'log' : []
\}

func! projectrc#get_initializing()
  if exists("s:initializing")
    return s:initializing
  endif

  return 0
endf

" プロジェクトを開きます
" @param entry_path
func! projectrc#cmd_Open(entry_path)
  let l:path_abs = fnamemodify(a:entry_path, ":p")
  let l:entry = s:rt.entries.get(l:path_abs)

  if empty(l:entry)
    unlet l:entry
    let l:entry = s:new_entry(l:path_abs)
  endif

  call l:entry.init( globpath(l:path_abs, ".project.vimrc") )
endf

" プロジェクトを閉じます。
" @param entry_path
func! projectrc#cmd_Close(entry_path)
  let l:path_abs = fnamemodify(a:entry_path, ":p")
  let l:entry = s:rt.entries.get(l:path_abs)

  if !empty(l:entry)
    call l:entry.release()
    call s:rt.entries.remove(l:entry.path)
  endif
endf

" バッファの編集開始
func! projectrc#au_BufAdd(buffer_num)
  call s:open_buffer(a:buffer_num)
endf

" バッファをワイプアウトする直前
func! projectrc#au_BufWipeout(buffer_num)
  let l:buffer = s:get_buffer(a:buffer_num)
  if !empty(l:buffer)
    call l:buffer.release()
  endif
endf

func! s:rt.init_workingset() dict
  if !isdirectory('~/.projectrc/')
    call mkdir('~/.projectrc')
  endif
  if !isdirectory('~/.projectrc/ws')
    call mkdir('~/.projectrc/ws')
  endif
  if !filereadable('~/.projectrc/ws/'.self.workingset)
  endif
endf

" プロジェクトリストから指定したパスのプロジェクトを取得
" 見つからない場合は空のディクショナリを返す
func! s:rt.entries.get(entry_path) dict
  let l:entry_path = s:normalize_path(a:entry_path)

  if has_key(self.map, l:entry_path)
   return self.map[l:entry_path]
  endif

  return 0
endf

" プロジェクトリストにプロジェクトを配置します。
func! s:rt.entries.put(entry) dict
  let s:rt.entries.map[a:entry.path] = a:entry
endf

" プロジェクトリストから指定パスのプロジェクトを削除します。
func! s:rt.entries.remove(entry_path) dict
  let l:entry_path = s:normalize_path(a:entry_path)

  call remove(s:rt.entries.map, l:entry_path)
endf

" パスリンクにパスとプロジェクトを関連付けする
func! s:rt.path_link.link_entry(path_key, entry) dict
  let l:path_key = s:normalize_path(a:path_key)

  if !has_key(self.table, l:path_key)
    let self.table[l:path_key] = []
  endif

  for entry_path in self.table[l:path_key]
    if entry_path == a:entry.path
      return
    endif
  endfor

  call add(self.table[a:path_key], a:entry.path)
endf

" パスリンクから関連付けを削除する
func! s:rt.path_link.unlink_entry(path_key, entry) dict
  let l:path_key = s:normalize_path(a:path_key)

  if !has_key(self.table, l:path_key)
    return
  endif

  call s:remove_value(self.table[l:path_key], a:entry.path)
  if len(self.table[l:path_key]) == 0
    call remove(self.table, l:path_key)
  endif
endf

" パスリンクから指定したパスに関連付けされているプロジェクトのリストを取得する
func! s:rt.path_link.search_entries(filepath) dict
  let l:dir_abs = fnamemodify(a:filepath, ":p:h") " normalized
  let l:link_keys = keys(self.table)
  let l:prjs = []

  for path_key in l:link_keys
    if path_key <=# l:dir_abs
      let l:prjs += self.table[path_key]
    endif
  endfor

  return l:prjs
endf

" プロジェクトを作成する
func! s:new_entry(path_abs)
  let l:path_abs = s:normalize_path(a:path_abs)
  let l:entry = {
    \"path" : l:path_abs,
    \"is_init" : 0,
    \"timestamp" : 0,
    \"ref_paths" : [],
    \"ref_buffers" : []
  \}

  func! l:entry.init(rc_path) dict
    if self.is_init
      call self.release()
    endif
    call self.link_path(self.path)
    " load
    let s:initializing = self
    if filereadable(a:rc_path)
      try
        execute ":source" . a:rc_path
        let self.timestamp = getftime(a:rc_path)
      catch
        " TODO quickfix
        "echo v:throwpoint
        " TODO オブジェクトを捨てる
      endtry
    endif
    let self.is_init=1
    unlet s:initializing
  endf

  func! l:entry.release() dict
    for ref_path in self.ref_paths
      call s:rt.path_link.unlink_entry(ref_path, self)
    endfor
    for buffer_num in self.ref_buffers
      let l:buffer = s:get_buffer(buffer_num)
      if !empty(l:buffer)
        call l:buffer.unlink_entry(self)
      endif
    endfor
    let self.is_init=0
    let self.timestamp=0
    let self.ref_paths=[]
    let self.ref_buffers=[]
  endf

  func! l:entry.link_path(ref_path) dict
    let l:ref_path = s:normalize_path(a:ref_path)
    for rpath in self.ref_paths
      if rpath == l:ref_path
        return
      endif
    endfor

    call add(self.ref_paths, l:ref_path)
    call s:rt.path_link.link_entry(l:ref_path, self)
  endf

  func! l:entry.link_buffer(buffer_num) dict
    for bnum in self.ref_buffers
      if bnum == a:buffer_num
        return
      endif
    endfor
    call add(self.ref_buffers, a:buffer_num)
  endf

  func! l:entry.unlink_buffer(buffer_num) dict
    call s:remove_value(self.ref_buffers, a:buffer_num)
  endf

  let l:bufnrs = s:get_named_buffers()
  for i in l:bufnrs
    if l:entry.path <=# fnamemodify(bufname(i), ":p")
      call l:entry.link_buffer(i)
      let l:buffer = s:open_buffer(i)
      if !empty(l:buffer)
        call l:buffer.link_entry(l:entry)
      endif
      unlet l:buffer
    endif
  endfor
  call s:rt.entries.put(l:entry)

  return l:entry
endf

" バッファー番号からプロジェクト参照オブジェクトを取得します。
func! s:get_buffer(buffer_num)
  if !bufexists(a:buffer_num)
    return 0
  endif
  return getbufvar(a:buffer_num, "projectrc_buffer")
endf

" 指定されたバッファー番号を有効化します
func! s:open_buffer(buffer_num)
  if !empty(getbufvar(a:buffer_num, "&buftype"))
    call projectrc#log("nofile")
    return 0
  endif
  call projectrc#log("empty")
  if empty(bufname(a:buffer_num))
    return 0
  endif

  let l:buffer = s:get_buffer(a:buffer_num)
  if !empty(l:buffer)
    return l:buffer
  endif

  return s:new_buffer(a:buffer_num)
endf

" バッファーにプロジェクト参照オブジェクトを作成します。
" すでに開いてるプロジェクトで関連するプロジェクトがあれば
" 関連付けを行います。
func! s:new_buffer(buffer_num)
  if !bufexists(a:buffer_num)
    return 0
  endif

  let l:filepath = s:normalize_path(fnamemodify(bufname(a:buffer_num), ":p"))
  let l:buffer = {
    \"number" : a:buffer_num,
    \"filepath" : l:filepath,
    \"ref_entries" : []
  \}

  func! l:buffer.release() dict
    for entry_path in self.ref_entries
      let l:entry = s:rt.entries.get(entry_path)
      call l:entry.unlink_buffer(self.number)
    endfor
    let self.ref_entries = []
  endf

  func! l:buffer.link_entry(entry)
    call s:put_value(self.ref_entries, a:entry.path)
  endf

  func! l:buffer.unlink_entry(entry)
    call s:remove_value(self.ref_entries, a:entry.path)
  endf

  let l:entry_paths = s:rt.path_link.search_entries(l:filepath)
  for entry_path in l:entry_paths
    call add(l:buffer.ref_entries, entry_path)
    let l:entry = s:rt.entries.get(entry_path)
    call l:entry.link_buffer(a:buffer_num)
  endfor

  call setbufvar(a:buffer_num, "projectrc_buffer", l:buffer)

  return l:buffer
endf

" パスを正規化します
func! s:normalize_path(filepath)
  let l:simple_path = simplify(a:filepath)
  if len(l:simple_path) < 2
    return l:simple_path
  endif
  if strpart(l:simple_path, len(l:simple_path)-1) != "/"
    return l:simple_path
  endif
  return strpart(l:simple_path, 0, len(l:simple_path)-1)
endf

" リストに値を追加します。重複する場合は何もしません。
func! s:put_value(list, value)
  for i in a:list
    " TODO case sensitive?
    if i == a:value
      return a:list
    endif
  endfor
  call add(a:list, a:value)
  return a:list
endf

" リストから値を削除します
func! s:remove_value(list, value)
  let i  = 0

  while i < len(a:list)
    " TODO case sensitive?
    if a:list[i] == a:value
      break
    endif
    let i = i + 1
  endwhile

  if i < len(a:list)
    call remove(a:list, i)
  endif
  return a:list
endf

" 名前付きバッファの一覧を取得します。
func! s:get_named_buffers()
  let l:list = []
  for nbuf in range(1, bufnr("$"))
    if bufexists(nbuf) && !empty(bufname(nbuf))
      call add(l:list, nbuf)
    endif
  endfor
  return l:list
endf

func! projectrc#log(...)
  if a:0 > 0
    call add(s:rt.log, a:1)
  endif
  return s:rt.log
endf

func! projectrc#debug()
  echo s:rt
endf

func! projectrc#debug_buffer()
  echo s:get_buffer(bufnr("%"))
endf

func! projectrc#_scope()
  return s:
endf

" TODO これが何をしてるかよくわからない
func! projectrc#_sid()
  return maparg('<SID>', 'n')
endf
nnoremap <SID>  <SID>

let &cpo=s:save_cpo
