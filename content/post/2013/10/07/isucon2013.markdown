---
layout: post
title: "#isucon 2013 予選1日目に参加しました"
published: true
date: "2013-10-07T09:55:00+09:00"
comments: true


---

[isucon 2013](http://isucon.net/)の1日目に参加しました。  
@fujiwaraさん、@acidlemonさんありがとうございました。  
本戦の問題作成頑張ってくださいね(・ω<)

細かいことは[isucon3 の予選に参加しました #isucon - @soh335 memo](http://soh335.hatenablog.com/entry/2013/10/06/230741)に書いてあります。  
大切なことは[#isucon の予選に参加してきた。 - パルカワ2](http://hisaichi5518.hatenablog.jp/entry/2013/10/07/094347)に書いてあります。  
  
補足としては、ひさいち君は335さんがあれ〜〜〜〜〜？？？なんで〜〜〜〜？？？  
って言い出したらコード見てこれがこうじゃない？？？って言って、  
あ〜〜〜〜〜〜〜〜〜！！！っていう  
デバッグ職人の役割とアプリケーションの細かい修正とかをやってもらってました。  
漫画読んでたのは残り時間2時間残して、5位以内当確間違いないでしょ〜みたいな  
奢りの象徴でした。 
  
残り2時間ぐらいやることなくなったのは、  
workload数を昔のISUCONのレギュレーションと勘違いして  
時間内の最高スコアが実スコアなのに、最後に運営側で回したスコアがそれだろ。  
って335さんと勘違いしてworkload 1しばりやってたからでした。  
これはひさいちが遅刻してこなければ免れたかもしれません。  
  
開始からいきなり忙しいぶってたり、攻殻機動隊のサントラをかけろ！！！  
gitの設定より先にそれやれ、gitはオレがやるから！！！な！！  
テンションあげてこ！！！？？とかやらずに  
開始と同時に、良い茶葉が入りましたので、  
ハーブティーでも飲みませんか？ぐらいの心の余裕が必要でした。  
  
それと、ベンチマーク走らせる度に   
「カムカムカムカム〜〜〜〜〜〜〜〜〜！！！！」「ノオ〜〜〜〜〜〜〜〜〜！！！！」  
「ワイワイワイワイワイエラー！！！」  
「きっとベンチマーク遅くなると思うけどやらせてくれッッ！！！！」  
「ヒュ〜〜〜〜〜〜！！！キマったぜ！！！」みたいに  
やたらテンションが高かったのも反省点でした。  
  
自分がやったことは  
1- nginx化はボトルネックわかってからやろう！って言ってたのに  
nginx化してもらわないとわからないみたいな  
当たり屋みたなこと言われて渋々ボトルネック探す前にnginx化し、  
ログフォーマットはLTSVを利用し、必要最低限のログだけ出すようにし、  
閲覧性を向上させていました。  
  
2- MySQLは、結局見ませんでしたが  
取り敢えずクエリを全部吐くようにしてログに出しておきました。  
  
3- ボトルネック探しはdstatとiotopでCPUとI/O周りを確認していました。  
一番効果があったのはDBIx::SunnyがどこのコードがそのSQL吐いてるのか  
クエリに出してくれるので、そこひたすら眺め  
335さんとこうした方が良い、ああした方が良い。って話していました。  
実装は全部335さんに任せていました。  
  
SQLで重い処理はRedisに持って行きました。  
Redis、長期的に運用すること考えない場合こんなに楽なのか〜って震えました。  
  
4- 335さんがRedisの実装書いてる時はチラチラコード読んで、データの中身確認して  

<blockquote class="twitter-tweet"><p>こそ泥みたいなチューニングしてる <a href="https://twitter.com/search?q=%23isucon&amp;src=hash">#isucon</a></p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/statuses/386401079199399936">October 5, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>  
  
こんな感じのことをしていました。  
  
残り2時間ぐらいになってくると、innodb_buffer_pool_size上げるだけ上げたので  
ほとんどのデータがメモリに載り、Disk Readなどほとんどなくなり  
サーバの資源がだいぶ余る感じになってきて、nginxの受け口増やしたりアプリの起動数  
増やしたりしても変わらなくなってきてて、これはベンチマークツールの限界だな(笑)  
などとフラグを立てることに集中していました。
  
<blockquote class="twitter-tweet"><p><a href="https://twitter.com/search?q=%23isucon&amp;src=hash">#isucon</a> 予選中間発表続き &#10;6. 335&#10;7. isuco&#10;8. 代々木の緑色の会社&#10;9. └(&#39;-&#39;└)&#10;10. Noder&#10;&#10;1位のスコアは14926.8点です</p>&mdash; 941 (@941) <a href="https://twitter.com/941/statuses/386386639297069056">October 5, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
  
この時の計測時点で8000とかで3位ぐらいには入れるな。みたな感じだったのですが  
ここからみなさん怒涛のスコアアップがはじまり、五桁台が当たり前になり  
  
エッエッ？？？？って完全にパニックに陥って、5位もあやしくなってきて  
「なにこれ？？？何が起こってるんです？？？」  
「5位以内じゃなきゃ死んだも同然だ！！！」  
「ディスクリードだ！！！ディスクリードさえなくせばええんや！！！」  
「もう温泉に行こう！！！」と完全に冷静さを失い、  
時間から逆算しても抜本的な対策もできなくなり  
  
残り1時間ぐらいはiptablesオフったりtcp_tw_recycle設定したり  
skip_innodb_doublewriteの設定いじったりして、微妙にスコア伸びましたが、  
全然5桁行く感じではなくて、時間ももうなくて  
もうダメだ！！！温泉行こう！！！温泉！！！な！！！みたいな感じになっていました。  
  
結果敵に
<blockquote class="twitter-tweet"><p>こそ泥みたいなチューニングで5位以内確定できるかと思ってたら無理っぽい <a href="https://twitter.com/search?q=%23isucon&amp;src=hash">#isucon</a></p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/statuses/386405476218314752">October 5, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
  
こうなりました。
 
同じ会社という利点を利用して  
  
<blockquote class="twitter-tweet"><p>チーム335、社内IRCでめっちゃつっかかってる <a href="https://twitter.com/search?q=%23isucon&amp;src=hash">#isucon</a></p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/statuses/386422737968705536">October 5, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>  
  
こんな感じでworkloadの文章がわかりづらいとつっかかっていました。  
どうしようもないですね。結果敵にNoderと50ms or die.チームもworkload 1縛りで  
我々より上位にランクインしているので、小物感が増しただけでした。  
  
本戦に出られたら、落ち着いて全体の実装全体確認して  
対応の方向性決めてから手を動かすようにしたいと思います。  
  
とても楽しかったです。  
ありがとうございました。
