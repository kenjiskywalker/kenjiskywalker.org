---
layout: post
title: "EC2でEphemeral DiskをRAID0で構築した状態でブートする"
published: true
date: "2013-03-04T21:26:00+09:00"
comments: true


---


{% gist 5081937 %}

こんなスクリプトを置いておいて


`/etc/rc.local`

```
sh ec2-raid0.sh
```

こんな感じで*rc.local*に一行書いておけば  
エフェメラルディスク2つをRAID0としてマウントする。  
なんで**md127**なのかは、AWSさんに聞いてほしい。  
**md0**でつくっても必ず、再起動後に**md127**として起動してくる。  
  
きっと神の意思なんだと思う。
