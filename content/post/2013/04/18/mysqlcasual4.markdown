---
layout: post
title: "#mysqlcasual vol.4 でカジュアルに発表してきました"
published: true
date: "2013-04-18T00:47:00+09:00"
comments: true


keywords: mysqlcasual
---

[MySQL Casual Talks vol.4](http://atnd.org/events/38091) で発表してきました。  

お声がけしていただいた@myfinderさん  
会場提供していただいたOracleさん  
業務中にSQLの勉強してるのを暖かく見守っていていてくれた弊社のみなさま  
@fujiwaraさん  

ありがとうございました。  
  

## 発表内容

<iframe src="//www.slideshare.net/slideshow/embed_code/18994012" width="425" height="355" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/KenjiNaito/mysql-casual-4" title="mysql casual #4" target="_blank">mysql casual #4</a> </strong> from <strong><a href="//www.slideshare.net/KenjiNaito" target="_blank">kenjis skywalker</a></strong> </div>

順番が@saisa6153さんの次という並び順でよかった。  
カジュアルにSQLを勉強するには〜的な話が続けられて最高だった。  
  
今回は初参加の人が半数以上いて、これはもしやいけるのでは！？って思って  
発表はじめる前に、会場でSQL書いたことのない人いますか？  
って聞いて、誰も手を上げなくて、会場で話す意味合いなくなって  
インターネットの向こう側とか、まだ見ぬエンジニアに向けてみたいな発表になった。  
  
## インターネットの向こう側へ話したこと(2週間で何ができたか)

### 本を買った
「初めてのSQL」をサラっと読んだ  
  
### [tweets.zipをSQLに入れてみた](http://blog.kenjiskywalker.org/blog/2013/04/04/tweets_zip_big_data/)

あんまり意味なかった
  
### サンプルデータを作成するスクリプト書いた  

[https://gist.github.com/kenjiskywalker/5397677](https://gist.github.com/kenjiskywalker/5397677)  
こんなんPerlじゃねー！って思われる方は是非リファクタリングしてください。  
引越しする際に、色んな参考値があって、それをSQLに入れたら面白いんじゃないかなって思って
サクっと書いたものです。取り敢えず1万件のサンプルデータ入ります。  
適当に数字いじればデータ量増えるのでインデックスのテストとかに使える。

### 5.1だけど日本語訳のリファレンス・マニュアルのPDFを発見した  

[MySQL Documentation: MySQL Reference Manuals](http://dev.mysql.com/doc/)  
リファレンス・マニュアル、PDF空いてる時間に読みながらSQLためした  
「初めてのSQL」、4.11なのでSQLについてはリファレンス・マニュアルを参考の基準にした  
  
### オレオレクエリリファレンスまとめた(随時更新していく)  

[https://github.com/kenjiskywalker/memo/blob/master/MySQL/SQL.md](https://github.com/kenjiskywalker/memo/blob/master/MySQL/SQL.md)
  
そんな感じで未経験からでも2週間あればそこそこできるって話を  
インターネットの向こう側にしました。

## みなさんのおすすめの本

- <a href="http://www.amazon.co.jp/gp/product/4774150266/ref=as_li_qf_sp_asin_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=4774150266&linkCode=as2&tag=13nightcrows-22">プロになるための データベース技術入門　～MySQLforWindows困ったときに役立つ開発・運用ガイド</a><img src="http://www.assoc-amazon.jp/e/ir?t=13nightcrows-22&l=as2&o=9&a=4774150266" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />  
- <a href="http://www.amazon.co.jp/gp/product/4774130850/ref=as_li_qf_sp_asin_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=4774130850&linkCode=as2&tag=13nightcrows-22">改訂新版 反復学習ソフト付き SQL書き方ドリル (WEB+DB PRESS plusシリーズ)</a><img src="http://www.assoc-amazon.jp/e/ir?t=13nightcrows-22&l=as2&o=9&a=4774130850" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />  
- <a href="http://www.amazon.co.jp/gp/product/4798115169/ref=as_li_qf_sp_asin_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=4798115169&linkCode=as2&tag=13nightcrows-22">達人に学ぶ SQL徹底指南書 (CodeZine BOOKS)</a><img src="http://www.assoc-amazon.jp/e/ir?t=13nightcrows-22&l=as2&o=9&a=4798115169" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />  
- <a href="http://www.amazon.co.jp/gp/product/1449314287/ref=as_li_qf_sp_asin_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=1449314287&linkCode=as2&tag=13nightcrows-22">High Performance MySQL: Optimization, Backups, and Replication</a><img src="http://www.assoc-amazon.jp/e/ir?t=13nightcrows-22&l=as2&o=9&a=1449314287" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />  

## みなさんのSQL勉強方法

知りたい。実務で必要になってってパターンがほとんどなんだろうけど  

## 感想

ダダスベリして明日会社休むようなことにならなくてよかった。  
  
@mikedaっていう人にもにかじで、@kazeburoさんとか@myfinderさんとかが  
やったって言ってもちょっとレベル違うなって思うけど、オレがやったって言うと  
あ、あいつでもできるんならオレでもできるわ。みたいになる。  
って話聞いてすごい良い話だなって思って、尖った技術力かっこいいけど、  
それ以前にもうちょっと入門向けの技術力ってのもあってもいいなって思っていて  
今回まさにそういう発表ができてよかった。  
  
貴重な体験をさせて頂いて大変ありがたかったです。  

## おまけ
  
<blockquote class="twitter-tweet"><p>@<a href="https://twitter.com/kenjiskywalker">kenjiskywalker</a> 会場の人たちが帰り支度し始めた時に物凄い速さで締切ドアをこじ開けながら会場を出ていったけんじさんの姿を僕は見逃しませんでした。</p>&mdash; id:shim0mura (@shim0mura) <a href="https://twitter.com/shim0mura/status/324519587951566849">April 17, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
  
この人なんだかんだで最前列に陣取ってて面白かった  
