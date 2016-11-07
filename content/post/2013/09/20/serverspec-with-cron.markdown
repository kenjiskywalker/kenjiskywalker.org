---
layout: post
title: "本番環境でのserverspecの運用方法"
published: true
date: "2013-09-20T02:18:00+09:00"
comments: true


---


- ミドルウェアの管理はchefを使用している
- サーバへのデプロイはcapistranoを使用している
  
上記2点が当てはまる場合、serverspecの使い方として  

- [Testing #chef Cookbook by #serverspec #devops / さよならインターネット](http://blog.kenjiskywalker.org/blog/2013/07/13/serverspec-chef-cookbook/)
- [serverspecでchefのjsonを読み込む / さよならインターネット](http://blog.kenjiskywalker.org/blog/2013/07/31/serverspec-attribute/)
- [serverspecをJenkins氏で回す場合について / さよならインターネット](http://blog.kenjiskywalker.org/blog/2013/06/30/serverspec-jenkins/)  
  
上記エントリーを参考にして頂ければchef + serverspecである程度の  
インフラストラクチャの構築とテストが行えるかと思います。  
  
また、こちらのエントリーのように、chefのrecipeからserverspecのテスト自体を  
生成してしまうという素晴らしいアイデアもあります。最高ですね。  
  
#### [Chef のレシピから serverspec のテストを自動生成する chef-serverspec-handler という gem を作ってみた](http://tily.hatenablog.com/entry/2013/07/21/150404)  
  
で、結局使えるのはわかったのですが、どのように運用すべきか  
というところは各所で試行錯誤中かと思います。  
一例として、基礎的な内容ではありますが、現在試している内容を  
記載してみようと思います。

## 前提条件
> capistranoを実行するサーバは、対象の全サーバのrootアカウントに  
> 鍵認証でノーパスワードでログインが可能である

## chefをcapistranoでdeploy時にテスト

capistranoの設定にserverspecの項目を増やすことで  
chef-soloなどが実行された後に、serverspecが実行されます。  
これは台数が多いと時間が結構かかるので良し悪しがあるかと思います。

```
  desc "run serverspec"
  task :run_serverspec do
    `cd /root/chef/ ; rake`
  end
```

## cronで定時実行

`/etc/cron.d/serverspec`

```
0 */1 * * * root cd /root/chef/ ; rake 1> /dev/null
```

正常終了であればログを破棄、エラーが出力された際には  
メールにて通知するようにします。  
  
## とても簡単なことですが

取り敢えずの導入としては、上記２つの方法を実践しています。  
新しくミドルウェアを追加した際にテストがコケたりするので  
なかなか面白いです。  
  
serverspecでどのような監視をしているかなど話し合うの面白そうですよね。

以上、ご参考になれば幸いです。


