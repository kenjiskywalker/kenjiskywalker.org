---
layout: post
title: "curlでcurl: (51) SSL: certificate verification failed (result: 5)が出る時の対処法"
published: true
date: "2015-08-05T18:24:00+09:00"
comments: true


---

> OS X Yosemite 10.10.4

```
curl: (51) SSL: certificate verification failed (result: 5)
```

```
🙏  ruby -ropenssl -e "p OpenSSL::X509::DEFAULT_CERT_FILE"
"/usr/local/etc/openssl/cert.pem"
🙏
🙏
🙏  cd /usr/local/etc/openssl/
🙏
🙏  curl -O http://curl.haxx.se/ca/cacert.pem
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  252k  100  252k    0     0  55123      0  0:00:04  0:00:04 --:--:-- 58321
🙏
🙏  mv cacert.pem cert.pem
```

で解決できた。正しいかどうかは知らん。
