" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
call vspec#hint({'scope': 'projectrc#scope()', 'sid': 'projectrc#sid()'})

require 'plugin/projectrc'
require 'test/lib/temp'
require 'test/lib/buffer'

describe 'Runtime'

  before
    let g:rt = Call('s:get_runtime')
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
    let g:file = temp#new_file('NoExist.java')
    execute ":silent! edit " . g:file
    let g:buffer = getbufvar(bufnr(g:file), "projectrc_buffer")
  end

  after
    call buffer#wipeoutall()
    call temp#clean()
  end

  it 'フィールド定義'
    Expect type(g:buffer['number'])      == type(0)
    Expect type(g:buffer['filepath'])    == type("")
    Expect type(g:buffer['ref_entries']) == type([])
  end

  it 'フィールド初期値'
    Expect g:buffer.number      == bufnr(g:file)
    Expect g:buffer.filepath    == fnamemodify(g:file, ":p")
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
    let g:dir = temp#new_dir('Sample')
    execute "ProjectrcOpen " . g:dir
    let g:temp = Call("s:normalize_path", fnamemodify(g:dir,":p"))
    let g:entry = Call("s:get_runtime").get_entry(g:dir)
  end

  after
    execute "ProjectrcClose " . g:dir
    call buffer#wipeoutall()
    call temp#clean()
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

