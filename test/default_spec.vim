" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
call vspec#hint({'scope': 'projectrc#scope()', 'sid': 'projectrc#sid()'})

func! _require(path)
  for script_file in split(globpath(&runtimepath, a:path), '\n')
    execute "source " . script_file
    break
  endfor
endf

call _require("plugin/projectrc.vim")
call _require("test/helper/temp.vim")
call _require("test/helper/buffer.vim")

describe 'Runtime'

  before
    let g:rt = Call('s:get_runtime')
  end

  after
    unlet g:rt
  end

  it 'フィールド定義'
    Expect type(g:rt.entries)   == type({})
    Expect type(g:rt.path_link) == type({})
  end

  it 'フィールド初期値'
    Expect g:rt.entries   == {}
    Expect g:rt.path_link == {}
  end

  it 'メソッド定義'
    Expect type(g:rt['init_workingset']) == type(function("tr"))
    Expect type(g:rt['get_entry'])       == type(function("tr"))
    Expect type(g:rt['put_entry'])       == type(function("tr"))
    Expect type(g:rt['remove_entry'])    == type(function("tr"))
    Expect type(g:rt['link_entry'])      == type(function("tr"))
    Expect type(g:rt['unlink_entry'])    == type(function("tr"))
    Expect type(g:rt['search_entries'])  == type(function("tr"))
  end
end

describe 'Buffer'

  before
    MakeTempFile NoExist.java
    execute ":silent! edit " . g:temp_get(0)
    let g:buffer = getbufvar(g:temp_bufnr(0), "projectrc_buffer")
  end

  after
    WipeoutAllBuffers
    CleanTemp
    unlet g:buffer
  end

  it 'フィールド定義'
    Expect type(g:buffer['number'])      == type(0)
    Expect type(g:buffer['filepath'])    == type("")
    Expect type(g:buffer['ref_entries']) == type([])
  end

  it 'フィールド初期値'
    Expect g:buffer.number      == bufnr(g:temp_get(0))
    Expect g:buffer.filepath    == fnamemodify(g:temp_get(0), ":p")
    Expect g:buffer.ref_entries == []
  end

  it 'メソッド定義'
    Expect type(g:buffer['link_entry'])   == type(function("tr"))
    Expect type(g:buffer['unlink_entry']) == type(function("tr"))
    Expect type(g:buffer['release'])      == type(function("tr"))
  end
end

describe 'Entry'

  before
    MakeTempDir  Sample
    execute "ProjectrcOpen " . g:temp_get(0)
    let g:temp = Call("s:normalize_path", fnamemodify(g:temp_get(0),":p"))
    let g:entry = Call("s:get_runtime").get_entry(g:temp_get(0))
  end

  after
    execute "ProjectrcClose " . g:temp_get(0)
    WipeoutAllBuffers
    CleanTemp
    unlet g:temp
    unlet g:entry
  end

  it 'フィールド定義'
    Expect type(g:entry['path'])        == type("")
    Expect type(g:entry['is_init'])     == type(0)
    Expect type(g:entry['ref_paths'])   == type([])
    Expect type(g:entry['ref_buffers']) == type([])
  end

  it 'フィールド初期値'
    Expect g:entry['path']        == g:temp
    Expect g:entry['is_init']     == 1
    Expect g:entry['ref_paths']   == [g:temp]
    Expect g:entry['ref_buffers'] == []
  end

  it 'メソッド定義'
    Expect type(g:entry['init'])          == type(function("tr"))
    Expect type(g:entry['release'])       == type(function("tr"))
    Expect type(g:entry['link_path'])     == type(function("tr"))
    Expect type(g:entry['link_buffer'])   == type(function("tr"))
    Expect type(g:entry['unlink_buffer']) == type(function("tr"))
  end
end

