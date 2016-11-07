---
layout: post
title: "特定のインスタンスIDのタグのValueを出力する"
published: true
date: "2016-07-12T10:31:00+09:00"
comments: true


---

### `query`オプションとかよー使わんわということで個人的メモ

`Name`タグを出力したければこう

```
$ aws ec2 describe-instances \
          --instance-ids i-XXXXXXXX \
          --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' \
          --output text
```
