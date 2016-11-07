---
layout: post
title: "OS Xでfigを利用してDockerのコンテナを操作する"
published: true
date: "2014-10-25T21:38:00+09:00"
comments: true


---

> Docker v1.3  
> fig 1.0.0

## TL;DR

OS XでDockerコンテナを操作するのが手間だったけどfigを使えば解決した.  
OS Xで本番環境と同じような環境をつくりたくてboot2docker + figを利用した  

## 目を通しておいてもらいたい最高のエントリー

[Docker1.3版 boot2docker+fig入門 - Qiita](http://qiita.com/toritori0318/items/190fd2dad2bf3ce38b88)  
[boot2dockerでのVolume問題が解決しそう | SOTA](http://deeeet.com/writing/2014/10/08/boot2docker-guest-additions/)


## 必要なもの

- [boot2docker](http://boot2docker.io/)
- [fig](http://www.fig.sh/)

## fig


OS Xでは、Docker containerにアクセスするまでに  

```
OS X -> boot2docker -> docker container
```  
  
boot2dockerを一旦挟まなければならなかった.  
これをfigを利用することで、透過的に  

```
OS X -> docker container
```  

このようにアクセスしているかのようにラッピングができる

## update 2014/10/27

完全に勘違い！OS Xでも普通に`docker`コマンド使えます.  


```
$ boot2docker up
$ boot2docker ssh
$ docker build .
```

などと操作しなくても[0.7.3](https://github.com/docker/docker/blob/master/CHANGELOG.md#073-2014-01-02)の頃から  
DockerはOS Xに対応していて

```
$ boot2docker up
$ docker build .
```

のようにログインせずともTiny Core Linuxのリモートクライアントとして  
コマンドを発行できた.全然アップデート見てないことがバレた〜  
  
Thanks [@deeeet](http://deeeet.com/writing/2014/10/08/boot2docker-guest-additions/)!!!
  
### figとは

<blockquote class="twitter-tweet" data-conversation="none" lang="en"><p><a href="https://twitter.com/deeeet">@deeeet</a> <a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> fig、foremanとかprocletに近い用途なイメージあります</p>&mdash; ゆううき (@y_uuk1) <a href="https://twitter.com/y_uuk1/status/526631144335233025">October 27, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
  
とのことです.わかりやすい.  

### figを利用しない場合
  
```
$ boot2docker up
$ docker build .
$ docker run -p 3000:3000 8c6d6a1339b6 bundle exec rackup -p 3000
```

のような操作で起動できる.



## figをどのように使うか
  
とあるRailsのアプリケーションがあった時に、そのアプリケーションを  
Docker containerで透過的に操作する為にどのようなことが必要なのかの例
  
```
.
├── Gemfile
├── Gemfile.lock
├── README.rdoc
├── Rakefile
├── app
├── bin
├── build
├── config
├── config.ru
├── db
├── lib
├── log
├── myapp
├── public
├── test
├── tmp
└── vendor
```

このようにRailsアプリケーションのディレクトリに


```
.
├── Dockerfile
├── Gemfile
├── Gemfile.lock
├── README.rdoc
├── Rakefile
├── app
├── bin
├── build
├── config
├── config.ru
├── db
├── fig.yml
├── lib
├── log
├── myapp
├── public
├── test
├── tmp
└── vendor
```

`Dockerfile`と`fig.yml`を置く


- Dockerfile

日本に住む人々は魂をRedHatに引かれてUbuntuを利用しにくいので  
CentOS 6.5でRuby 2.1.3が使えるコンテナを用意した(名前の通りsqliteも入っている)

```
FROM kenjiskywalker/dockerfile-centos-ruby-sqlite:ruby213

WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install

RUN mkdir /myapp
WORKDIR /myapp
ADD . /myapp
```

- fig.yml

```
web:
  build: .
  command: bundle exec rackup -p 3000
  volumes:
    - .:/myapp
  ports:
    - "3000:3000"
```

この状態で

```
$ boot2docker up
$ fig up
```

とコマンドを発行し

```
$ boot2docker ip

The VM's Host only interface IP address is: 192.168.59.103

$
```

で利用しているIPアドレスを確認して

`http://192.168.59.103:3000/`にアクセスすると  
コンテナ上で起動しているアプリケーションにアクセスすることができる.
  
## 手元のデータベース・サーバで何を選択するか

development環境がsqlite3を利用する設定であれば  
データベースのミドルウェアを立ち上げる必要はないので  
1コンテナで完結するのでこの方法が利用できます.

-  config/database.yml

```
development: &default
  adapter: sqlite3
  database: db/development.sqlite3
  pool: 5
  timeout: 5000
```

しかし、裏側にMySQLを利用する場合は

- fig.yml

```
db:
  image: mysql
  environment:
    MYSQL_ROOT_PASSWORD: "pass"
  ports:
    - "3306"

web:
  build: .
  command: bundle exec rackup -p 3000
  volumes:
    - .:/myapp
  ports:
    - "3000:3000"
  links:
    - db
  environment:
    DB_HOST: db
```

- config/database.yml

```
development: &default
  adapter: mysql2
  encoding: utf8
  pool: 5
  database: mysql
  username: root
  password: 'pass'
  host: <%= ENV['DB_HOST'] %>
```

このようにデータベースサーバ用コンテナの設定をRails側に記載しなければならない.  
  
アプリケーションもデータベースもsupervisorなどで動くコンテナを  
作成すれば良いのではないか、という話になるが、  
本番サーバも同じようにsupervisorを利用しているならまだしも  
手元でのテストをするためだけに専用のコンテナを用意するのは  
本質的ではない気がします.
> 今書いていて、supervisorで色々上げるコンテナ用意するのは  
> それはそれでいいかもしれないという気がしてきた  

## まとめ


<blockquote class="twitter-tweet" data-conversation="none" lang="en"><p><a href="https://twitter.com/deeeet">@deeeet</a> <a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> fig、foremanとかprocletに近い用途なイメージあります</p>&mdash; ゆううき (@y_uuk1) <a href="https://twitter.com/y_uuk1/status/526631144335233025">October 27, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

です.

## 参考

- [Docker1.3版 boot2docker+fig入門 - Qiita](http://qiita.com/toritori0318/items/190fd2dad2bf3ce38b88) アルパカさんの最高のまとめ
- [Getting started with Fig and Rails - fig](http://www.fig.sh/rails.html)
- [Fig 1.0: boot2docker compatibility and more | Docker Blog](http://blog.docker.com/2014/10/fig-1-0-boot2docker-compatibility-and-more/)
