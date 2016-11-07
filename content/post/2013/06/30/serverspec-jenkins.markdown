---
layout: post
title: "serverspecをJenkins氏で回す場合について"
published: true
date: "2013-06-30T02:47:00+09:00"
comments: true


keywords: serverspec jenkins
---

今流行りの[serverspec](http://serverspec.org/)、みなさんどうやって活用しているのでしょうか。  
インフラもCIだ！みたいな話最近よく聞くので、CIといえばJenkins！  
的な感じで試してみました。
  
ほんのさわり程度やってみたところで、工夫が必要だと感じたのは  
Jenkinsをどうやって回すか。という根本的なところです。   
  
Jenkinsのアカウントをsudo許可するのか、別アカウントを用意するのか、  
もうなんだったらルート権限付与してしまうのか。色々方法はあるかと思います。  
  
ほんのさわり程度ですが、良さそうだなと感じたのは  
[Publish Over SSH Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Publish+Over+SSH+Plugin)このプラグインを利用して  
NOPASS sudo権限のあるアカウントを作成し、秘密鍵を設定して  
Jenkins用のアカウントとしてSSHログインさせてテストを回すのが良いかなと。  
  
![https://dl.dropboxusercontent.com/u/5390179/ea0d7aa2ae77caf8623cead6fdfa522e.png](https://dl.dropboxusercontent.com/u/5390179/ea0d7aa2ae77caf8623cead6fdfa522e.png)  
  
ほんのさわり程度なので、もっと良い方法ありそうですね。
  
あと[IRC Plugin](https://wiki.jenkins-ci.org/display/JENKINS/IRC+Plugin)これ、動かなくて  
どっちかっていうとIRCでserverspecのテストの結果チラチラ見たいんんだよぉ〜  
むしろその為にやってたんだよぉ〜ってなって、3時間ぐらいああだこうだやってて  
なんで〜！！！ってなってたけど  

- [Jenkins casual notification using Remote access API / 烏賊様](http://ikasama.hateblo.jp/entry/2011/12/21/033421)
  
ikasam_aさんのおかげでできるようになった！！！ありがたい！！！  
もうちょっと触っていったら色々やりたい。  
