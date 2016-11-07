---
layout: post
title: "shellscriptでmailコマンドを利用してGmailにメールを送るとnonameという添付ファイルが添付される問題"
published: true
date: "2014-06-04T02:56:00+09:00"
comments: true


---

```
#!/bin/bash

FOO=`command`

echo ${FOO} | mail -s "foo command dayo" foo@example.com
```

のようなスクリプトを作成した時に、送信先である  
Gmailで受信すると本文にコマンドの結果が出力されるのではなく  
nonameという添付ファイルが送られてきた。  
  
原因はコマンドの結果にEscape Sequenceが入っていたため  
文字コードを上手く認識できなかったようだ。  
  
Escape Sequenceとかガッツリやったことがなくて  
IRCに色付けたりターミナルの文字列に色付けたりするぐらいしか  
使ったことがなくて、原因が特定できなかった。  
  
@keitap氏は一撃でEscape Sequenceだってわかった。  
対応としては

[colでエスケープシーケンスを除去 - うまい棒blog](http://d.hatena.ne.jp/hogem/20100320/1269132856)  
  
hogemさんが書いてくれたように`\`を除外するとかして  
Escape Sequenceとして認識させないようにして上手くいった。  
  
```
#!/bin/bash

FOO=`command`

echo ${FOO} | col -b | mail -s "foo command dayo" foo@example.com
```
  
こちらからは以上です。

