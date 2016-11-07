---
layout: post
title: "Created check-fluentd-monitor-agent of sensu-plugin"
published: true
date: "2014-05-30T19:08:00+09:00"
comments: true


---

Colleagues said to me that I want to monitoring fluentd's state,  
Then I created this plugin.  
同僚がfluentdの状態を監視したいと言っていたので  
私はこのプラグインをつくりました。  
  
- [Monitoring Fluentd - fluentd](http://docs.fluentd.org/articles/monitoring)  
- [sensu-community-plugins/plugins/fluentd/check-fluentd-monitor-agent.rb](https://github.com/sensu/sensu-community-plugins/blob/master/plugins/fluentd/check-fluentd-monitor-agent.rb)

how to use.  
使い方  

```
{
  "checks": {
    "check_fluentd_monitor_agent_retry": {
      "command": "/etc/sensu/plugins/check-fluentd-monitor-agent.rb -w 5 -c 10 -m 'retry_count'",
      "interval": 60,
      "occurrences": 1,
      "subscribers": ["foo"],
      "handlers": ["hipchat", "mailer"]
    },
    "check_fluentd_monitor_agent_buffer_total_queued_size": {
      "command": "/etc/sensu/plugins/check-fluentd-monitor-agent.rb -w 1024 -c 5120 -m 'buffer_queue_length'",
      "interval": 60,
      "occurrences": 1,
      "subscribers": ["foo"],
      "handlers": ["hipchat", "mailer"]
    }
  }
}
```

Please try it.  
よかったらご利用ください。
