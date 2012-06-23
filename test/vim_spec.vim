
describe '一時ディレクトリ'

  before
    let g:name = tempname()
  end

  after
    if isdirectory(g:name)
      
    endif
  end

  it '作成前は存在しない'
    Expect isdirectory(g:name) ==  0
  end

  it '取得した名前でディレクトリが作成できる'
    call mkdir(l:name, "p", 0700)
    Expect isdirectory(g:name) !=  0
  end
end

describe 'simplify()'
  it '不要なスラッシュを消す'
    Expect simplify("test//data.txt") == "test/data.txt"
    Expect simplify("test///data.txt") == "test/data.txt"
    Expect simplify("test////data.txt") == "test/data.txt"
  end
end

describe 'fnamemodify()'
  it ':h 基底パスの取り出し'
    Expect fnamemodify("abc/test/data/", ":h") == "abc/test/"
  end
end

" vim:set ft=vim ts=8 sts=2 sw=2 tw=0:
