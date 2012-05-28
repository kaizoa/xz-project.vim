" vim:set ts=8 sts=2 sw=2 tw=0:

let s:save_cpo=&cpo
set cpo&vim

augroup Projectrc
  au! 
  au BufAdd * call projectrc#au_BufAdd(str2nr(expand("<abuf>")))
  au BufWipeout  * call projectrc#au_BufWipeout(str2nr(expand("<abuf>")))
augroup END

" プロジェクトを開きます
" @param entry_path
func! projectrc#cmd_Open(entry_path)
  let l:rt = s:get_runtime()
  let l:path_abs = fnamemodify(a:entry_path, ":p")
  let l:entry = l:rt.get_entry(l:path_abs)

  if empty(l:entry)
    unlet l:entry
    let l:entry = s:Entry(l:rt, l:path_abs)
  endif

  call l:entry.init( globpath(l:path_abs, ".project.vimrc") )
endf

" プロジェクトを閉じます。
" @param entry_path
func! projectrc#cmd_Close(entry_path)
  let l:rt = s:get_runtime()
  let l:path_abs = fnamemodify(a:entry_path, ":p")
  let l:entry = l:rt.get_entry(l:path_abs)

  if !empty(l:entry)
    call l:entry.release()
    call l:rt.remove_entry(l:entry.path)
  endif
endf

" バッファの編集開始
func! projectrc#au_BufAdd(buffer_num)
  call s:Buffer(s:get_runtime(), a:buffer_num)
endf

" バッファをワイプアウトする直前
func! projectrc#au_BufWipeout(buffer_num)
  let l:buffer = s:get_buffer(a:buffer_num)
  if !empty(l:buffer)
    call l:buffer.release()
  endif
endf

func! projectrc#get_rc_context()
  if exists("s:rc_context")
    return s:rc_context
  endif

  return 0
endf

func! projectrc#log(...)
  if a:0 > 0
    call add(s:get_runtime().log, a:1)
  endif
  return s:get_runtime().log
endf

func! projectrc#debug()
  echo s:get_runtime()
endf

func! projectrc#debug_buffer()
  echo s:get_buffer(bufnr("%"))
endf

" ランタイム
func! s:Runtime()

  let l:runtime = {
    \'workingset' : 'default',
    \'entries'    : {},
    \'path_link'  : {},
    \'log' : []
  \}

  func! l:runtime.init_workingset() dict
    if !isdirectory('~/.projectrc/')
      call mkdir('~/.projectrc')
    endif
    if !isdirectory('~/.projectrc/ws')
      call mkdir('~/.projectrc/ws')
    endif
    if !filereadable('~/.projectrc/ws/'.self.workingset)
    endif
  endf

  " 指定したパスのプロジェクトを取得
  " 見つからない場合は空のディクショナリを返す FIXME
  func! l:runtime.get_entry(entry_path) dict
    let l:entry_path = s:normalize_path(a:entry_path)

    if has_key(self.entries, l:entry_path)
     return self.entries[l:entry_path]
    endif

    return 0
  endf

  " プロジェクトリストにプロジェクトを配置します。
  func! l:runtime.put_entry(entry) dict
    let self.entries[a:entry.path] = a:entry
  endf

  " プロジェクトリストから指定パスのプロジェクトを削除します。
  func! l:runtime.remove_entry(entry_path) dict
    let l:entry_path = s:normalize_path(a:entry_path)

    call remove(self.entries, l:entry_path)
  endf

  " パスリンクにパスとプロジェクトを関連付けする
  func! l:runtime.link_entry(path_key, entry) dict
    let l:path_key = s:normalize_path(a:path_key)

    if !has_key(self.path_link, l:path_key)
      let self.path_link[l:path_key] = []
    endif

    for entry_path in self.path_link[l:path_key]
      if entry_path == a:entry.path
        return
      endif
    endfor

    call add(self.path_link[a:path_key], a:entry.path)
  endf

  " パスリンクから関連付けを削除する
  func! l:runtime.unlink_entry(path_key, entry) dict
    let l:path_key = s:normalize_path(a:path_key)

    if !has_key(self.path_link, l:path_key)
      return
    endif

    call s:remove_value(self.path_link[l:path_key], a:entry.path)
    if len(self.path_link[l:path_key]) == 0
      call remove(self.path_link, l:path_key)
    endif
  endf

  " パスリンクから指定したパスに関連付けされているプロジェクトのリストを取得する
  func! l:runtime.search_entries(filepath) dict
    let l:dir_abs = fnamemodify(a:filepath, ":p:h") " normalized
    let l:link_keys = keys(self.path_link)
    let l:prjs = []

    for path_key in l:link_keys
      if path_key <=# l:dir_abs
        let l:prjs += self.path_link[path_key]
      endif
    endfor

    return l:prjs
  endf

  return l:runtime
endf

