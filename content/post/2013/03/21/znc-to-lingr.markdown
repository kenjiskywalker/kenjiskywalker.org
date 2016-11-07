---
layout: post
title: "ZNCでlingr-ircに接続する設定"
published: true
date: "2013-03-21T00:25:00+09:00"
comments: true


---

[ゆるふわなかんじで perl の話題をするためのチャットルームをつくってみた - tokuhirom's blog.](http://blog.64p.org/entry/2013/03/13/195515)  

インターネットそんなに古くからやってないのでlingrとかあんまり知らなかったけど  
面白そうだから入ってみた。ブラウザでログインとかしたくなかったので  

[psychs/lingr-irc](https://github.com/psychs/lingr-irc)  

使って

```
$ nohup ruby lig.rb &
```

とかユルフワな感じでふぉわーどするようにしてる。  
長く動かすようだとdaemontools化した方が良い。  
今ならtokuhiromさんがつくったPerlバージョンの  

[tokuhirom/lingr-ircd](https://github.com/tokuhirom/lingr-ircd)  
  
こっち使ってもいいかもしれない。  
  
> あとずっとハマってたのが、アカウントつくってIRCでつなげねー！  
> ってなってたけど、1回ルームに入ってからじゃないとダメだった。  
  
どうせならZNCで繋ぎたかったのでこんな感じでつないでる。  

```
        <Network lingr>
                FloodBurst = 4
                FloodRate = 1.00
                IRCConnectEnabled = true
                Ident = [lingr account name]
                RealName = hotoke
                Server = 127.0.0.1 26667 [lingr password]

                <Chan #perl_jp>
                        Buffer = 10
                </Chan>
        </Network>
```

**Ident** にlingrのユーザ名入れて  
**Server** で指定するパスワードにlingr userのパスワード設定するだけだった。  
webadmin使えばNetworkの設定追加する時も再起動なしでいけるしすごい良い。  
  
ずっとwebadmin見れないなーって思ってたら  
@handlename先輩が「Chromeでは見れないよ」って  
アドバイスくれて、さすがオレたちのhandle先輩！ってなってた。  
  
ChromeだとブラウザでIRCポートとか接続しに行くと良くないアクセスみたいな判断して  
遮断しちゃうみたい。Firefoxだと開けた。この辺細かい情報は調べてない。  
  
調べてないって書いたらひろせおじさんがエントリー書いてくれた  
  
 - [ChromeでへんてこなポートにHTTPで繋ぎたい / (ひ)メモ](http://d.hatena.ne.jp/hirose31/20130327/1364362758)  
  
hirose31++
  
祝日なのにインターネットに関わってて体調悪くなってる。  
休肝日みたいな感じで休インターネット日みたいなの必要っぽい。
