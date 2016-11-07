---
layout: post
title: "EC2のインスタンスが立ち上がってきた時にEphemeral Diskを束ねてRAID0にするスクリプト"
published: true
date: "2014-02-24T18:15:00+09:00"
comments: true


---

Ephemeral Diskが8本ある場合は条件を増やせば良い。  

```
#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin:/usr/local/bin

if [[ \`test -e /dev/xvdc ; echo \$?\` -eq 0 ]] ; then
    if [[ \`test -e /dev/xvde ; echo \$?\` -eq 0 ]] ; then

        # RAID用のファイルをつくる(ephemeral x4バージョン)
        umount /media/ephemeral0
        yes | mdadm --create /dev/md127 --level=0 --raid-devices=4 /dev/xvd[bcde]
        mkfs.ext4 /dev/md127
        mount /dev/md127 /media/ephemeral0
    else

        # RAID用のファイルをつくる(ephemeral x2バージョン)
        umount /media/ephemeral0
        yes | mdadm --create /dev/md127 --level=0 --raid-devices=2 /dev/xvd[bc]
        mkfs.ext4 /dev/md127
        mount /dev/md127 /media/ephemeral0
    fi
fi
```

このスクリプトを`rc.local`とか`/etc/rc3.d/S~`とかに置いておけば  
起動時にRAID0として束ねて立ち上がってくれる。  
  
> このクールなアイデアは自分発のものではない