" プロジェクトを作成する
func! s:Entry(rt, path_abs)
  let l:path_abs = s:normalize_path(a:path_abs)
  let l:entry = {
    \"rt"          : a:rt,
    \"path"        : l:path_abs,
    \"is_init"     : 0,
    \"ref_paths"   : [],
    \"ref_buffers" : []
  \}

  " 初期化スクリプトを読み込む
  func! l:entry.init(rc_path) dict
    if self.is_init
      call self.release()
    endif
    call self.link_path(self.path)
    " load
    let s:rc_context = self
    if filereadable(a:rc_path)
      try
        execute ":source" . a:rc_path
      catch
        " TODO quickfix
        "echo v:throwpoint
        " TODO オブジェクトを捨てる
      endtry
    endif
    let self.is_init=1
    unlet s:rc_context
  endf

  " プロジェクトを開放します
  " 参照しているパスとバッファーのリンクの解除します
  func! l:entry.release() dict
    for ref_path in self.ref_paths
      call self.rt.unlink_entry(ref_path, self)
    endfor
    for buffer_num in self.ref_buffers
      let l:buffer = s:get_buffer(buffer_num)
      if !empty(l:buffer)
        call l:buffer.unlink_entry(self)
      endif
    endfor
    let self.is_init=0
    let self.ref_paths=[]
    let self.ref_buffers=[]
  endf

  " 参照先のパスをこのプロジェクトに関連付けします
  func! l:entry.link_path(ref_path) dict
    let l:ref_path = s:normalize_path(a:ref_path)
    for rpath in self.ref_paths
      if rpath == l:ref_path
        return
      endif
    endfor

    call add(self.ref_paths, l:ref_path)
    call self.rt.link_entry(l:ref_path, self)
  endf

  " バッファー番号をこのプロジェクトに関連付けします
  func! l:entry.link_buffer(buffer_num) dict
    for bnum in self.ref_buffers
      if bnum == a:buffer_num
        return
      endif
    endfor
    call add(self.ref_buffers, a:buffer_num)
  endf

  " バッファー番号をこのプロジェクトから関連付け解除します
  func! l:entry.unlink_buffer(buffer_num) dict
    call s:remove_value(self.ref_buffers, a:buffer_num)
  endf

  let l:bufnrs = s:get_named_buffers()
  for i in l:bufnrs
    if l:entry.path <=# fnamemodify(bufname(i), ":p")
      call l:entry.link_buffer(i)
      let l:buffer = s:Buffer(a:rt, i)
      if !empty(l:buffer)
        call l:buffer.link_entry(l:entry)
      endif
      unlet l:buffer
    endif
  endfor
  call a:rt.put_entry(l:entry)

  return l:entry
endf

" バッファーにプロジェクト参照オブジェクトを作成します。
" すでに開いてるプロジェクトで関連するプロジェクトがあれば
" 関連付けを行います。
func! s:Buffer(rt, buffer_num)

  if !bufexists(a:buffer_num)
    " TODO 例外
    return 0
  endif

  if !empty(getbufvar(a:buffer_num, "&buftype"))
    " TODO 例外
    call projectrc#log("nofile")
    return 0
  endif

  if empty(bufname(a:buffer_num))
    " TODO 例外
    call projectrc#log("empty")
    return 0
  endif

  let l:cached = s:get_buffer(a:buffer_num)
  if !empty(l:cached)
    return l:cached
  endif

  let l:filepath = s:normalize_path(fnamemodify(bufname(a:buffer_num), ":p"))
  let l:buffer = {
    \"rt" : a:rt,
    \"number" : a:buffer_num,
    \"filepath" : l:filepath,
    \"ref_entries" : []
  \}

  " このバッファーを開放します
  " 関連付けされているプロジェクトを加除します
  func! l:buffer.release() dict
    for entry_path in self.ref_entries
      let l:entry = self.rt.get_entry(entry_path)
      call l:entry.unlink_buffer(self.number)
    endfor
    let self.ref_entries = []
  endf

  " このバッファーにプロジェクトを関連付けします
  func! l:buffer.link_entry(entry)
    call s:put_value(self.ref_entries, a:entry.path)
  endf

  " このバッファーに関連付けされているプロジェクトを解除します
  func! l:buffer.unlink_entry(entry)
    call s:remove_value(self.ref_entries, a:entry.path)
  endf

  let l:entry_paths = self.rt.search_entries(l:filepath)
  for entry_path in l:entry_paths
    call add(l:buffer.ref_entries, entry_path)
    let l:entry = self.rt.get_entry(entry_path)
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

let s:rt = s:Runtime()

func! s:get_runtime()
  return s:rt
endf

" バッファー番号からプロジェクト参照オブジェクトを取得します。
func! s:get_buffer(buffer_num)
  if !bufexists(a:buffer_num)
    return 0
  endif
  return getbufvar(a:buffer_num, "projectrc_buffer")
endf

func! projectrc#scope()
  return s:
endf

func! projectrc#sid()
  return maparg('<SID>', 'n')
endf
nnoremap <SID>  <SID>

let &cpo=s:save_cpo
