---
layout: post
title: "Ubuntu 13.10でOMRONのUPS BY35Sを使う"
published: true
date: "2014-02-02T11:53:00+09:00"
comments: true


keywords: omron ubuntu nut 
---

> Ubuntu 13.04
> nut        2.6.4-2.2ubuntu1  
> nut-client 2.6.4-2.2ubuntu1  
> nut-server 2.6.4-2.2ubuntu1

<a href="http://www.amazon.co.jp/gp/product/B002UQFAPW/ref=as_li_ss_il?ie=UTF8&camp=247&creative=7399&creativeASIN=B002UQFAPW&linkCode=as2&tag=13nightcrows-22"><img border="0" src="http://ws-fe.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B002UQFAPW&Format=_SL110_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=13nightcrows-22" ></a><img src="http://ir-jp.amazon-adsystem.com/e/ir?t=13nightcrows-22&l=as2&o=9&a=B002UQFAPW" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

[OMRON の UPS BY35S を Linux と使う - 酒日記はてな支店](http://d.hatena.ne.jp/sfujiwara/20110216/1297867818)  

家のブレーカーがバシバシ落ちるのでfujiwaraさんおすすめのUPSを買った。  
SSSを使いたかったけどDebian系はフォローしてなかったので[Network UPS Tools](http://www.networkupstools.org/)を利用した。

### 設定参考

[OMRON BY50SをUbuntu 11.04で使用する](http://sunnyone41.blogspot.jp/2011/05/omron-by50subuntu-1104.html)  
[Configuring NUT for the Eaton 3S UPS on Ubuntu Linux](http://srackham.wordpress.com/2013/02/27/configuring-nut-for-the-eaton-3s-ups-on-ubuntu-linux/)

### 作業内容

1. BY35Sの電源入れる
2. BY35Sからサーバの電源を取る
3. BY35SとサーバをUSBでつなぐ。



#### サーバにて

```
# apt-get install nut
```

nut-clientとnut-serverがインストールされる。

```
$ lsusb | grep -i omron
Bus 002 Device 006: ID 0590:0080 Omron Corp.
$
$ lsusb -v -s 002:006

Bus 002 Device 006: ID 0590:0080 Omron Corp.
Couldn't open device, some information will be missing
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               1.10
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0         8
  idVendor           0x0590 Omron Corp.
  idProduct          0x0080
  bcdDevice            1.08
  iManufacturer           3
  iProduct                1
  iSerial                 0
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           34
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0
    bmAttributes         0xe0
      Self Powered
      Remote Wakeup
    MaxPower              100mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           1
      bInterfaceClass         3 Human Interface Device
      bInterfaceSubClass      0 No Subclass
      bInterfaceProtocol      0 None
      iInterface              0
        HID Device Descriptor:
          bLength                 9
          bDescriptorType        33
          bcdHID               1.11
          bCountryCode            0 Not supported
          bNumDescriptors         1
          bDescriptorType        34 Report
          wDescriptorLength      27
         Report Descriptors:
           ** UNAVAILABLE **
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0008  1x 8 bytes
        bInterval              10
$
```
idVendorとidProductをメモしておく

```
# diff -C0 /lib/udev/rules.d/.52-nut-usbups.rules /lib/udev/rules.d/52-nut-usbups.rules
*** /lib/udev/rules.d/.52-nut-usbups.rules      2014-02-01 22:23:17.624993312 +0900
--- /lib/udev/rules.d/52-nut-usbups.rules       2014-02-02 00:27:37.540750650 +0900
***************
*** 205 ****
--- 206,208 ----
+ # omron UPS BY35S - blazer_usb
+ ATTR{idVendor}=="0590", ATTR{idProduct}=="0080", MODE="664", GROUP="nut"
+
```

メモした内容を`/lib/udev/rules.d/52-nut-usbups.rules`に追記する。


#### nut.conf

```
MODE=standalone
```

#### ups.conf

```
[ups]
     driver    = blazer_usb
     port      = auto
     vendorid  = 0590
     productid = 0080
     subdriver = ippon
```

#### upsd.users

```
        [upsmon]
                password  = pass
                upsmon master
```


#### upsmon.conf

```
RUN_AS_USER root
MONITOR ups@localhost 1 upsmon pass master
MINSUPPLIES 1
SHUTDOWNCMD "/sbin/shutdown -h +0"
NOTIFYCMD "/etc/nut/notifycmd"
POLLFREQ 5
POLLFREQALERT 5
HOSTSYNC 15
DEADTIME 15
POWERDOWNFLAG /etc/killpower
NOTIFYFLAG ONLINE       SYSLOG+WALL+EXEC
NOTIFYFLAG ONBATT       SYSLOG+WALL+EXEC
NOTIFYFLAG LOWBATT      SYSLOG+WALL+EXEC
NOTIFYFLAG FSD          SYSLOG+WALL+EXEC
NOTIFYFLAG COMMOK       SYSLOG+WALL+EXEC
NOTIFYFLAG COMMBAD      SYSLOG+WALL+EXEC
NOTIFYFLAG SHUTDOWN     SYSLOG+WALL+EXEC
NOTIFYFLAG REPLBATT     SYSLOG+WALL+EXEC
NOTIFYFLAG NOCOMM       SYSLOG+WALL+EXEC
NOTIFYFLAG NOPARENT     SYSLOG+WALL+EXEC
RBWARNTIME 43200
NOCOMMWARNTIME 300
FINALDELAY 5
```

#### notifycmd

vmのシャットダウンはfujiwaraさんのを丸コピ

```
#!/bin/bash
#
# NUT NOTIFYCMD script

PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin

LANG=C
export LANG

trap "exit 0" SIGTERM

if [ "$NOTIFYTYPE" = "ONLINE" ]
then
        echo $0: power restored | wall
        # Cause all instances of this script to exit.
        killall -s SIGTERM `basename $0`
fi

if [ "$NOTIFYTYPE" = "ONBATT" ]
then
        echo $0: 5 minutes till system powers down... | wall
        # Loop with one second interval to allow SIGTERM reception.
        let "n = 300"
        while [ $n -ne 0 ]
        do
                sleep 1
                let "n--"
        done

        echo $0: vm shutdown | wall
        VM=`/usr/bin/virsh list --all | grep 'running$' | awk '{print $2}'`
        for v in $VM
        do
            echo $0: shutdown virtual machine $v | wall
            virsh shutdown $v
        done

        echo $0: commencing shutdown | wall
        upsmon -c fsd
fi
```


#### nut start

```
# /etc/init.d/nut-client start
# /etc/init.d/nut-server start
#
# upsc ups
battery.voltage: 13.50
battery.voltage.high: -1.08
battery.voltage.low: -0.87
device.type: ups
driver.name: blazer_usb
driver.parameter.pollinterval: 2
driver.parameter.port: auto
driver.parameter.productid: 0080
driver.parameter.subdriver: ippon
driver.parameter.vendorid: 0590
driver.version: 2.6.4
driver.version.internal: 0.08
input.frequency: 49.9
input.voltage: 99.2
input.voltage.fault: 99.2
output.voltage: 98.9
ups.beeper.status: disabled
ups.delay.shutdown: 30
ups.delay.start: 180
ups.load: 29
ups.productid: 0080
ups.status: OL BYPASS
ups.temperature: 37.5
ups.type: offline / line interactive
ups.vendorid: 0590
#
#
# upsc ups ups.status
OL BYPASS
#
```

nut-serverも動かさないといけないのに気付かなくてハマってた。  

- バッテリー状態にして5分後にシャットダウンが実行される
- バッテリー状態にして商用電源を回復させてシャットダウンが停止される

ことを確認した。これでブレーカーが落ちても取り敢えずは大丈夫。  
ルーターとスイッチの電源もUPSから供給するようにしたら  
ネット越しに通知を受け取れるけど配線とか配置とかやり直さないといけないので  
元気があったらやりたい。元気があれば。
