" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
call vspec#hint({'scope': 'projectrc#scope()', 'sid': 'projectrc#sid()'})

require 'plugin/projectrc'
require 'test/lib/temp'
require 'test/lib/buffer'

describe 'プロジェクトを開く'

  before
    let g:rt = Call('s:get_runtime')
    let g:dir = temp#new_dir('Sample')
    execute "ProjectrcOpen " . g:dir
  end

  after
    execute "ProjectrcClose " . g:dir
    call buffer#wipeoutall()
    call temp#clean()
  end

  it 'プロジェクトがエントリーに追加されている'
    Expect g:rt.get_entry(g:dir) != 0
  end

  it 'エントリーの絶対パスがランタイムに追加されている'
    let l:temp = Call("s:normalize_path", fnamemodify(g:dir,":p"))
    Expect g:rt.search_entries(g:dir) == [l:temp]
  end
end

"describe 'OpenProjectWithRCScript'
  
  "before
    "MakeTempDir  Sample
    "MakeTempFile Sample/.project.vimrc
    "execute "ProjectrcOpen " . temp#get(0)
    "let g:rt = Call('s:get_runtime')
  "end

  "after
    "execute "ProjectrcClose " . temp#get(0)
    "call buffer#wipeoutall()
    "call temp#clean()
  "end
"endf

describe '編集中にプロジェクトを開く'

  before
    let g:dir = temp#new_dir('Sample')
    let g:file = temp#new_file('Sample/.projectrc')
    execute ":silent! edit " . g:file
    execute "ProjectrcOpen " . g:dir
    let g:entry = Call("s:get_runtime").get_entry(g:dir)
    let g:buffer = getbufvar(bufnr(g:file), "projectrc_buffer")
  end

  after
    call buffer#wipeoutall()
    execute "ProjectrcClose " . g:dir
    call temp#clean()
  end

  it 'バッファがプロジェクトを保持している'
    Expect g:buffer.ref_entries == [g:entry.path]
  end

  it 'プロジェクトを開いてるバッファ番号を保持している'
    Expect g:entry.ref_buffers == [g:buffer.number]
  end

  it 'バッファを消すとプロジェクトに保持されているバッファ番号も消える'
    call buffer#wipeoutall()
    Expect g:entry.ref_buffers == []
  end
end

describe 'プロジェクトを閉じる'

  before
    let g:dir = temp#new_dir('Sample')
    execute "ProjectrcOpen " . g:dir
    execute "ProjectrcClose " . g:dir
  end

  after
    call buffer#wipeoutall()
    call temp#clean()
  end

  it 'ランタイムのプロジェクトは空'
    Expect Call("s:get_runtime").get_entry(g:dir) == 0
  end

  it 'ランタイムのリンクは空'
    Expect Call("s:get_runtime").search_entries(g:dir) == []
  end

  it '二度閉じる'
    execute "ProjectrcClose " . g:dir
  end
end

describe '保存前のファイル'

  before
    let g:file = temp#new('noent.txt')
    execute ":silent! edit " . g:file
    let g:buffer = getbufvar(bufnr(g:file), "projectrc_buffer")
  end

  after
    call buffer#wipeoutall()
    call temp#clean()
  end

  it 'バッファが作成されている'
    Expect type(g:buffer) == type({})
  end
end
