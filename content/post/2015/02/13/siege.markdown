---
layout: post
title: "負荷テストが気軽に行えるsiegeでちょっとハマった"
published: true
date: "2015-02-13T18:06:00+09:00"
comments: true


---

> siege: version 3.0.9

## TL;DR

httpsのリクエストの際にうんともすんともいわなくて、lddで見たら  
opensslのライブラリ読み込んでなかった。

## Siege

- [Siege Home](http://www.joedog.org/siege-home/)  
- [Siege でお手軽 Web 負荷テスト - Qiita](http://qiita.com/inokappa/items/84f42dbd718a8070bd1d)

詳しくは上記URLを参照してください。  
  
kappa大先生の記事を見て、これいいやん！ってなって導入した。  
負荷テストをかけるサーバも今ではAWSのスポットインスタンスを利用すれば  
c3.4xlargeも$0.5/hで借りれて最高だ。  


## インストール

```
# gccが必要なのでインストール
$ yum install gcc

$ wget http://download.joedog.org/siege/siege-3.0.9.tar.gz
$ tar xzf siege-3.0.9.tar.gz
$ cd siege-3.0.9
$ ./configure
$ make -j 16
$ make install
```
  
### HTTPSにつながらない?

```
$ siege -c 1 -t 2S http://example.com/
** SIEGE 3.0.9
** Preparing 1 concurrent users for battle.
The server is now under siege...
HTTP/1.1 200   0.69 secs:    5121 bytes ==> GET  /
HTTP/1.1 200   0.68 secs:    5123 bytes ==> GET  /

Lifting the server siege...      done.

Transactions:                      0 hits
Availability:                   0.00 %
Elapsed time:                   1.00 secs
Data transferred:               0.00 MB
Response time:                  0.00 secs
Transaction rate:               0.00 trans/sec
Throughput:                     0.00 MB/sec
Concurrency:                    0.01
Successful transactions:           1
Failed transactions:               0
Longest transaction:            0.01
Shortest transaction:           0.01

FILE: /root/siege.log
You can disable this annoying message by editing
the .siegerc file in your home directory; change
the directive 'show-logfile' to false.
$
```

では応答したのに  

```
$ siege -c 1-t 2S https://example.com/
** SIEGE 3.0.9
** Preparing 1 concurrent users for battle.
The server is now under siege...
Lifting the server siege...      done.

Transactions:                      0 hits
Availability:                   0.00 %
Elapsed time:                   4.68 secs
Data transferred:               0.00 MB
Response time:                  0.00 secs
Transaction rate:               0.00 trans/sec
Throughput:                     0.00 MB/sec
Concurrency:                    0.00
Successful transactions:           0
Failed transactions:               3
Longest transaction:            0.00
Shortest transaction:           0.00

FILE: /root/siege.log
You can disable this annoying message by editing
the .siegerc file in your home directory; change
the directive 'show-logfile' to false.
$
```

などとFailedになってしまった。  
最初、cookieで認証しているのでcookieの渡し方が悪かったのかと思ったが  
ふとライブラリちゃんと読み込んでいるのか気になったので確認してみた。

```
$ ldd /usr/local/bin/siege
        linux-vdso.so.1 =>  (0x00007fff0a7fe000)
        libpthread.so.0 => /lib64/libpthread.so.0 (0x00007fe27e031000)
        libc.so.6 => /lib64/libc.so.6 (0x00007fe27dc8c000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fe27e253000)
$
```

おや...   
ということで`yum install openssl-devel`をしてから再度インストールしなおす。

```
$ ldd /usr/local/bin/siege
        linux-vdso.so.1 =>  (0x00007fff3a561000)
        libpthread.so.0 => /lib64/libpthread.so.0 (0x00007f77766e2000)
        libdl.so.2 => /lib64/libdl.so.2 (0x00007f77764de000)
        libssl.so.10 => /usr/lib64/libssl.so.10 (0x00007f7776270000)
        libcrypto.so.10 => /lib64/libcrypto.so.10 (0x00007f7775e8c000)
        libc.so.6 => /lib64/libc.so.6 (0x00007f7775ae7000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f7776904000)
        libgssapi_krb5.so.2 => /lib64/libgssapi_krb5.so.2 (0x00007f77758a3000)
        libkrb5.so.3 => /lib64/libkrb5.so.3 (0x00007f77755be000)
        libcom_err.so.2 => /usr/lib64/libcom_err.so.2 (0x00007f77753bb000)
        libk5crypto.so.3 => /lib64/libk5crypto.so.3 (0x00007f777518f000)
        libz.so.1 => /lib64/libz.so.1 (0x00007f7774f79000)
        libkrb5support.so.0 => /lib64/libkrb5support.so.0 (0x00007f7774d6e000)
        libkeyutils.so.1 => /lib64/libkeyutils.so.1 (0x00007f7774b6a000)
        libresolv.so.2 => /lib64/libresolv.so.2 (0x00007f7774953000)
        libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x00007f777473d000)
        libselinux.so.1 => /usr/lib64/libselinux.so.1 (0x00007f777451b000)
$
```

おお、色々読み込んでいる  

## 改めて確認
  
```
$ siege -c 1 -t 3S https://example.com/
** SIEGE 3.0.9
** Preparing 1 concurrent users for battle.
The server is now under siege...
HTTP/1.1 200   0.78 secs:    5119 bytes ==> GET  /

Lifting the server siege...      done.

Transactions:                      1 hits
Availability:                 100.00 %
Elapsed time:                   2.89 secs
Data transferred:               0.00 MB
Response time:                  0.78 secs
Transaction rate:               0.35 trans/sec
Throughput:                     0.00 MB/sec
Concurrency:                    0.27
Successful transactions:           1
Failed transactions:               0
Longest transaction:            0.78
Shortest transaction:           0.78

FILE: /root/siege.log
You can disable this annoying message by editing
the .siegerc file in your home directory; change
the directive 'show-logfile' to false.
$
```

無事レスポンスを取得することができた。  

### cookieの渡し方

`--header="Cookie: k=v; k=v;"`みたいな渡し方でいけた。

```
$ siege -c 1 -t 3S https://example.com/ --header="Cookie: key_one=value_one; domain=.example.com; path=/; expires=Fri, 13 Feb 2015 16:41:26 -0000; key_two=value_two; path=/;"
```

こちらからは以上です。
