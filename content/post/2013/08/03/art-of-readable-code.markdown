---
layout: post
title: "リーダブルコード読んだ"
published: true
date: "2013-08-03T14:18:00+09:00"
comments: true


---

<a href="http://www.amazon.co.jp/gp/product/4873115655/ref=as_li_qf_sp_asin_il?ie=UTF8&camp=247&creative=1211&creativeASIN=4873115655&linkCode=as2&tag=13nightcrows-22"><img border="0" src="http://ws-fe.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=4873115655&Format=_SL160_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=13nightcrows-22" ></a><img src="http://ir-jp.amazon-adsystem.com/e/ir?t=13nightcrows-22&l=as2&o=9&a=4873115655" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

本読むより人のコード読んだ方が勉強なるけど  
こういう所作の話全然知らないから面白かった。

### 自分メモ

- ワンラインでシュッっとさせてわかりづらくなるならそれは止めた方が良い
- 汎用的な単語を使うのを止める。直接的で何をしているのかわかりやすい単語を使う  
  hosts,status,get,list,この辺汎用的な名前付けがちなのでわかりやすいようにする
- スコープが小さければx,yとか使っても良いけど目視で追い切れないところで使うと追う手間が発生する
- コメントで補う前にコードや変数名をよしなにできないか考える
- ループロジックは簡潔に、かつそれぞれのメソッドがわかりやすいように


