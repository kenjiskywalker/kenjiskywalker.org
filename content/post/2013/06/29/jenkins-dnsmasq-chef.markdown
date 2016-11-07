---
layout: post
title: "さくらVPSでJenkinsたちあげたくてVPN繋いでdnsmasqで名前解決できるようにした"
published: true
date: "2013-06-29T20:49:00+09:00"
comments: true


---

Jenkins氏、存在は知ってるけど自分で使ったことなかったので  
取り敢えずインストールしてみた。  
  
さくらVPSだとグローバル経由でアクセスすることになって  
誰でも見れちゃうので悲しい感じになる。  
ということでVPNを貼って内部で接続しに行く。


```
+--------+             +-----+
| sakura | --- vpn --- | MBA |
+--------+             +-----+
[10.9.0.1]             [10.9.0.6]

```

VPNの貼り方とはか[ここ](http://d.hatena.ne.jp/kenjiskywalker/20120702/1341226191)を見て貰いたい。  
  

### Jenkins氏

- /etc/sysconfig/jenkins

```
JENKINS_ARGS="--httpPort=${JENKINS_PORT} --ajp13Port=${JENKINS_AJP_PORT} --httpListenAddress=127.0.0.1"
```

として、自分自身のアクセスだけ許可

### nginx氏

- /etc/nginx/conf.d/hoge.conf

```
server {
    listen 80;
    server_name jenkins.kenjiskywalker.org;
    root /home/skywalker/www;

    location /{
        proxy_pass http://localhost:8080;
        allow 10.9.0.0/16;
        deny all;
    }
}
```

で、`jenkins.kenjiskywalker.org`でアクセスを受け付けるようにする。

MBAにdnsmasqを入れて`/usr/local/etc/`にPATH通しておいて

- /usr/local/etc/dnsmasq.conf
```
address=/jenkins.kenjiskywalker.org/10.9.0.1
```
```
$ sudo /usr/local/sbin/dnsmasq
```

とかで起動させて、コントロールパネルの方で、DNSサーバを  
`127.0.0.1`を最初に見に行かせるようにすれば名前解決できるようになる。  
`homebrew.mxcl.dnsmasq.plist`があるので、それ使って継続的にdnsmasq上げると良さそう。
  
さて、さくらのVPS、メモリ1Gしかなくて心配だけど試してみよう。
