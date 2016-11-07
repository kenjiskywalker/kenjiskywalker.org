---
layout: post
title: "さくらVPSでOctopress"
published: true
date: "2013-01-02T19:34:00+09:00"
comments: true


---

新年あけましておめでとうございます。  
年初めは意識高いのでやろうと思ってたこと実行するのに良い機会ですね。

ということで[Octopress](http://octopress.org/)を入れてみました。

### 手順

#### 1. nginxの設定

`nginx.conf`に下記内容を記述

```
server {
    listen 8080;
    server_name blog.kenjiskywalker.org;
    root /home/blog/;
    index index.html;
    access_log /var/log/nginx/blog/access_log skywalker;
    error_log  /var/log/nginx/blog/error_log  error;
```

`8080`なのは、フロントにvarnishがいるから。  
これで *blog.kenjiskywalker.org* にアクセスが来たら  
`/home/blog/`のディレクトリを見に行くようになる。


#### 2. オフィシャルのドキュメントを読みながらOctopressの設定

[Octopress Setup](http://java.com/en/download/apple_manual.jsp)

とくに躓くところはなし。


[Deploying](http://octopress.org/docs/deploying/)

さくらVPSで運用する予定なので  
[Deploying With Rsync](http://octopress.org/docs/deploying/rsync/)を読みながら作業。問題なし。

`Rakefile`はnginxにて設定したように

```
document_root  = "/home/blog/" 
```

`/home/blog/`を記述。


[Configuring Octopress](http://octopress.org/docs/configuring/)

最低限の設定を行った。
この辺はもうちょっといじくりたい。

 - 右サイドバーにGithubのリポジトリ表示したり
 - Twitterのストリーミング流したり
 - Google Analyticsの設定したりするのもここで行える

カスタマイズページを右上に表示してみたかったので

```
default_asides: [asides/about.html, 
```

と*about.html*の設定を追記して

`/source/_includes/asides/about.html`にファイルを設置。

参考：[Octopressでサイドバーに簡易プロフィールを表示させよう！](http://qiita.com/items/ac729ec076f477f05ac6)

#### 3. Glide Noteさんを参考にvimの設定


[Octopressの記事管理用プラグイン、Octoeditor.vimを作った](http://blog.glidenote.com/blog/2012/04/02/octoeditor.vim/)

神様。このエントリーもOctoeditor.vim使って書かせてもらっています！


#### 4. 記事を書いて確認してみる


```
$ rake generate
で、source/配下の(記事であればsource/_post/)ファイルをよしなにpublicへゴリゴリしながらつくりあげて

$ rake preview
で、localhost:4000で確認

$ rake deploy
問題がなければデプロイでfinish！
```

上記コマンドはすべてOctoeditorで完結しているのですが  
念の為コマンドを打ってみて動きを確認。

deploy先で正常に閲覧できればOKです。

