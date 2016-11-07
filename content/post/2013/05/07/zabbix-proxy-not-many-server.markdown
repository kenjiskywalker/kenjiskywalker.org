---
layout: post
title: "zabbix-proxyに複数のServerを設定することはできない"
published: true
date: "2013-05-07T17:50:00+09:00"
comments: true


---

忘れそうだから書いておく。  

- [3.2.3 Zabbixエージェント (UNIX、スタンドアロンデーモン)](https://www.zabbix.com/documentation/jp/1.8/manual/processes/zabbix_agentd)
- [3.2.2 Zabbixプロキシ](https://www.zabbix.com/documentation/jp/1.8/manual/processes/zabbix_proxy)
  
> ZabbixサーバのIPアドレス(またはホスト名)をカンマ区切りで指定します。  
  
っていう文言の有無で確認すればよかった。  
けど、書いてないのは「わざわざ言わせんな恥ずかしい・・・///」  
みたいな感じにも受け取れるけど、取り敢えず送れない。  
  
2時間ぐらいあーだこーだしてた。最終的にngrepして  
パケットの送受信されていないこと確認して終わった。ngrep便利だ。
