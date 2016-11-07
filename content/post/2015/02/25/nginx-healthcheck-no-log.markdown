---
layout: post
title: "nginxで特定のURIだけログに出力しない"
published: true
date: "2015-02-25T16:04:00+09:00"
comments: true


---

nginxでヘルスチェックなど設定している時に特定のURIだけログに出したくない場合の設定

```
    location / {

        if ( $request_uri ~ /healthcheckurl) { access_log off; }

        proxy_pass http://unicorn;
        proxy_set_header Host              $http_host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;

        ...

        break;
    }
```
