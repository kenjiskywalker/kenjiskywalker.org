---
layout: post
title: "Postfixのheader_checksでの否定の条件について"
published: true
date: "2013-01-23T20:52:00+09:00"
comments: true


---

[header_checks - Postfix built-in content inspection](http://www.postfix.org/header_checks.5.html)  
[regexp_table - format of Postfix regular expression tables](http://www.postfix.org/regexp_table.5.html)

`header_checks`
```
!/^(To|From):.*@example\.com*/ REJECT
```

とすれば、対象の*example.com*のドメイン意外受け付けなくて  
ライフチェンジングなのでは！！！！！！！！  
と思ったのですが、header_checksの仕様上  
ヘッダ全てに対してではなく、1行毎にルールを適用するため  
例えば、ヘッダの1行目が  
  
```Delivered-To: foo@example.com```  
  
である場合、***マッチしない***と認識されてREJECTされます。  

この意味がわからなくてずっと悩んでいました。

メールの破棄の処理をheader_checksの例外処理を利用して行うのは  
とてもむずかしいので、素直にSpamAssasinやprocmailなどを利用しましょう！  
  
というお話でした。  

(;´д｀)ﾄﾎﾎ…
