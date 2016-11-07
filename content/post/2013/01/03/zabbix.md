---
layout: post
title: "Zabbix v2.0.4 + nginx v1.0.15 installed"
published: true
date: "2013-01-03T15:38:00+09:00"
comments: true


---

nginxでZabbix2.0.4をインストールしたのでメモ。

## 環境
 - nginx v1.0.15
 - zabbix v2.0.4
 - MySQL - 5.5.28
 - CentOS 6.3


### Zabbixをyumでインストール

```
$ yum install zabbix20-server-mysql.x86_64
$ yum install zabbix20-2.0.4-1.el6.x86_64
$ yum install zabbix20-server-mysql-2.0.4-1.el6.x86_64
$ yum install zabbix20-server-2.0.4-1.el6.x86_64
```

### Zabbix用のデータベースを用意

```
$ mysql
> grant all privileges on zabbix.* to zabbix@localhost identified by '********';
> create database zabbix character set utf8;
```

### Zabbixのデータをさきほど作成したデータベースに装入

```
$ cd /usr/share/zabbix-mysql/
$ mysql -uzabbix -p zabbix  < schema.sql
$ mysql -uzabbix -p zabbix  < images.sql 
$ mysql -uzabbix -p zabbix  < data.sql
```

`/etc/zabbix_server.conf`に
*DBPassword*を記述。  
デフォルトで書き込み権限ないの意識高い。


### Zabbix Serverを起動
```
$ /etc/init.d/zabbix-server start
tail /var/log/zabbix/zabbix_server.log
```

### nginxとphp-fpmのインストール
```
$ yum install --enablerepo=remi nginx php php-fpm php-devel \  
php-cli php-xml php-mysql php-mbstring php-gd
```

### WebUIのファイルがないことに気付きzabbix2--webをインストール

```
$ yum install --enablerepo=remi zabbix20-web.noarch
```

nginxのデフォルトルートにシンボリックリンク

```
ln -s /usr/share/zabbix /usr/share/nginx/html/zabbix
```


`/etc/nginx/conf.d/zabbix.conf`
```
server {
    listen 80;
    server_name home.kenjiskywalker.org;
    index index.html;
    access_log /var/log/nginx/zabbix/access_log main;
    error_log  /var/log/nginx/zabbix/error_log  error;

    location /zabbix {
        index index.php;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```
*/var/log/nginx/zabbix/*ディレクトリは自分で掘る


`/etc/php.ini`
```
[Date]
; Defines the default timezone used by the date functions
; http://php.net/date.timezone
; date.timezone = 
date.timezone = Asia/Tokyo


; 追記
post_max_size = 32M
max_execution_time = 300
max_input_time = 300
```
timezoneの設定はphp-fpmをstop/startしないと反映されなかった。

```
$ /etc/init.d/nginx start
$ /etc/init.d/php-fpm start
```

あとは`http://domain/zabbix/`にアクセスすれば閲覧できるはず。
ログイン確認後はすみやかにパスワードを変更してとりあえずは完了。
