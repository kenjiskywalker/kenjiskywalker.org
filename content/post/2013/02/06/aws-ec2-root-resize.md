---
layout: post
title: "AWS::EC2のルートパーティションをリサイズする"
published: true
date: "2013-02-06T21:24:00+09:00"
comments: true


---

基本的にルートパーティションはEBSで8GB決め打ちだったので  
サイズ変更できないかなーと思ったらできたのでメモ。  

1. 普通にEC2のインスタンスつくる
2. インスタンスを落とす
3. Volumesから作成されたインスタンスのルートボリュームをDetach
4. DetachされたVolumeからSnapshotを作成
5. SnapshotからVolumeを作成(この時にディスクサイズ指定)
6. 作成されたボリュームをAttach(Deviceは ***/dev/sda1*** を指定)
7. インスタンスを起動
8. *fdisk -l* などで認識しているディスクサイズが変わったことを確認して
9. *resize2fs /dev/xvda1*

さわりはじめたばかりなので、もっと簡単な方法ありましたら  
教えてくださいませ。
