---
layout: post
title: "Sensuで一つのJSONファイルに複数の設定を記述する"
published: true
date: "2014-05-12T16:40:00+09:00"
comments: true


---

deep_mergeなのでこう書けます。

- /etc/sensu/conf.d/checks/check_hoge.json

```
{
  "checks": {
    "check_hoge_one": {
      "command": "/etc/sensu/plugins/check-hoge.rb -C 1",
      "interval": 60,
      "subscribers": ["all"],
      "handlers": ["hipchat", "mailer"]
    },
    "check_hoge_two": {
      "command": "/etc/sensu/plugins/check-hoge.rb -C 2",
      "interval": 60,
      "subscribers": ["all"],
      "handlers": ["hipchat", "mailer"]
    },
    "check_hoge_three": {
      "command": "/etc/sensu/plugins/check-hoge.rb -C 3",
      "interval": 60,
      "subscribers": ["all"],
      "handlers": ["hipchat", "mailer"]
    }
  }
}
```

