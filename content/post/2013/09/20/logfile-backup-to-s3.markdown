---
layout: post
title: "ログファイルをS3にバックアップする"
published: true
date: "2013-09-20T00:44:00+09:00"
comments: true


---

デイリーのログファイルをS3へバックアップしたいという事案はよくあると思います。  
一つの例として私の方法を載せますので、よりよい方法などあれば教えて頂きたいです。

## backup dir 

`/var/log/backup/nginx/YYYYMMDD/`  
`/var/log/backup/app/YYYYMMDD/`  

## backup file

`/var/log/backup/nginx/20130918/access.20130918-00.log.gz`
`/var/log/backup/nginx/20130918/access.20130918-01.log.gz`
`/var/log/backup/nginx/20130918/access.20130918-02.log.gz`  
...
  

`/var/log/backup/app/20130918/app.20130918-00.log.gz`
`/var/log/backup/app/20130918/app.20130918-01.log.gz`
`/var/log/backup/app/20130918/app.20130918-02.log.gz`  
...


上記ディレクトリに、それぞれ  
nginx、アプリケーションのログがあるとします。  
  
nginxのログはtd-agentによって

```
<store>
  type file_alternative
  time_slice_format %Y%m%d-%H
  path /var/log/backup/nginx/access
  output_data_type attr:msg
  localtime
  output_include_time false
</store>
```

`/var/log/backup/nginx/access.20130919-00.log`
`/var/log/backup/nginx/access.20130919-01.log`
`/var/log/backup/nginx/access.20130919-02.log`

このように吐き出され、それを日付が変わったのち

```
#!/bin/sh

# set -e
DATE=`date --date '1 days ago' +%Y%m%d`
BASE="/var/log/backup"
for type in nginx app;
do
  DIR="${BASE}/${type}/${DATE}"
  mkdir "${DIR}"
  mv ${BASE}/${type}/*${DATE}*log "${DIR}"
  nice gzip --fast ${DIR}/*log
done
```

こちらのアーカイブスクリプトによって

`/var/log/backup/nginx/YYYYMMDD/`

というディレクトリを作成し、その配下へ昨日分のログファイルをgzip化し退避します。  
そして、退避したログファイルをS3へバックアップします。

バックアップは[s3cmd](http://s3tools.org/s3cmd)を利用しても良いですが  
先日1.0のリリースが行われた[awscli](https://github.com/aws/aws-cli)を利用します。

## backup script

{% gist 6625841 %}

`aws s3 cp --recursive`によって昨日分のログファイルディレクトリを  
再帰的にバックアップを行い、ファイルの整合性を担保する為に  
ファイルサイズの比較を行っています。(可能であればMD5チェックを行いたい)
  
このように、深夜に昨日分のログファイルをS3にバックアップするようにしています。  
  
以上、ご参考になれば幸いです。
