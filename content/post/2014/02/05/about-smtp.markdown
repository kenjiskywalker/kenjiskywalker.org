---
layout: post
title: "SMTPが何故嫌いか"
published: true
date: "2014-02-05T18:04:00+09:00"
comments: true


---

雑談です。

- 送り先を間違えると二度と取り戻せない(メールサーバを管理している場合を除く)  
- そのSMTPのトラフィックの半分以上はスパム([Kaspersky Security Bulletin. Spam evolution 2013](http://www.securelist.com/en/analysis/204792322/Kaspersky_Security_Bulletin_Spam_evolution_2013))
  
送り先を間違えると二度と取り戻せないのは、人間に対して厳しい仕様ではないのかなと。  
万が一間違えた場合、インターネットは無力なことが多くて  
該当のメールを削除してくださいと電話したり、メール誤送信についてのFAXを送ったりする。  

インターネットでは物騒が当たり前なようですが、大半がSPAMのトラフィックを捌く方も大変ですね。  
  
で、どうしたら良いって話なんですが  
メールアドレスじゃなくてhash値生成してそこのURLへアクセスすると   
メッセージが見れてやり取りができる。万が一内容を間違えた場合は  
誤った内容のメッセージを削除して再生成する。とかが良いのかなと。  
  
そしてそのURLをどうやって送るかっていうとSMT(この文章はここで終わっている)
