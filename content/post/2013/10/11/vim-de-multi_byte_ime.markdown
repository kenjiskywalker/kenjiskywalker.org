---
layout: post
title: "Vimで日本語の切り替えで毎回っっっっっっってなる対策"
published: true
date: "2013-10-11T14:24:00+09:00"
comments: true


---

`.gvimrc`に  

```
if has('multi_byte_ime') || has('xim') 
  highlight Cursor guifg=NONE guibg=White
  highlight CursorIM guifg=NONE guibg=DarkRed
endif
```

って書いたら

![http://gifzo.net/hfBHJNAZR0.gif](http://gifzo.net/hfBHJNAZR0.gif)  
  
こんな風に全角の時に赤色になるから  
ノーマルモードで全角で入力しちゃってうわああああ！！！  
っていうことなくなるのでおすすめです。  
  
MacVimだと`multi_byte_ime`使えなくて  
[macvim-kaoriya](https://code.google.com/p/macvim-kaoriya/)だと使えました。  
マコピーに教えてもらいました。ライフチェインジング！
