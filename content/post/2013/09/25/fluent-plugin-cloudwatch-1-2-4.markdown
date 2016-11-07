---
layout: post
title: "fluent-plugin-cloudwatch 1.2.4 release"
published: true
date: "2013-09-25T23:06:00+09:00"
comments: true


---

### [https://rubygems.org/gems/fluent-plugin-cloudwatch](https://rubygems.org/gems/fluent-plugin-cloudwatch)  
  
リリースしました。  
CloudWatchのAPIが、値なしでレスポンス返してくることはよくあったのですが、  
リクエストに対してレスポンスが取得できずに詰まってしまう現象があり、  
その解決策としてtimeoutを追加しました。  
同現象でお悩みの方はバージョンアップをお願いいたします。  
  
> 本件でアドバイスを頂いたfujiwaraさん有難うございます。
  
また、td-agentの`version 1.1.17`から正式に`configtest`が導入され  
設定に誤りがあった場合、エラー内容が出力され、  
`reload`、および`restart`が走らないようになっています。  

この変更により、運用中の設定ファイルの更新作業も楽しく行えるかと思います。  
  
合わせてアップデートをおすすめいたします。  
@repeatedly++
