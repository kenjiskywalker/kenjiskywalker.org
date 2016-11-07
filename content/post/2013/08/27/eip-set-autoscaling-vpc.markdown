---
layout: post
title: "AWSのAutoScalingで立ち上がってきたVPC内のEC2インスタンスに強制的にEIPを付与する"
published: true
date: "2013-08-27T23:50:00+09:00"
comments: true


---

## 前提条件  

- グローバルにアクセスできる管理サーバが一台ある  
- 対象のVPCにアサイン可能なEIPがある(AssociateされていないEIPがある)

という前提条件が成立していれば、管理サーバで  

{% gist 6354555 %}  

このようなスクリプトを

```
*/1 * * * * root /root/set_eip.sh 2> /dev/null
```

と噛ましておけば、EIPが付与されていないインスタンスを発見し次第  
強制的にEIPをアサインすることができます。  
  
`2> /dev/null`とかやってるとイスが飛んできそうなものですが  
1分毎に実行していると、内部DNS結構頻繁に取りこぼしたりするので闇に葬りました。  
成功した場合は`ADDRESS	 i-XXXXXXXX	eipalloc-XXXXXXXX	eipassoc-XXXXXXXX`  
という内容のメールがとんできて、お、アサインされたのか。と気付けます。  
  
CloudWatchのAutoScaling発動トリガーで何かしらの通知設定をされているかと思うので  
まずその通知でAutoScalingの発火を確認し、  
上記EIPアサイン通知でインスタンスの起動を確認。のようなこともできます。  
  
[【AWS発表】 VPC内のパブリックIPアドレスの取い扱いがより柔軟に](http://aws.typepad.com/aws_japan/2013/08/additional-ip-address-flexibility-in-the-virtual-private-cloud.html)  
  
ということを頑張らなくてもそのうち上記Public IPがAutoScalingにも対応すると思う。  
  
ところで`EIP`と`Public IP`の違いって何なんですかね？
