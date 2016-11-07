---
layout: post
title: "Goでvalue domainのアップデートスクリプトかいた"
published: true
date: "2013-10-10T15:28:00+09:00"
comments: true


---
書き方あってるのか微妙なのでGoに明るい方のご指摘をお待ちしております。  
  
{% gist 6914101 %}

Goでpit使えないのかなって@soh335さんに聞いたらtype氏のリポジトリ見ろ  
って言われて見に行ったらあった。@typester++
  
1. `pitDomain`で設定されている`domain`と`password`を取得
2. `records`で現在のIPアドレスに変更したいレコードリストを入れる
3. temple-kun.appspot.comで現在のIPを取得
4. 現在のIPとレコードに設定されているIPが違ったら更新、同じであればスルー
  
という感じです。

