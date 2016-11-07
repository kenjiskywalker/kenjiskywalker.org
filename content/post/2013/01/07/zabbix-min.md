---
layout: post
title: "Zabbixで5分間閾値以下だったらアラート"
published: true
date: "2013-01-07T10:53:00+09:00"
comments: true


---

```
({HostName:net.if.out[eth0,bytes].max(#10)}<50K)
```

とかで設定すると、アイテムが30秒間隔の場合  
`30sec * 10 = 300sec`の間の最大値が全て`50Kbps以下`であれば  
トリガーを発動する。みたいな設定ができる。  


```
({HostName:net.if.out[eth0,bytes].max(300)}<50K)
```

こっちの方がシンプルでわかりやすいかもしれない。

  
@fujiwara++  
@qryuu++
