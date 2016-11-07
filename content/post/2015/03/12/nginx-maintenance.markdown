---
layout: post
title: "nginxでメンテナンスページ用意する技"
published: true
date: "2015-03-12T12:22:00+09:00"
comments: true


---

## LT;DR

かっぱ先輩！

## かっぱ先輩のブログを読んで

- [深夜メンテナンスに役立ちそうな nginx 小ネタ - ようへいの日々精進 XP ](http://inokara.hateblo.jp/entry/2014/02/22/134221)

同じようなことを最近やっていたのでメモ。


## 追記(03/12) 14:00

- リダイレクトやめましょうとのこと
- 503でお返事しましょうとのこと

<blockquote class="twitter-tweet" lang="en"><p>メンテナンス時にメンテページにリダイレクトするのやめましょう</p>&mdash; そらは (@sora_h) <a href="https://twitter.com/sora_h/status/575875916506640384">March 12, 2015</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> <a href="https://twitter.com/sora_h">@sora_h</a> 元ネタの自分の記事は503返してるよ <a href="http://t.co/lONIVrv7OF">http://t.co/lONIVrv7OF</a></p>&mdash; fujiwara (@fujiwara) <a href="https://twitter.com/fujiwara/status/575877278355214336">March 12, 2015</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> <a href="https://twitter.com/sora_h">@sora_h</a> 静的ページ更新して差し替えぐらいでいいんじゃないですかねえ</p>&mdash; fujiwara (@fujiwara) <a href="https://twitter.com/fujiwara/status/575880371214020609">March 12, 2015</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> <a href="https://twitter.com/fujiwara">@fujiwara</a> あ、そういう話か。ちょっと勘違いしてた。静的ページ更新の差し替えしかないのでは。</p>&mdash; そらは (@sora_h) <a href="https://twitter.com/sora_h/status/575880494400729088">March 12, 2015</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

ノーSEO(disallow: /)だったので完全に無視してた

### nginxに設定しているメンテナンスモードの条件

- `/var/nginx/html/maintenance/maintenance.html`ファイルがあればメンテナンスモードとして`maintenance.html`を表示するように

- `/healthcheck`のリクエストはメンテナンスモードでも通す

- 管理IPアドレスからはメンテナンスモードでも通す

という3点を設定しています。

- nginx.conf

```
upstream example_pool {
    server 127.0.0.1:3000;
}

geo $allow_ip_flag {
    default 0;
    192.0.2.0/24 1;    #TEST-NET-1
    198.51.100.0/24 1; #TEST-NET-2
}

server {
    listen       80;
    server_name  example.com;

    access_log  /var/log/nginx/example_com_access.log  ltsv;
    error_log  /var/log/nginx/example_com_error.log warn;

    root /var/nginx/html/example;

    location /robots.txt {
            alias /var/nginx/html/robots.txt;
    }

    location / {

        ### メンテナンスの設定 ここから ###############################
        if ( -e /var/nginx/html/maintenance/maintenance.html ) {
            set $maintenance true;
        }

        # health checkのリクエストはログに出さずに
        # メンテナンスページを通過する
        if ( $request_uri ~ /healthcheck ) {
            set $maintenance false;
            access_log off;
        }

        # 許可IPアドレスならメンテナンスページを通過する
        if ( $allow_ip_flag ) {
            set $maintenance false;
        }

        # それ以外は/maintenance.htmlに飛ばす
        if ( $maintenance = true ) {
            rewrite ^ /maintenance.html redirect;
        }

        location /maintenance.html {
            alias /var/nginx/html/maintenance/maintenance.html;
            expires 0;
        }
        ### メンテナンスの設定 ここまで ###############################

        proxy_pass http://example_pool;

        proxy_set_header Host              $http_host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;

        client_max_body_size 710M;
        proxy_connect_timeout      3000;
        proxy_send_timeout         3000;
        proxy_read_timeout         3000;
        break;
    }
}
```

nginxは複数の条件の場合bit立てて判断するの知らなかった。

- [IfIsEvil](http://wiki.nginx.org/IfIsEvil)

こういうのはエレガントにngx_mrubyでやった方が運用楽そう。
