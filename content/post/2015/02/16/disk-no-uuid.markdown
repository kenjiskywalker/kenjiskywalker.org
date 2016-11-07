---
layout: post
title: "/etc/fstabにディスクのUUIDを指定する時にUUIDを調べるコマンド"
published: true
date: "2015-02-16T12:14:00+09:00"
comments: true


---

[19.4.2. blkid コマンドの使用](https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/s2-sysinfo-filesystems-blkid.html)  
  
`blkid`知らなくてずっと`/dev/sdb1`とか指定してた。  
これからはUUID。時代はUUID。

> root権限じゃないと足したディスクが表示されないので気をつけよう;)
