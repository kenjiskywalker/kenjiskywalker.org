---
layout: post
title: "「なるほどUnixプロセス ― Rubyで学ぶUnixの基礎」を読んだ"
published: true
date: "2013-10-21T14:43:00+09:00"
comments: true


---

サラサラ〜っと読んで放置していた  
[「なるほどUnixプロセス ― Rubyで学ぶUnixの基礎」](http://tatsu-zine.com/books/naruhounix)を読みました。  
週末手を動かしながら読めたのでよかった。  
`fork(2)`周りの所作と`pipe(2)`、`socket(2)`も簡単に試せてよかった。  
daemon化するために孫プロセスで動かすとか古典的な感じだった。  
  
本書は簡単に書きながら試せる。っていうのが最高に最高だと思います。
  
何で放置していたものを手に取ったかは  
[なるほどUnixプロセス読んだ - デーモン化のためのdouble fork - はこべブログ ♨](http://hakobe932.hatenablog.com/entry/2013/04/28/210815)  
このはこべさんのエントリー読んだのがきっかけでした。  
  
[親プロセスは2度死ぬ - デーモン化に使うダブルforkの謎 - 睡眠不足？！](http://d.hatena.ne.jp/sleepy_yoshi/20100228/p1)  
そしてこちらのエントリーへ行って、[詳解UNIXプログラミング](http://www.amazon.co.jp/dp/4894713195)に行きあたり  
いい加減読むか〜って思って色々見ていたら  
[『詳細UNIXプログラミング』の原書『Advanced Programming in the UNIX Environment』(通称APUE)の3rd Editionが出てました - (ひ)メモ](http://d.hatena.ne.jp/hirose31/20130731/1375248744)  
というひろせさんのブログにぶち当たり  
  
APUEか〜、いい加減読まないとダメだな〜ってなって買いました。  
  
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>  
  
洋書なので多分今年中に読み終わらないと思います。  
購入の決め手はサンプルコードが毎回記載されてて  
サンプルコード毎に実行できそうだったので、コード読めばなんとなく  
わかるかなって判断しました。  

<blockquote class="twitter-tweet"><p>なるほどUNIXなんとか読む =&gt; hakobeさんのブログでdouble forkについて理解する =&gt; 詳細UNIXプログラミングが気にある =&gt; (ひ)に辿り着く</p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/statuses/391948022038282240">October 20, 2013</a></blockquote>

次から次に壁が現れるぜコンチクショ〜
