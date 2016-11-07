---
layout: post
title: "Zabbix::Senriganをつくりました"
published: true
date: "2013-10-17T23:14:00+09:00"
comments: true


---

千里眼、どんなメリットがあるのか見えないとのことなので  
もう少し詳細に書きます。

## demo：[http://un.kenjiskywalker.org/senrigan/](http://un.kenjiskywalker.org/senrigan/)  

動きます。

## screen shot

![https://dl.dropboxusercontent.com/u/5390179/senrigan2.png](https://dl.dropboxusercontent.com/u/5390179/senrigan2.png)
![https://dl.dropboxusercontent.com/u/5390179/senrigan3.png](https://dl.dropboxusercontent.com/u/5390179/senrigan3.png)
![https://dl.dropboxusercontent.com/u/5390179/senrigan6.png](https://dl.dropboxusercontent.com/u/5390179/senrigan6.png)

こんな感じのZabbixのグラフを取得してきて一覧で表示してくれるものです。

## 何のために？

グラフの一覧を表示するためなら、Zabbixのスクリーンを利用するのが良いですね。  
しかし、スクリーンが案件毎やグループ毎に分かれていた場合、  
横断的にCPU使用率を確認しようとすると、全てのスクリーンへ  
アクセスしなければならない。世に云うZabbix画面右上プルダウン地獄です。  

![https://dl.dropboxusercontent.com/u/5390179/senrigan5.png](https://dl.dropboxusercontent.com/u/5390179/senrigan5.png)
  
案件担当者であれば、特定のスクリーンだけ見ておけば問題ないかもしれませんが  
システム全域に目を通さなければならない運用者にとって  
このZabbixプルダウン地獄はそこそこストレスになります。  
私はなりました。  
そして、横断的に確認するコストが高くなると  
目視で定期的に確認する間隔が減り、変化に気付きにくくなります。  
私はなりました。
  
そこで、解決策として

- 動的ではなくて良い
- 決まった期日の間のグラフ一覧がほしい
- なるべくプルダウンしなくて良いようにする  
- 全てのグラフをシンプルに表示する
  
この3点を叶えるオレ得ツール、Zabbix::Senriganを作成しました。

### [https://github.com/kenjiskywalker/p5-Zabbix-Senrigan/](https://github.com/kenjiskywalker/p5-Zabbix-Senrigan/)

## demo：[http://un.kenjiskywalker.org/senrigan/](http://un.kenjiskywalker.org/senrigan/)  

改めてdemo。

## screen shot

![https://dl.dropboxusercontent.com/u/5390179/senrigan2.png](https://dl.dropboxusercontent.com/u/5390179/senrigan2.png)
![https://dl.dropboxusercontent.com/u/5390179/senrigan3.png](https://dl.dropboxusercontent.com/u/5390179/senrigan3.png)
![https://dl.dropboxusercontent.com/u/5390179/senrigan6.png](https://dl.dropboxusercontent.com/u/5390179/senrigan6.png)
  
自宅環境だとグラフ少ないのでメリットないのですが、プロダクト環境で  
CPUのグラフが400個ぐらいあるとだいぶ便利です。


### [https://github.com/kenjiskywalker/Mzcs](https://github.com/kenjiskywalker/Mzcs)
  
これのバージョンアップ版みたいな感じです。  

## 導入方法

> Zabbixを利用していることが前提条件です
  
`carton install`、`carton exec perl script.pl`で動きます。  
egの中に`script.pl`があるので  
  

```
#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Zabbix::Senrigan;

my $snrgn = Zabbix::Senrigan->new(
    username    => "zabbix_user",                          ### Zabbixのユーザ名
    password    => "zabbix_password",                      ### Zabbixのパスワード
    zabbix_url  => "http://localhost/zabbix",              ### ZabbixのURL
    data_source => "DBI:mysql:zabbix",                     ### ZabbixのDB名
    db_username => "zabbix",                               ### ZabbixのDBのユーザ名
    db_password => "zabbinx",                              ### ZabbixのDBのパスワード
    graph_name_list => ["CPU utilization", "Swap usage"],  ### 見たいグラフ
    view_graph_num => 30,                                  ### 1ページに表示するグラフ数
    period      => 86400,                                  ### グラフの間隔
    time        => "120000",                               ### 12:00:00 からのデータ
    create_dir  => "../test_dir",
);

$snrgn->run;
```

みたいな感じでrunさせれば`create_dir`に  
指定したディレクトリにグラフ一覧ができます。  
MechanizeとDBIの両方使わないといけないのが  
なんともって感じです。  
  
上の設定の場合

- `zabbix_url`へ`username`と`password`を利用してMechanizeでログイン
- `data_source`へ`db_username`と`db_password`を利用してDBにログイン
- `period`の期間のグラフを作成する。時刻は`time`からのものを利用

つまり画像をローカルにダウンロードしてきて  
その一覧を見るためのHTMLを作成する。というものです。  
  
基本的に2週間ぐらいのメトリクスが見れれば  
ある程度の傾向は見れるかなと。基本的に増減については  
Zabbixがアラートを発報してくれますが、漏れもあるかと思うので  
定期的に職人が目視で確認するのに利用できます。
  
enjoy Zabbix life!
