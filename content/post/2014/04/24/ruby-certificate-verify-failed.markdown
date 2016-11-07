---
layout: post
title: "Rubyでconnect': SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (OpenSSL::SSL::SSLError)\nが出た時の対応方法"
published: true
date: "2014-04-24T23:00:00+09:00"
comments: true


---

SensuでSSL使うプラグインでエラーが出ていた。  
その対処法を忘れないようにメモ。

```
$
$ /opt/sensu/embedded/bin/ruby -ropenssl -e "p OpenSSL::X509::DEFAULT_CERT_FILE"
"/opt/sensu/embedded/ssl/cert.pem"
$
$ ls /opt/sensu/embedded/ssl/cert.pem
ls: cannot access /opt/sensu/embedded/ssl/cert.pem: No such file or directory
$
$ wget -O /opt/sensu/embedded/ssl/cert.pem http://curl.haxx.se/ca/cacert.pem
--2014-04-24 08:10:09--  http://curl.haxx.se/ca/cacert.pem
Resolving curl.haxx.se... 80.67.6.50, 2a00:1a28:1200:9::2
Connecting to curl.haxx.se|80.67.6.50|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 250283 (244K)
Saving to: “/opt/sensu/embedded/ssl/cert.pem”

100%[============================================================================================================================================>] 250,283      253K/s   in 1.0s

2014-04-24 08:10:11 (253 KB/s) - “/opt/sensu/embedded/ssl/cert.pem” saved [250283/250283]

$ ls /opt/sensu/embedded/ssl/cert.pem
/opt/sensu/embedded/ssl/cert.pem
$
```

以上です。
