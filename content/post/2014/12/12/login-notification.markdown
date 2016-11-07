---
layout: post
title: "fluentdを利用してsshログインを通知する"
published: true
date: "2014-12-12T22:53:00+09:00"
comments: true


---

sshを利用していると招かれざる客の来訪が多い。  
また、サーバに不必要にログインしている関係者がいないか  
把握しつづけるのも難しい。  
  
今回はfluentdを利用して簡単にログイン周りの通知をSlackに流してみる。  
  
## 準備

`/var/log/secure`はパーミッションが厳しいので  
y-kenさんのブログを参考にパーミッションを変更する必要があります。

- [Fluentdでsyslogを取り込むための権限設定（CentOS 5&6両対応） - Y-Ken Studio](http://y-ken.hatenablog.com/entry/fluentd-syslog-permission) 

SlackのAPIがバージョンアップしてリアルタイム性を持つようになった。  
  
- [A new Slack API: The inevitable rise of the bots Bots](http://slackhq.com/post/104688116560/rtm-api)  

個人的にはリアルタイム性よりも  
private roomでもhubotが利用できるようになったのいうのがアツい。  
これで色々遊べるようになる。

- [fluent-plugin-slack](https://github.com/sowawa/fluent-plugin-slack)

手元で`endpoint`を変更して動くようになった。みんな普通に動いているのかな


```
private
def endpoint
  # URI.parse "https://#{@team}.slack.com/services/hooks/incoming-webhook?token=#{@api_key}"
  URI.parse "https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX"
end
```

Real Time Messagingを利用するためには  
  
```
https://slack.com/api/chat.postMessage?token=xoxp-XXXXXXXXXX-XXXXXXXXXX-XXXXXXXXXX-XXXXXX&channel=XXXXXXXXX&text=XXXXX&username=XXXXX'
```

のようにリクエストを送る必要がある。  
時間があればpull requestしたい。(あと20分で書き終えなければ...)  

[chat.postMessage - slack API](https://api.slack.com/methods/chat.postMessage)
  

## 2014/12/16 追記

sowawaさんにmergeして頂いた。感謝

## 設定

- /etc/td-agent/td-agent.conf

```
<source>
  type tail
  path /var/log/secure
  format syslog
  tag secure_log
  pos_file /var/log/td-agent/syslog_secure.pos
</source>

<match secure_log.**>
  type grep
  input_key message
  regexp Accepted|failure|Invalid
  add_tag_prefix greped
</match>

<match greped.**>
  type buffered_slack
  rtm true
  token API_KEY
  team TEAMNAME
  channel %23general # You should use %23 in return for #
  username fluentd
  color danger
  icon_emoji :shit:
  buffer_path /var/log/td-agent/buffer/
  flush_interval 5s
</match>
```

こんな感じで`Accepted`、`failure`、`Invalid`の文字列を  
sonotsさんがつくった[fluent-plugin-grep](https://github.com/sonots/fluent-plugin-grep)を利用して抽出。  
  
そうすると  
  
![](http://i.gyazo.com/00260a2b25dfbfb9b55f00eb1b20ca05.png)


こんな感じで通知されてくる。セキュリティを気にする環境では  
このような設定を入れておくと良いのではないでしょうか。
