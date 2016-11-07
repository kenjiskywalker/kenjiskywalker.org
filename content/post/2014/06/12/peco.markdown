---
layout: post
title: "pecoを導入してzshのhistoryに使うようにした"
published: true
date: "2014-06-12T16:48:00+09:00"
comments: true


---

## TL;DR

peco入れた。速い


## peco

[https://github.com/lestrrat/peco](https://github.com/lestrrat/peco)

まだターミナルのヒストリの絞り込みぐらいしか使っていないけど便利です。  

## percol
  
[https://github.com/mooz/percol](https://github.com/mooz/percol)
  
元々moozさんが書いたpercolというものがあってlestrratさんがGoで書いたものがpeco。  
  

## 導入方法

- peco を go get

```
$ go get github.com/lestrrat/peco/cmd/peco/
```

## .zshrc

percolのものを流用させて頂きました。

```
function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history
```

##  ~/.peco/config.json

C-c でキャンセルできるように

```
{
    "Keymap": {
        "C-p": "peco.SelectPrevious",
        "C-n": "peco.SelectNext",
        "C-c": "peco.Cancel"
    }
}
```

![http://gifzo.net/BE8NmHmus2A.gif](http://gifzo.net/BE8NmHmus2A.gif)  

> いまいちなキャプチャだこれ  
  
[ghq](http://motemen.hatenablog.com/entry/2014/06/01/introducing-ghq)もまだ入れたばかりなので  
これから色々試していこうと思います。
