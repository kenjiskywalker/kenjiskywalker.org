---
layout: post
title: "LVM入門"
published: true
date: "2014-01-11T11:39:00+09:00"
comments: true


---

LVMについては、きちんと学習したことがなかったので  
今回改めて学習した内容をまとめました。  

## 参考
- [redhat カスタマーポータル - Red Hat Enterprise Linux 6 論理ボリュームマネージャの管理](https://access.redhat.com/site/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html-single/Logical_Volume_Manager_Administration/)
- [it-資格.jp - LPIC対策](http://www2.it-shikaku.jp/top30.php?hidari=201-04-03.php&migi=km201-04.php&title=204.3%20%E8%AB%96%E7%90%86%E3%83%9C%E3%83%AA%E3%83%A5%E3%83%BC%E3%83%A0%E3%83%9E%E3%83%8D%E3%83%BC%E3%82%B8%E3%83%A3)
- [Pantora Networks - 2章 LVM操作 基本編](http://pantora.net/pages/lvm/2/)

## わかりやすかったRedhat社のLVM解説図

![https://access.redhat.com/site/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html-single/Logical_Volume_Manager_Administration/images/overview/basic-lvm-volume.png](https://access.redhat.com/site/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html-single/Logical_Volume_Manager_Administration/images/overview/basic-lvm-volume.png)

### 取り敢えずざっくりと

PV = 物理ディスク  
VG = PVを束ねたもの。VGを利用して複数のディスクをまたいで利用できる  
LV = VGの中から指定したディスクサイズを仮想ディスクとして利用できる


## 検証環境

```
- ルートパーティション
/dev/xvda1 16GB 

- 元々存在していたと仮定するディスク
/dev/xvdb  64GB EBS

- RAID0用のディスク
/dev/xvdc  16GB EBS
/dev/xvdd  16GB EBS
/dev/xvde  16GB EBS
/dev/xvdf  16GB EBS
```


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

## PV 

### PVの作成(pvcreate)

```
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# fdisk /dev/xvdb
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0x64007579.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-8354, default 1):
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-8354, default 8354):
Using default value 8354

Command (m for help): t
Selected partition 1
Hex code (type L to list codes): L

 0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris
 1  FAT12           39  Plan 9          82  Linux swap / So c1  DRDOS/sec (FAT-
 2  XENIX root      3c  PartitionMagic  83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       40  Venix 80286     84  OS/2 hidden C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      41  PPC PReP Boot   85  Linux extended  c7  Syrinx
 5  Extended        42  SFS             86  NTFS volume set da  Non-FS data
 6  FAT16           4d  QNX4.x          87  NTFS volume set db  CP/M / CTOS / .
 7  HPFS/NTFS       4e  QNX4.x 2nd part 88  Linux plaintext de  Dell Utility
 8  AIX             4f  QNX4.x 3rd part 8e  Linux LVM       df  BootIt
 9  AIX bootable    50  OnTrack DM      93  Amoeba          e1  DOS access
 a  OS/2 Boot Manag 51  OnTrack DM6 Aux 94  Amoeba BBT      e3  DOS R/O
 b  W95 FAT32       52  CP/M            9f  BSD/OS          e4  SpeedStor
 c  W95 FAT32 (LBA) 53  OnTrack DM6 Aux a0  IBM Thinkpad hi eb  BeOS fs
 e  W95 FAT16 (LBA) 54  OnTrackDM6      a5  FreeBSD         ee  GPT
 f  W95 Ext'd (LBA) 55  EZ-Drive        a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            56  Golden Bow      a7  NeXTSTEP        f0  Linux/PA-RISC b
11  Hidden FAT12    5c  Priam Edisk     a8  Darwin UFS      f1  SpeedStor
12  Compaq diagnost 61  SpeedStor       a9  NetBSD          f4  SpeedStor
14  Hidden FAT16 <3 63  GNU HURD or Sys ab  Darwin boot     f2  DOS secondary
16  Hidden FAT16    64  Novell Netware  af  HFS / HFS+      fb  VMware VMFS
17  Hidden HPFS/NTF 65  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE
18  AST SmartSleep  70  DiskSecure Mult b8  BSDI swap       fd  Linux raid auto
1b  Hidden W95 FAT3 75  PC/IX           bb  Boot Wizard hid fe  LANstep
1c  Hidden W95 FAT3 80  Old Minix       be  Solaris boot    ff  BBT
1e  Hidden W95 FAT1
Hex code (type L to list codes): 8e
Changed system type of partition 1 to 8e (Linux LVM)

Command (m for help): p

Disk /dev/xvdb: 68.7 GB, 68719476736 bytes
255 heads, 63 sectors/track, 8354 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x64007579

    Device Boot      Start         End      Blocks   Id  System
/dev/xvdb1               1        8354    67103473+  8e  Linux LVM

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvdisplay
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvcreate /dev/xvdb1
  Physical volume "/dev/xvdb1" successfully created
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvdisplay
  "/dev/sdb1" is a new physical volume of "63.99 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb1
  VG Name
  PV Size               63.99 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               gyJLPn-FMuy-0b9h-yeYN-6AB2-OFTj-pQLh5W

[root@lvm-test-server ~]# pvdisplay -c
  "/dev/sdb1" is a new physical volume of "63.99 GiB"
  /dev/sdb1:#orphans_lvm2:134206947:-1:8:8:-1:0:0:0:0:gyJLPn-FMuy-0b9h-yeYN-6AB2-OFTj-pQLh5W
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvdisplay -C
  PV         VG   Fmt  Attr PSize  PFree
  /dev/sdb1       lvm2 a--  63.99g 63.99g
[root@lvm-test-server ~]#
```

パーティションではなくディスク全体をPVにすることも可能

```
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvcreate /dev/xvdb
  Physical volume "/dev/xvdb" successfully created
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvdisplay -c
  "/dev/sdb" is a new physical volume of "64.00 GiB"
  /dev/sdb:#orphans_lvm2:134217728:-1:8:8:-1:0:0:0:0:99H0KX-HZSK-IYfI-j1Mn-KjLf-UlIz-ZNRANd
[root@lvm-test-server ~]# pvdisplay -C
  PV         VG   Fmt  Attr PSize  PFree
  /dev/sdb        lvm2 a--  64.00g 64.00g
[root@lvm-test-server ~]# pvdisplay
  "/dev/sdb" is a new physical volume of "64.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               64.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               99H0KX-HZSK-IYfI-j1Mn-KjLf-UlIz-ZNRANd

[root@lvm-test-server ~]#
```

### PVの削除(pvremove)

```
[root@lvm-test-server ~]# pvremove /dev/xvdb
  Labels on physical volume "/dev/xvdb" successfully wiped
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvdisplay
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
```


## VG

### VGの作成(vgcreate)

```
[root@lvm-test-server ~]# vgcreate vgrp0 /dev/xvdb
  Volume group "vgrp0" successfully created
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgdisplay -c
  vgrp0:r/w:772:-1:0:0:0:-1:0:1:1:67104768:4096:16383:0:16383:spCzJn-CU9u-Fim0-Zonl-Lr0v-8ADc-elBfk5
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgdisplay -C
  VG    #PV #LV #SN Attr   VSize  VFree
  vgrp0   1   0   0 wz--n- 64.00g 64.00g
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgdisplay
  --- Volume group ---
  VG Name               vgrp0
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               64.00 GiB
  PE Size               4.00 MiB
  Total PE              16383
  Alloc PE / Size       0 / 0
  Free  PE / Size       16383 / 64.00 GiB
  VG UUID               spCzJn-CU9u-Fim0-Zonl-Lr0v-8ADc-elBfk5

[root@lvm-test-server ~]#
```


### VGの削除(vgremove)

```
[root@lvm-test-server ~]# vgremove vgrp0
  Volume group "vgrp0" successfully removed
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgdisplay
  No volume groups found
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
```

### パーティション毎にPVを複数作成してVGにまとめる(vgcreate)

#### パーティション毎にPVを作成する

```
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# fdisk /dev/xvdb
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0x7224e6ea.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').

...

Command (m for help): p

Disk /dev/xvdb: 68.7 GB, 68719476736 bytes
255 heads, 63 sectors/track, 8354 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x7224e6ea

    Device Boot      Start         End      Blocks   Id  System
/dev/xvdb1               1        3917    31463271   8e  Linux LVM
/dev/xvdb2            3918        8354    35640202+  8e  Linux LVM

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvcreate /dev/xvdb1 /dev/xvdb2
  Physical volume "/dev/sdb1" successfully created
  Physical volume "/dev/sdb2" successfully created
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvdisplay
  "/dev/sdb1" is a new physical volume of "30.01 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb1
  VG Name
  PV Size               30.01 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               mizQ5k-ln0l-X9SS-2Hbd-QqUj-ZpSY-PsGQPa

  "/dev/sdb2" is a new physical volume of "33.99 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb2
  VG Name
  PV Size               33.99 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               LyAp4h-fQtA-30vD-u2jb-3PSt-oaEk-W6nowQ

[root@lvm-test-server ~]#
```


#### 複数のPVをVGにまとめる

```
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgcreate vgrp0 /dev/sdb1 /dev/sdb2
  Volume group "vgrp0" successfully created
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgdisplay
  --- Volume group ---
  VG Name               vgrp0
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
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
  VG UUID               HMii83-udZK-dNPR-7O7p-ybOC-8XeX-9eITD0

[root@lvm-test-server ~]#
```


### 既存のVGにPVを追加(vgextend)

```
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgremove vgrp0
  Volume group "vgrp0" successfully removed
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgdisplay
  No volume groups found
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgcreate vgrp0 /dev/sdb1
  Volume group "vgrp0" successfully created
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgdisplay
  --- Volume group ---
  VG Name               vgrp0
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               30.00 GiB
  PE Size               4.00 MiB
  Total PE              7681
  Alloc PE / Size       0 / 0
  Free  PE / Size       7681 / 30.00 GiB
  VG UUID               j4hcOI-hsYy-j8jL-Dnp7-wa44-ue4c-ZlMi5m

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgextend vgrp0 /dev/sdb2
  Volume group "vgrp0" successfully extended
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
```

### 既存のVGからPVを切り離す(vgreduce)

```
[root@lvm-test-server ~]# pvremove /dev/sdb2
  PV /dev/sdb2 belongs to Volume Group vgrp0 so please use vgreduce first.
  (If you are certain you need pvremove, then confirm by using --force twice.)
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgreduce vgrp0 /dev/sdb2
  Removed "/dev/sdb2" from volume group "vgrp0"
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# vgdisplay
  --- Volume group ---
  VG Name               vgrp0
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  9
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               30.00 GiB
  PE Size               4.00 MiB
  Total PE              7681
  Alloc PE / Size       0 / 0
  Free  PE / Size       7681 / 30.00 GiB
  VG UUID               j4hcOI-hsYy-j8jL-Dnp7-wa44-ue4c-ZlMi5m

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sdb1
  VG Name               vgrp0
  PV Size               30.01 GiB / not usable 1.85 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              7681
  Free PE               7681
  Allocated PE          0
  PV UUID               mizQ5k-ln0l-X9SS-2Hbd-QqUj-ZpSY-PsGQPa

  "/dev/sdb2" is a new physical volume of "33.99 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb2
  VG Name
  PV Size               33.99 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               LyAp4h-fQtA-30vD-u2jb-3PSt-oaEk-W6nowQ

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvremove /dev/sdb2
  Labels on physical volume "/dev/sdb2" successfully wiped
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sdb1
  VG Name               vgrp0
  PV Size               30.01 GiB / not usable 1.85 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              7681
  Free PE               7681
  Allocated PE          0
  PV UUID               mizQ5k-ln0l-X9SS-2Hbd-QqUj-ZpSY-PsGQPa

[root@lvm-test-server ~]#
```


## LV


### LVの作成

```
[root@lvm-test-server ~]# lvcreate vgrp0
  Please specify either size or extents
  Run `lvcreate --help' for more information.
[root@lvm-test-server ~]#

サイズ指定しないと怒られる

[root@lvm-test-server ~]# lvcreate -L 10G -n lvol0 vgrp0
  Logical volume "lvol0" created
[root@lvm-test-server ~]#

100%使い切る場合にはこれ

[root@lvm-test-server ~]# lvcreate -l 100%FREE -n lvol0 vgrp0
  Logical volume "lvol0" created
[root@lvm-test-server ~]#

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# lvdisplay -c
  /dev/vgrp0/lvol0:vgrp0:3:1:-1:0:20971520:2560:-1:0:-1:253:0
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# lvdisplay -C
  LV    VG    Attr      LSize  Pool Origin Data%  Move Log Cpy%Sync Convert
  lvol0 vgrp0 -wi-a---- 10.00g
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/vgrp0/lvol0
  LV Name                lvol0
  VG Name                vgrp0
  LV UUID                4VNA2l-dgiU-p36w-kfS8-HP7P-eIfy-nfaPe4
  LV Write Access        read/write
  LV Creation host, time lvm-test-server, 2014-01-07 08:16:54 +0000
  LV Status              available
  # open                 0
  LV Size                10.00 GiB
  Current LE             2560
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

[root@lvm-test-server ~]#
```

### LVをmountする

```
[root@lvm-test-server ~]# mkfs.ext4 /dev/vgrp0/lvol0
mke2fs 1.42.3 (14-May-2012)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
655360 inodes, 2621440 blocks
131072 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2684354560
80 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# mount /dev/vgrp0/lvol0 /mnt
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/xvda1             16G  2.9G   13G  19% /
tmpfs                 1.9G     0  1.9G   0% /dev/shm
/dev/mapper/vgrp0-lvol0
                      9.9G  151M  9.2G   2% /mnt
[root@lvm-test-server ~]#
```

### LVを拡張する(lvextend)

```
[root@lvm-test-server ~]# lvcreate -L 10G vgrp0
  Logical volume "lvol1" created
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/vgrp0/lvol0
  LV Name                lvol0
  VG Name                vgrp0
  LV UUID                4VNA2l-dgiU-p36w-kfS8-HP7P-eIfy-nfaPe4
  LV Write Access        read/write
  LV Creation host, time lvm-test-server, 2014-01-07 08:16:54 +0000
  LV Status              available
  # open                 1
  LV Size                10.00 GiB
  Current LE             2560
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# lvextend -L +10G /dev/vgrp0/lvol0
  Extending logical volume lvol0 to 20.00 GiB
  Logical volume lvol0 successfully resized
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/vgrp0/lvol0
  LV Name                lvol0
  VG Name                vgrp0
  LV UUID                4VNA2l-dgiU-p36w-kfS8-HP7P-eIfy-nfaPe4
  LV Write Access        read/write
  LV Creation host, time lvm-test-server, 2014-01-07 08:16:54 +0000
  LV Status              available
  # open                 1
  LV Size                20.00 GiB
  Current LE             5120
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/xvda1             16G  2.9G   13G  19% /
tmpfs                 1.9G     0  1.9G   0% /dev/shm
/dev/mapper/vgrp0-lvol0
                      9.9G  151M  9.2G   2% /mnt
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
```


ext3の場合は`ext2online /dev/testvg/LVName`


```
[root@lvm-test-server ~]# resize2fs /dev/vgrp0/lvol0
resize2fs 1.42.3 (14-May-2012)
Filesystem at /dev/vgrp0/lvol0 is mounted on /mnt; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/vgrp0/lvol0 is now 5242880 blocks long.

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/xvda1             16G  2.9G   13G  19% /
tmpfs                 1.9G     0  1.9G   0% /dev/shm
/dev/mapper/vgrp0-lvol0
                       20G  156M   19G   1% /mnt
[root@lvm-test-server ~]#
```

### LVを減少(lvextend)

```
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# umount /mnt
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# df
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/xvda1            16513960   2980776  13365588  19% /
tmpfs                  1922292         0   1922292   0% /dev/shm
[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# resize2fs /dev/vgrp0/lvol0 10G
resize2fs 1.42.3 (14-May-2012)
Please run 'e2fsck -f /dev/vgrp0/lvol0' first.

[root@lvm-test-server ~]# e2fsck -f /dev/vgrp0/lvol0
e2fsck 1.42.3 (14-May-2012)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/vgrp0/lvol0: 11/1310720 files (0.0% non-contiguous), 122065/5242880 blocks
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# resize2fs /dev/vgrp0/lvol0 10G
resize2fs 1.42.3 (14-May-2012)
Resizing the filesystem on /dev/vgrp0/lvol0 to 2621440 (4k) blocks.
The filesystem on /dev/vgrp0/lvol0 is now 2621440 blocks long.

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/vgrp0/lvol0
  LV Name                lvol0
  VG Name                vgrp0
  LV UUID                4VNA2l-dgiU-p36w-kfS8-HP7P-eIfy-nfaPe4
  LV Write Access        read/write
  LV Creation host, time lvm-test-server, 2014-01-07 08:16:54 +0000
  LV Status              available
  # open                 0
  LV Size                20.00 GiB
  Current LE             5120
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

[root@lvm-test-server ~]#
[root@lvm-test-server ~]# lvreduce -L -10G /dev/vgrp0/lvol0
  WARNING: Reducing active logical volume to 10.00 GiB
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce lvol0? [y/n]: y
  Reducing logical volume lvol0 to 10.00 GiB
  Logical volume lvol0 successfully resized
[root@lvm-test-server ~]#
[root@lvm-test-server ~]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/vgrp0/lvol0
  LV Name                lvol0
  VG Name                vgrp0
  LV UUID                4VNA2l-dgiU-p36w-kfS8-HP7P-eIfy-nfaPe4
  LV Write Access        read/write
  LV Creation host, time lvm-test-server, 2014-01-07 08:16:54 +0000
  LV Status              available
  # open                 0
  LV Size                10.00 GiB
  Current LE             2560
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

[root@lvm-test-server ~]#
[root@lvm-test-server ~]#
```



