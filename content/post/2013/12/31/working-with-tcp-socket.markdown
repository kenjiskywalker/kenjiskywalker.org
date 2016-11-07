---
layout: post
title: "「Working With TCP Sockets」を読んだ"
published: true
date: "2013-12-31T06:34:00+09:00"
comments: true


---

<div class="booklog_html"><table><tr><td class="booklog_html_image"><a href="http://www.amazon.co.jp/Working-With-Sockets-Jesse-Storimer-ebook/dp/B00BPYT6PK%3FSubscriptionId%3D0AVSM5SVKRWTFMG7ZR82%26tag%3D13nightcrows-22%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3DB00BPYT6PK" target="_blank"><img src="http://ecx.images-amazon.com/images/I/51uNC60Jm4L._SL160_.jpg" width="160" height="124" style="border:0;border-radius:0;" /></a></td><td class="booklog_html_info" style="padding-left:20px;"><div class="booklog_html_title" style="margin-bottom:10px;font-size:14px;font-weight:bold;"><a href="http://www.amazon.co.jp/Working-With-Sockets-Jesse-Storimer-ebook/dp/B00BPYT6PK%3FSubscriptionId%3D0AVSM5SVKRWTFMG7ZR82%26tag%3D13nightcrows-22%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3DB00BPYT6PK" target="_blank">Working With TCP Sockets</a></div><div style="margin-bottom:10px;"><div class="booklog_html_author" style="margin-bottom:15px;font-size:12px;;line-height:1.2em">著者 : <a href="http://booklog.jp/author/Jesse+Storimer" target="_blank">Jesse Storimer</a></div><div class="booklog_html_manufacturer" style="margin-bottom:5px;font-size:12px;;line-height:1.2em"></div><div class="booklog_html_release" style="font-size:12px;;line-height:1.2em">発売日 : 2012-10-24</div></div><div class="booklog_html_link_amazon"><a href="http://booklog.jp/item/1/B00BPYT6PK" style="font-size:12px;" target="_blank">ブクログでレビューを見る»</a></div></td></tr></table></div>  
  
大切なことはここにすべて載っています。  
[Working With TCP Socketsを読んだ - $shibayu36->blog;](http://shibayu36.hatenablog.com/entry/2013/10/29/205718) 

これも読みました。  
[電子書籍「irbから学ぶRubyの並列処理 ~ forkからWebSocketまで」EPUB版をGumroadから出版しました！](http://melborne.github.io/2012/12/13/ruby-parallel-on-ebook/)  
  
100円で完結にまとめられていて最高でした。

コード参考  
[EventMachine: scalable non-blocking i/o in ruby](http://ja.scribd.com/doc/28253878/EventMachine-scalable-non-blocking-i-o-in-ruby)

send(2)のマニュアルページ  
[http://linuxjm.sourceforge.jp/html/LDP_man-pages/man2/sendmsg.2.html](http://linuxjm.sourceforge.jp/html/LDP_man-pages/man2/sendmsg.2.html)

### ソケットの流れ

> 1. socket(2) ソケットの生成
> 2. bind(2)   ソケットとポートの結合
> 3. listen(2)   接続キューの作成(サーバ)
> 4. accept(2)   接続受け入れ(サーバ)
> 5. send(2), write(2) パケット送信
> 6. recv(2), read(2) パケット受信
> 7. close   ソケットの終了
  
基礎について改めて勉強になった。accept_loop便利だった。  
IO.selectの部分はepollとかkqueueでやってるんじゃないのかな。  
EventMachineどうなってるんだろう。って思って調べたら

- ext/project.h

<pre>
#ifdef HAVE_EPOLL
#include <sys/epoll.h>
#endif

#ifdef HAVE_KQUEUE
#include <sys/event.h>
#include <sys/queue.h>
#endif

#ifdef HAVE_INOTIFY
#include <sys/inotify.h>
#endif
</pre>

ってやってた。
  
この人の本はわかりやすくていい。

