---
layout: post
title: "hubot-atというhubot pluginをつくった"
published: true
date: "2014-09-04T14:22:00+09:00"
comments: true


---

Slackを使い始めたので昔つくった[unazu_kun](http://kenjiskywalker.hatenablog.com/entry/20121010/1349878137)の機能を  
hubotに持ってきました。  


## [hubot-at](https://www.npmjs.org/package/hubot-at)
  
![https://dl.dropboxusercontent.com/u/5390179/hubot-at-capture.png](https://dl.dropboxusercontent.com/u/5390179/hubot-at-capture.png)

というように

```
> hubot at HH:MM message
```

と指定することによって、その指定した時間に`message`を通知してくれます。  
  
元々taiyohさんが  
  
- [hubotにもunazu_kun的な機能を追加する - taiyoh's memorandum](http://taiyoh.hatenablog.com/entry/2013/05/19/105832)  
  
にて書いてくれていたので、それを踏襲しています。  
ありがとうございます。  
  
最低限の実装しかしていません。何かあればpull requestください:)  
