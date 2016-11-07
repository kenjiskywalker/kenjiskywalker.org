---
layout: post
title: "supervisorでログのディレクトリをSIGUSR2を使って開き直す"
published: true
date: "2013-12-04T20:04:00+09:00"
comments: true


---

- supervisorをインストール

```
$ sudo yum -y install python-setuptools
$ sudo easy_install supervisor
$ echo_supervisord_conf > /etc/supervisord.conf
```

- テストスクリプト(/root/while.sh)を置く

```
#!/bin/bash
while true ; do date ; sleep 1 ; done
```

- /etc/supervisord.conf

```
[unix_http_server]
file=/tmp/supervisor.sock   ; (the path to the socket file)
[supervisord]
logfile=/var/log/supervisord.log ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=50MB        ; (max main logfile bytes b4 rotation;default 50MB)
logfile_backups=10           ; (num of main logfile rotation backups;default 10)
loglevel=info                ; (log level;default info; others: debug,warn,trace)
pidfile=/tmp/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
nodaemon=false               ; (start in foreground if true;default false)
minfds=1024                  ; (min. avail startup file descriptors;default 1024)
minprocs=200                 ; (min. avail process descriptors;default 200)
childlogdir=/var/log/supervisor  ; ('AUTO' child log dir, default $TEMP)
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket
[program:hello]
priority = 100
command = sh /root/while.sh
redirect_stderr = true
```

- supervisorを走らせる

```
$ mkdir /var/log/supervisor
$ supervisord -c /etc/supervisord.conf
```

- ログが出力されているのか確認

```
$ tail -f /var/log/supervisor/hello-std*
==> /var/log/supervisor/hello-stdout---supervisor-4rZfjC.log <==
Wed Dec  4 10:32:17 UTC 2013
Wed Dec  4 10:32:18 UTC 2013
Wed Dec  4 10:32:19 UTC 2013
Wed Dec  4 10:32:20 UTC 2013
```

- 状態を確認するためにプロセスを監視しておく

```
$ strace -e trace=open -p `pgrep supervisor`
```


- /var/log/supervisor/を移動する

```
$ mv /var/log/supervisor /var/log/supervisor_old
```

tailで流しているログが流れ続けているか確認する。  
ログが止まっていたりしたらがんばってください。  

- 別のディレクトリを作成してsymlinkしてみる

```
$ mkdir /var/log/supervisor_new
$ ln -s /var/log/supervisor_new /var/log/supervisor
$ ls -la /var/log/supervisor
```

## [http://supervisord.org/running.html](http://supervisord.org/running.html)

- `SIGUSR2`を発行して新しいディレクトリの方にファイルを出力するか確認する

出力され続けていることを確認

```
$ ls -la /var/log/supervisor_old
```

`SIGUSR2`を発行

```
$ kill -SIGUSR2 `pgrep supervisor`
```

こんな感じでシグナルがやってきて

```
$ strace -e trace=open -p `pgrep supervisor`
Process 22859 attached - interrupt to quit
--- SIGUSR2 (User defined signal 2) @ 0 (0) ---
open("/var/log/supervisord.log", O_WRONLY|O_CREAT|O_APPEND, 0666) = 3
open("/var/log/supervisor/hello-stdout---supervisor-4rZfjC.log", O_WRONLY|O_CREAT|O_APPEND, 0666) = 5
```

新しいディレクトリ(symlinkを貼った方に)にログが出力されはじめる

```
$ tail -f /var/log/supervisor/hello-std*
Wed Dec  4 10:03:42 UTC 2013
Wed Dec  4 10:03:43 UTC 2013
Wed Dec  4 10:03:44 UTC 2013
Wed Dec  4 10:03:45 UTC 2013
Wed Dec  4 10:03:46 UTC 2013
Wed Dec  4 10:03:47 UTC 2013
```

学ぶことは多い。

