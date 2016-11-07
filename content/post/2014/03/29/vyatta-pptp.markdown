---
layout: post
title: "VyattaでVPN(PPTP)の設定"
published: true
date: "2014-03-29T18:01:00+09:00"
comments: true


---

iOS用にPPTPで接続できるようにしたら便利だったので  
VyattaでVPN(PPTP)設定したメモ。

参考：[Vyatta で構築する簡単 VPN サーバ](http://jedipunkz.github.io/blog/2012/06/13/vyatta-vpn/)

```
$ configure
# set vpn pptp remote-access authentication local-users username ${USER} password ${PASSWORD}
# set vpn pptp remote-access authentication mode local
# set vpn pptp remote-access client-ip-pool start ${IP_START}
# set vpn pptp remote-access client-ip-pool stop ${IP_END}
# commit
# save
```

以上です。市販のルータ使っていたらGUIで設定して  
反映する為にはルータの再起動が必要です。1分待って下さいとか  
なかなか渋いことになりますが、VyattaはCLIで設定すれば  
再起動など必要なく即反映されます。最高のユーザ体験です。  
  
もう市販のルータ使うことはないと思います。　
