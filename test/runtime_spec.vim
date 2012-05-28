" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
call vspec#hint({'scope': 'projectrc#scope()', 'sid': 'projectrc#sid()'})

source helper/temp.vim
source helper/buffer.vim

describe 'Runtime'

  it 'バージョン1.0.0'
    Expect Call("s:get_version") == "1.0.0"
  end

  "it 'バージョン1.0.0 - 2'
  "  Expect Call("s:Runtime") toBeTrue
  "end

  it 'ランタイムが初期化されている'
    Expect Call("s:get_runtime") isnot 0
  end

end
