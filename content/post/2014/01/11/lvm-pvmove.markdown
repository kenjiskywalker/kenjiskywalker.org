---
layout: post
title: "pvmoveを利用して物理ディスクのデータを別の物理ディスクへオンラインで移設する"
published: true
date: "2014-01-11T13:31:00+09:00"
comments: true


---

AWSとLVMを利用することによって、オンラインで  
EBSをアタッチして、pvmoveでデータを新しいEBSへ移行し  
元のEBSを切り離すことができる。

## 参考

[redhat カスタマーポータル - 6 5.4. 論理ボリュームからのディスクの削除](https://access.redhat.com/site/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html/Logical_Volume_Manager_Administration/disk_remove_ex.html)

<blockquote class="twitter-tweet" lang="ja"><p>pvmoveは同一VG内の空きPVに移動するのか。ということは旧ディスクから新ディスクへの移行は 1.新ディスクをLVMフォーマットで作成して 2.新ディスクをPV化して 3.旧ディスクがアサインされいるVGにvgexendでPVを追加して 4.pvmoveか</p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/statuses/420484347779489792">2014, 1月 7</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="ja"><p>pvremoveするときはVGにアサインされているからまずvgreduceで対象のPVを切り離してからpvremoveか。当たり前っちゃあ当たり前か</p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/statuses/420486502531874816">2014, 1月 7</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

とのことです。

## 検証環境

```
- ルートパーティション
/dev/xvda1 16GB 

- EBS
/dev/xvdb  64GB EBS

- RAID0用EBS
/dev/xvdc  16GB EBS
/dev/xvdd  16GB EBS
/dev/xvde  16GB EBS
/dev/xvdf  16GB EBS
```

xvdbに既存データが存在していており  
そのデータをmd127に移設する。


```
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# fdisk -l

Disk /dev/xvda1: 17.2 GB, 17179869184 bytes
255 heads, 63 sectors/track, 2088 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000


Disk /dev/xvde: 17.2 GB, 17179869184 bytes
255 heads, 63 sectors/track, 2088 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000


Disk /dev/xvdd: 17.2 GB, 17179869184 bytes
255 heads, 63 sectors/track, 2088 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000


Disk /dev/xvdc: 17.2 GB, 17179869184 bytes
255 heads, 63 sectors/track, 2088 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000


Disk /dev/xvdb: 68.7 GB, 68719476736 bytes
255 heads, 63 sectors/track, 8354 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000


Disk /dev/xvdf: 17.2 GB, 17179869184 bytes
255 heads, 63 sectors/track, 2088 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

[root@lvm-test-server ~]#
```


### EBS x4をまとめてRAID0を組む

```
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# yes | mdadm --create /dev/md127 --level=0 --raid-devices=4 /dev/xvd[cdef]
mdadm: /dev/xvdc appears to be part of a raid array:
    level=raid0 devices=4 ctime=Tue Jan  7 09:36:58 2014
mdadm: /dev/xvdd appears to be part of a raid array:
    level=raid0 devices=4 ctime=Tue Jan  7 09:36:58 2014
mdadm: /dev/xvdf appears to be part of a raid array:
    level=raid0 devices=4 ctime=Tue Jan  7 09:36:58 2014
Continue creating array? mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md127 started.
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# cat /proc/mdstat
Personalities : [raid0]
md127 : active raid0 xvdf[3] xvde[2] xvdd[1] xvdc[0]
      67106816 blocks super 1.2 512k chunks

unused devices: <none>
[root@lvm-test-server ~]#
```

### 既存のVG（引っ越し元のディスクが入っているVG）にRAID0のPVをアサイン

```
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvcreate /dev/md127
  Physical volume "/dev/md127" successfully created
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgdisplay
  --- Volume group ---
  VG Name               vgrp0
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               63.99 GiB
  PE Size               4.00 MiB
  Total PE              16381
  Alloc PE / Size       0 / 0
  Free  PE / Size       16381 / 63.99 GiB
  VG UUID               j4hcOI-hsYy-j8jL-Dnp7-wa44-ue4c-ZlMi5m

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgextend vgrp0 /dev/md127
  Volume group "vgrp0" successfully extended
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgdisplay
  --- Volume group ---
  VG Name               vgrp0
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               127.99 GiB
  PE Size               4.00 MiB
  Total PE              32766
  Alloc PE / Size       16383 / 64.00 GiB
  Free  PE / Size       16383 / 64.00 GiB
  VG UUID               x6y3NX-WNwZ-8pOj-Ez0S-U7r4-fice-9CljNP

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvs -o+pv_used
  PV         VG    Fmt  Attr PSize  PFree Used
  /dev/md127 vgrp0 lvm2 a--  64.00g    0  64.00g
  /dev/xvdb1 vgrp0 lvm2 a--  64.00g    0  64.00g
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
```

この時点でxvdb1(64GB)とmd127(128GB)がVGにアサインされている。  

### PVからPVへデータを移行

```
[root@lvm-test-server ~]# pvmove /dev/xvdb1
  /dev/xvdb1: Moved: 0.0%
  /dev/xvdb1: Moved: 0.4%
  /dev/xvdb1: Moved: 0.7%
  /dev/xvdb1: Moved: 1.1%
  /dev/xvdb1: Moved: 1.4%
  /dev/xvdb1: Moved: 1.8%
  /dev/xvdb1: Moved: 2.1%
  /dev/xvdb1: Moved: 2.5%
  /dev/xvdb1: Moved: 2.8%
  /dev/xvdb1: Moved: 3.2%

  ...

  /dev/xvdb1: Moved: 99.1%
  /dev/xvdb1: Moved: 99.5%
  /dev/xvdb1: Moved: 99.8%
  /dev/xvdb1: Moved: 100.0%
    Found volume group "vgrp0"
    Found volume group "vgrp0"
    Loading vgrp0-lvol0 table (253:0)
    Loading vgrp0-pvmove0 table (253:2)
    Suspending vgrp0-lvol0 (253:0) with device flush
    Suspending vgrp0-pvmove0 (253:2) with device flush
    Found volume group "vgrp0"
    Resuming vgrp0-pvmove0 (253:2)
    Found volume group "vgrp0"
    Resuming vgrp0-lvol0 (253:0)
    Found volume group "vgrp0"
    Removing vgrp0-pvmove0 (253:2)
    Removing temporary pvmove LV
    Writing out final volume group after pvmove
    Creating volume group backup "/etc/lvm/backup/vgrp0" (seqno 6).
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvs -o+pv_used
  PV         VG    Fmt  Attr PSize  PFree  Used
  /dev/md127 vgrp0 lvm2 a--  64.00g     0  64.00g
  /dev/xvdb1 vgrp0 lvm2 a--  64.00g 64.00g     0
[root@lvm-test-server ~]#
```

PFreeになっていることを確認

```
[root@lvm-test-server ~]# vgdisplay
  --- Volume group ---
  VG Name               vgrp0
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  6
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               127.99 GiB
  PE Size               4.00 MiB
  Total PE              32766
  Alloc PE / Size       16383 / 64.00 GiB
  Free  PE / Size       16383 / 64.00 GiB
  VG UUID               x6y3NX-WNwZ-8pOj-Ez0S-U7r4-fice-9CljNP

[root@lvm-test-server ~]#
```

### xvdb1をVGから切り離す

```
[root@lvm-test-server ~]# vgreduce vgrp0 /dev/xvdb1
  Removed "/dev/xvdb1" from volume group "vgrp0"
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgdisplay
  --- Volume group ---
  VG Name               vgrp0
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  7
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               64.00 GiB
  PE Size               4.00 MiB
  Total PE              16383
  Alloc PE / Size       16383 / 64.00 GiB
  Free  PE / Size       0 / 0
  VG UUID               x6y3NX-WNwZ-8pOj-Ez0S-U7r4-fice-9CljNP

[root@lvm-test-server ~]#
```

Allocサイズが変わっていることを確認。  
この後はPVを削除してEBSをデタッチすればデータの移設が完了します。
