---
layout: post
title: "AWS::Provisioned IOPSなRDSをVPC内につくろうとしたら"
published: true
date: "2013-02-15T13:21:00+09:00"
comments: true


---

![RDS Error Capture](https://dl.dropbox.com/u/5390179/cb9cb8c8599fe3da49aa78be3c700b31.png)  

こんなエラーが出た。  

> Cannot create a db.m1.small Multi-AZ instance because at least 2 subnets  
> must exist in availability zones with sufficient capacity for 
> VPC and provisioned IOPS for db.m1.small,  
> so 1 more must be created in other availability zones;
> choose from these availability zones: ap-northeast-1c.

AZが足りなさそうだったのでVPCとRDSのSubnetGroupsそれぞれに  
*ap-northeast-1c*を追加したらエラーが消えてRDS作成できた。
  
AZ、*ap-northeast-1a*が一番使われて*ap-northeast-1c*が一番使われないの人間っぽいし  
Amazonさんもキャパシティプランニングとか大変だなーって思って  
缶コーヒーでもおごってあげたい気持ちになりました。
  
けどお給料はAmazonさんの方が良さそうなので、焼肉おごってほしいです。
