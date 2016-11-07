---
layout: post
title: "Monitoring monitor_agent by Sensu"
published: true
date: "2014-07-09T19:39:00+09:00"
comments: true


---

## TL;DR

Monitor the state of the Fluentd by Sensu.  
SensuでFluentdの状態を監視する


### 利用するソフトウェア(Using Software)

- [fluentd](https://github.com/fluent/fluentd)
- [Sensu](https://github.com/sensu/sensu)
- [check-fluentd-monitor-agent.rb](https://github.com/sensu/sensu-community-plugins/blob/master/plugins/fluentd/check-fluentd-monitor-agent.rb)


### 監視設定(Monitoring Settings)

Sensu's Configuration Example  
Sensuの設定例

`check_fluentd_monitor_agent.json`

```
{
  "checks": {
    "check_fluentd_monitor_agent_retry": {
      "command": "/etc/sensu/plugins/check-fluentd-monitor-agent.rb -w 5 -c 10 -m 'retry_count'",
      "interval": 60,
      "occurrences": 3,
      "subscribers": ["foo"],
      "handlers": ["hipchat", "mailer"]
    },
    "check_fluentd_monitor_agent_buffer_total_queued_size": {
      "command": "/etc/sensu/plugins/check-fluentd-monitor-agent.rb -w 1024000 -c 51200000 -m 'buffer_queue_length'",
      "interval": 60,
      "occurrences": 3,
      "subscribers": ["foo"],
      "handlers": ["hipchat", "mailer"]
    }
  }
}
```

- アラート例(Example Alert) 

```
CheckFluentdMonitorAgent WARNING: plugin_id object:XXXXXXX retry_count 8
```

- アラートが出ているプラグインの確認(Check the plug-in target)

```
$ curl http://localhost:24220/api/plugins.json | jq . | grep -10 XXXXXXX
```

Thus, It is useful to grasp if Fluentd could not be temporarily connected to the another service.  
このように、Fluentdが他のサービスへ一時的に接続できなかった場合にアラートが来たりして便利です。
