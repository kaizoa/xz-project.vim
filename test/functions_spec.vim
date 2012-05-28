" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:

echo split(globpath(&runtimepath, 'autoload/vspec.vim'), '\n')

func! Require(path)
  for script_file in split(globpath(&runtimepath, a:path), '\n')
    execute "source " . script_file
  endfor
endf

call vspec#hint({'scope': 'projectrc#scope()', 'sid': 'projectrc#sid()'})

call Require("test/helper/temp.vim")
call Require("test/helper/buffer.vim")

describe 'normalize path'

  it '終端のスラッシュは消す'
    Expect Call('s:normalize_path', '/test/test') == '/test/test'
    Expect Call('s:normalize_path', '/test/test/') == '/test/test'
    Expect Call('s:normalize_path', './') == '.'
  end

  it 'スラッシュ2つは1つとして扱う'
    " FIXME 先頭の//はそのままでも良いかも
    Expect Call('s:normalize_path', '/') == '/'
    Expect Call('s:normalize_path', '//') == '/'
    " Expect Call('s:normalize_path', '///') == '///' "FIXME
    Expect Call('s:normalize_path', './test/../test//abc.txt') == simplify('./test/../test//abc.txt')
    Expect Call('s:normalize_path', './test/../test//abc//') == './test/abc'
  end
end

describe 'list operation'

  it '存在しない値をリストに追加できる'
    Expect Call('s:put_value', [], "a") == ["a"]
  end

  it '存在する値はリストに追加しないので重複しない'
    Expect Call('s:put_value', ["a","b"], "a") == ["a","b"]
  end

  it '存在する値をリストから削除できる'
    Expect Call('s:remove_value', ["a","b"], "a") == ["b"]
  end

  it '存在しない値を削除しても何も起こらない'
    Expect Call('s:remove_value', ["b"], "a") == ["b"]
    Expect Call('s:remove_value', [],    "a") == []
  end
end

describe 'buffer operation'

  before
    SetTempSourcePath data
    " TODO ファイルを作成しないオプションを作る
    MakeTempFile noexist_file.txt
    MakeTempFile existed_file.txt
  end

  after
    WipeoutAllBuffers
    CleanTemp
  end

  it '編集を開始していないのでバッファに追加されていない'
    Expect Call('s:get_named_buffers') == []
  end

  it '編集を開始すると名前つきバッファとして取得できる'
    execute ":silent! edit " . g:temp_get(0)
    execute ":silent! edit " . g:temp_get(1)
    Expect Call('s:get_named_buffers') == [g:temp_bufnr(0), g:temp_bufnr(1)]
  end

  it '編集してワイプアウトするとバッファは消える'
    execute ":silent! edit " . g:temp_get(0)
    execute ":silent! edit " . g:temp_get(1)
    WipeoutAllBuffers
    Expect Call('s:get_named_buffers') == []
  end
end
