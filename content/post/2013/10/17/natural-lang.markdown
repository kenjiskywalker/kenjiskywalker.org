---
layout: post
title: "「自然言語処理ことはじめ」を読んだ"
published: true
date: "2013-10-17T22:23:00+09:00"
comments: true


---

<a href="http://www.amazon.co.jp/gp/product/4627828519/ref=as_li_ss_il?ie=UTF8&camp=247&creative=7399&creativeASIN=4627828519&linkCode=as2&tag=13nightcrows-22"><img border="0" src="http://ws-fe.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=4627828519&Format=_SL110_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=13nightcrows-22" ></a><img src="http://ir-jp.amazon-adsystem.com/e/ir?t=13nightcrows-22&l=as2&o=9&a=4627828519" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

- n-gram(隣接する文字を2、3文字で区切って、統計的に出現頻度を求める)
- bigram(隣接する文字を2、3文字で区切って、2つの文字を統計的に出現頻度を求める)
- trigram(隣接する文字を2、3文字で区切って、3つの文字を統計的に出現頻度を求める)

無作為に分けるだけではなく、名詞、接続詞、動詞などで区別したりもする。

> n-gram
> 
> 「私は眠い」
>
> |私は|
> |は眠|
> |眠い|

「わたしははがいたい」=> 「私母が痛い」
「わたしははがいたい」=> 「私は歯が痛い」

- 最長一致法
- トップダウン法
- ボトムアップ法

どのように適切な単語区切りを行うか(アルゴリズム)  
文章の中の単語の前後関係をどうやって上手く使うか(アルゴリズム)  
  
与えられた言葉を正確にコンピュータが理解できれば  
コンピュータのリソースの効率化が行われて、  
人間の生きる速度が上昇するなーって思いました。  
  
最終的に与えられたものだけではなく、その先の  
自分が考えなければならないことや決断しなければならないことを  
コンピュータが補助してくれたら面白そうだなって思いました。

