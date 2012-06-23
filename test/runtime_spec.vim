" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
call vspec#hint({'scope': 'projectrc#scope()', 'sid': 'projectrc#sid()'})

describe 'Runtime'

  it 'ランタイムが初期化されている'
    Expect Call("s:get_runtime") isnot 0
  end

end
