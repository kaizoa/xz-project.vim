" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
call vspec#hint({'scope': 'projectrc#scope()', 'sid': 'projectrc#sid()'})

require 'test/lib/temp'
require 'test/lib/buffer'

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
    call temp#set_src('data')
    " TODO ファイルを作成しないオプションを作る
    let g:noexist=temp#new_file('noexist_file.txt')
    let g:existed=temp#new_file('existed_file.txt')
  end

  after
    call buffer#wipeoutall()
    call temp#clean()
  end

  it '編集を開始していないのでバッファに追加されていない'
    Expect Call('s:get_named_buffers') == []
  end

  it '編集を開始すると名前つきバッファとして取得できる'
    execute ":silent! edit " . g:noexist
    execute ":silent! edit " . g:existed
    Expect Call('s:get_named_buffers') == [bufnr(g:noexist), bufnr(g:existed)]
  end

  it '編集してワイプアウトするとバッファは消える'
    execute ":silent! edit " . g:noexist
    execute ":silent! edit " . g:existed
    call buffer#wipeoutall()
    Expect Call('s:get_named_buffers') == []
  end
end

describe 'invoke method'

  before
    let g:dict = {}
    func g:dict.test(val)
      return a:val
    endf
  end

  it '呼出に成功する'
    Expect Call('s:invoke_method',g:dict,'test',['hello']) == 'hello'
  end
end
