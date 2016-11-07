---
layout: post
title: "Instance Store-BackedのAMIをつくる"
published: true
date: "2014-03-18T23:04:00+09:00"
comments: true


---

[Creating an Instance Store-Backed Linux AMI](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-instance-store.html)

基本的にドキュメントに従って作業をすれば作成できます。  
気を付けなければいけない点が何点かあったのでシェアさせて頂きます。  

> ec2-api-tools 1.6.12.0  
> ec2-bundle-vol 1.4.0.9 20071010  
> ec2-upload-bundle 1.4.0.9 20071010  

- AMIをつくる元のインスタンスにて

```
[ec2-user ~]$ mkdir /tmp/cert
[ec2-user ~]$ cd /tmp/cert
```

- 手元からファイルを送る

```
$ scp -i my-private-key.pem /path/to/pk-HKZYKTAIG2ECMXYIBH3HXV4ZBEXAMPLE.pem \
ec2-user@ec2-203-0-113-25.compute-1.amazonaws.com:/tmp/cert/
```

- image元となるデータを作成 

[ami-bundle-vol](http://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/CLTRG-ami-bundle-vol.html)に書いてある通り`--no-filter`を付けないと  
所々ファイルが消えます。

```
[root ec2-user]# $EC2_AMITOOL_HOME/bin/ec2-bundle-vol  --no-filter \
-k /tmp/cert/pk-HKZYKTAIG2ECMXYIBH3HXV4ZBEXAMPLE.pem \
-c /tmp/cert/cert-HKZYKTAIG2ECMXYIBH3HXV4ZBEXAMPLE.pem \
-u your_aws_account_id -r x86_64 -e /tmp/cert
```

- S3にAMIの元となるデータをアップロードします

AMIを作成するregionと合わせないとエラーになります。  
`--region`ではなく`--location`


```
[ec2-user ~]$ ec2-upload-bundle -b my-s3-bucket/bundle_folder/bundle_name \
-m /tmp/image.manifest.xml -a your_access_key_id -s your_secret_access_key \
--location us-west-2
```


- AMIにregisterします

```
[ec2-user ~]$ ec2-register my-s3-bucket/bundle_folder/bundle_name/image.manifest.xml \
-n AMI_name -O your_access_key_id -W your_secret_access_key \
--region us-west-2
```

以上です。
