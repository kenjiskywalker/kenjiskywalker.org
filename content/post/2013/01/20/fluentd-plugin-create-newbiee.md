---
layout: post
title: "fluentdのプラグインを書く練習をする為にsecureログをparseしてZabbixで値が取得できるようにしてみた(作成編)"
published: true
date: "2013-01-20T17:03:00+09:00"
comments: true


---

[https://github.com/kenjiskywalker/fluent-plugin-securelog-parser](https://github.com/kenjiskywalker/fluent-plugin-securelog-parser)

<pre>
   ,j;;;;;j,. ---一､ ｀   ―--‐､_ l;;;;;;  
  ｛;;;;;;ゝ T辷iﾌ i      f'辷jァ   !i;;;;;    全く触ったことがなくてもpluginを書いたらfluentdがわかる  
   ヾ;;;ﾊ        ﾉ              .::!lﾘ;;rﾞ  
     `Z;i      〈.,_..,.            ﾉ;;;;;;;;>    そんなふうに考えていた時期が  
     ,;ぇﾊ、  ､_,.ｰ-､_',.      ,ｆﾞ: Y;;f.      俺にもありました  
     ~''戈ヽ    ｀二´      r'´:::.  `!  
</pre>

最初Postfixのmaillogつくってやろうかなんて  
思っていたりした時期もオレにはありました。

しかしログが多様すぎるので、ちょっとこれ最初にやるには敷居高いなー  
と思い、だからってあんまり理にかなわないことをしても意味ないな  
ということで、`/var/log/secure`のログを指定した文字列の出現具合を  
Zabbixで取得したら面白いかなというアイデアが思いついたので  
取り敢えずコードは汚いにしろ、動くまで書いてみたメモです。  

[設定編はこちら](http://blog.kenjiskywalker.org/blog/2013/01/20/fluentd-plugin-create-newbie/)


# 作成編

事前にtestが通るまでのものは  
[超初級！Fluentdのプラグインを書きたくなった時の下地づくり](http://blog.kenjiskywalker.org:8080/blog/2013/01/05/fluent-pluing/)にて作成しています。  

本来はもっとスマートな作り方があるのでしょうが、  
私は基本的にこの流れで行いました。

 - 内容を更新する度にrake testでtestが通ることを確認する
 - 変数の状況を`p hoge`で毎回確認する

この2つの繰り返しでした。  

### 参考

 - [@repeatedlyさんのプラグイン作成の記事 / Software Design 2012年6月号](http://gihyo.jp/magazine/SD/archive/2012/201206)
 - [Writing plugins / fluentd](http://docs.fluentd.org/articles/plugin-development)
 - [検証中のtd-agent（fluentd）の設定とか負荷とか / IT 東京 楽しいと思うこと](http://d.hatena.ne.jp/mikeda/20120704/1341363870)
 - [fluentdのプラグインは簡単に作成できる / ぽにくすじゃないだいありー](http://d.hatena.ne.jp/erukiti/20120205/1328452455)
 - [Fluentd plugins](http://fluentd.org/plugin/)

基本はりぴーさんの記事を参考に、取り敢えず片っ端からpluginのソースを読んでいけば  
センスの良い人ならその場で書けそうなものですが、いかんせん素人なので  
試行錯誤しながら書いて行きました。  

取り敢えず動いたレベルですが、何かの参考になればと思います。  

[https://github.com/kenjiskywalker/fluent-plugin-securelog-parser](https://github.com/kenjiskywalker/fluent-plugin-securelog-parser)

また、ソースを見て頂く通り、何かのログのパーサを書こうと思えば  
*regexp*と*time_format*さえどうにかなれば、  
プラグインの種類にもよりますが、いくらでも加工することが可能です。  
fluentd、素晴らしいですね。

> *tag*、*es*、*chain*の中身などを*.each*などで分解していき  
> testを実行した際に(*test_emit*)で  
> プラグイン内部の確認したい変数の中身を`p hoge`する。

この繰り返していってという感じです。  
ソースファイルのコメントアウト部は  
コードを記述していた際には常に表示させていたものです。

サーバ上での動作のテストは  
`out_securelog_parser.rb`ファイルを`/etc/td-agent/plugin/`へ配置することで  
プラグインとして認識してくれます。素晴らしいですね。
  
ログが出るのを待つのは大変なので  
```
echo '{"message":"Jan 17 02:47:59 hostname sshd[10654]: test"}' | /usr/lib64/fluent/ruby/bin/fluent-cat secure
```
と、`fluent-cat`コマンドを実行して、確認したい*tag*を指定することで  
プラグインの確認を行うことが可能です。

ちゃんとテストを書いていないあｗ、中身はまだまだ改善の余地があるわでアレですが  
Rubyもよくに書けず、fluentdを運用した経験もあまりない人間が  
稚拙ではありますが、最低限動作するところまでは書くことができました。

ハイユーザーから、エントリーユーザまで利用でき、  
かつ、簡単なログパーサから、各種メトリクス生成などのプラグインが  
容易に作成することができるfluentdは、やはりこれからのオペレーションの  
情報取得ツールとして、無くてはならないものになっていくんだろうな。  
という印象を受けました。

awesome fluentd!

続きは[設定編](http://blog.kenjiskywalker.org/blog/2013/01/20/fluentd-plugin-create-newbie/)で

