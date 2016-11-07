---
layout: post
title: "自宅ルータをVyattaにして快適になった"
published: true
date: "2013-09-10T23:39:00+09:00"
comments: true


---

市販のルータ兼無線アクセスポイント君が  
2日に1回再起動しないとAirPlayできなくなってしまったので  
この際自宅のネットワーク環境を一新すべく  
Vyattaを導入した。その際のメモ。

#### 参考URL
- [自宅ルータをVyattaに移行しました - IT 東京 楽しいと思うこと](http://d.hatena.ne.jp/mikeda/20120331/1333172105)
- [Vyatta_QuickStart_R6.1_v02_1.pdf](http://www.vyatta.com//sites/vyatta.com/files/pdfs/Vyatta_QuickStart_R6.1_v02_1.pdf)


## 環境

- Ubuntu: 12.04.3 LTS (KVM HOST)
- Vyatta: VC6.6R1


## ネットワーク

![https://dl.dropboxusercontent.com/u/5390179/Network_diagram.png](https://dl.dropboxusercontent.com/u/5390179/Network_diagram.png)

## 買ったもの

追加NIC用に「Intel Gigabit CT Desktop Adapter EXPI9301CT」  
<a href="http://www.amazon.co.jp/gp/product/B001CXWWBE/ref=as_li_ss_il?ie=UTF8&camp=247&creative=7399&creativeASIN=B001CXWWBE&linkCode=as2&tag=13nightcrows-22"><img border="0" src="http://ws-fe.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B001CXWWBE&Format=_SL110_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=13nightcrows-22" ></a><img src="http://ir-jp.amazon-adsystem.com/e/ir?t=13nightcrows-22&l=as2&o=9&a=B001CXWWBE" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

---

無線LAN用に「PLANEX FFP-PKA04D」  
<a href="http://www.amazon.co.jp/gp/product/B005GHZ1GU/ref=as_li_ss_il?ie=UTF8&camp=247&creative=7399&creativeASIN=B005GHZ1GU&linkCode=as2&tag=13nightcrows-22"><img border="0" src="http://ws-fe.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B005GHZ1GU&Format=_SL110_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=13nightcrows-22" ></a><img src="http://ir-jp.amazon-adsystem.com/e/ir?t=13nightcrows-22&l=as2&o=9&a=B005GHZ1GU" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
  
---

スイッチは前職で頂いた8ポートのスイッチングハブを利用


# 構築

### ブリッジのインタフェースを２つつくる


- eth0 Internal
- eth1 External

### /etc/network/interfaces

```
auto lo
iface lo inet loopback

iface eth0 inet manual
iface eth1 inet manual

auto br0
iface br0 inet static
        address 192.168.0.3
        network 192.168.0.0
        netmask 255.255.255.0
        broadcast 192.168.0.255
        gateway 192.168.0.1
        bridge_ports eth0
        bridge_stp off
        bridge_fd 0
        bridge_maxwait 0
        dns-nameservers 192.168.0.1

auto br1
iface br1 inet static
        address 0.0.0.0
        bridge_ports eth1
        bridge_stp off
        bridge_fd 0
        bridge_maxwait 0
```

気が付いたらvnetがアサインされていた。
ここらへんまだ理解していない。

### brctl show

```
bridge name     bridge id               STP enabled     interfaces
br0             8000.20cf30ea8178       no              eth0
br0             8000.XXXXXXXXXXXX       no              eth0
                                                        vnet0
                                                        vnet1
                                                        vnet2
br1             8000.XXXXXXXXXXXX       no              eth1
                                                        vnet3
lxcbr0          8000.000000000000       no
```


### VyattaのISOファイルを落としてくる

```
$ curl -O http://www.vyatta.com/downloads/vc6.6/vyatta-livecd_VC6.6R1_amd64.iso
```


### Vyatta用のディスクイメージを作成する

```
$ qemu-img create -f raw /var/lib/libvirt/images/vyatta01-2G.img 2G
```


### KVMでインストールする

```
$ virt-install  --connect qemu:///system  \
--name vyatta01 \
--ram 512  \
--vcpus=1  \
--disk path=/var/lib/libvirt/images/vyatta01-2G.img \
--nographics  \
--network=bridge:br0 --network=bridge:br1 \
--cdrom=/tmp/vyatta-livecd_VC6.6R1_amd64.iso
```

Install Default setting

- login: vyatta
- Password: vyatta

```

$ virsh console Vyatta01


boot:

Welcome to Vyatta - vyatta ttyS0

vyatta login: vyatta
Password:
Linux vyatta 3.3.8-1-amd64-vyatta #1 SMP Wed Mar 13 10:35:28 PDT 2013 x86_64
Welcome to Vyatta.
This system is open-source software. The exact distribution terms for
each module comprising the full system are described in the individual
files in /usr/share/doc/*/copyright.

vyatta@vyatta:~$ install image
Welcome to the Vyatta install program.  This script
will walk you through the process of installing the
Vyatta image to a local hard drive.
Would you like to continue? (Yes/No) [Yes]:
Probing drives: OK
Looking for pre-existing RAID groups...none found.
The Vyatta image will require a minimum 1000MB root.
Would you like me to try to partition a drive automatically
or would you rather partition it manually with parted?  If
you have already setup your partitions, you may skip this step

Partition (Auto/Parted/Skip) [Auto]:
```

のようにインストールがはじまります。  
基本的にチュートリアルに乗って行けば問題ないかと。

新しいパスワードを設定して、再起動

```
This will destroy all data on /dev/sda.
Continue? (Yes/No) [No]: yes

Enter password for administrator account
Enter vyatta password:
Retype vyatta password:
```


```
vyatta@vyatta:~$ reboot now
```

## vyattaの設定

Vyattaは他のネットワーク機器と同じように  
`set`, `show`, `delete` で全て行うことができる。  
  
- setで値を設定し
- showで確認
- 間違っていればdeleteで削除
- テストを行い、問題がなければcommit
- 永続的に設定を保持するためにsave

という一連のサイクルで設定を行う。


### Vyattaの内部IPを設定

```
# set interfaces ethernet eth0 address 192.168.0.1/24
```

### SSHの許可

```
# set service ssh listen-address 192.168.0.1
```

### ISPと接続

```
# set interfaces ethernet eth0 pppoe 0 user-id XXXXX@YYY.ZZZ
# set interfaces ethernet eth0 pppoe 0 password XXXXX
# set interfaces ethernet eth0 pppoe 0 default-route auto
# commit
# save
```

この時点で外部との接続が可能

```
$ ping 8.8.8.8 
```

などで pppoe0 => internet の疎通確認を行う


### マスカレードの設定

```
# set nat source rule 1 source address 192.168.0.0/24
# set nat source rule 1 outbound-interface pppoe0
# set nat source rule 1 translation address masquerade
```

試しにクライアントPCを  

- IP: 192.168.0.100
- NETWORK: 255.255.255.0/24
- GATEWAY: 192.168.0.1

と設定して、外部に疎通ができるか確認する。疎通ができればまずはOK。


### SSHを許可する

`ssh 192.168.0.1 -l vyatta` などとしてSSHで接続してみる

### DHCPを振る

DHCPで192.168.0.200から192.168.0.250までの  
IPアドレスを割り振るように設定。

```
# set service dhcp-server shared-network-name vyatta subnet 192.168.0.0/24 start 192.168.0.200 stop 192.168.0.250
# set service dhcp-server shared-network-name vyatta subnet 192.168.0.0/24 default-router 192.168.0.1
# set service dhcp-server shared-network-name vyatta subnet 192.168.0.0/24 dns-server NTT DNS SERVER
# set service dhcp-server shared-network-name vyatta subnet 192.168.0.0/24 dns-server NTT DNS SERVER
```

ここでハマったのが、PLANEXでもDHCPを振っていたせいで  
DHCPでIPを付与されたクライアントPCのGATEWAYが  
PLANEXを見に行ってしまっていていた。  

PLANEXの方のDHCP機能を無効化することで解決。  
しかし今度はPLANEXの方の管理画面に入れなくなってて放置してる。


### Vyatta 6.6で画像が表示されない

[Vyatta 6.6 画像が表示されない。 / 題名のないBlog（ｒｙ](http://speed47.com/adiary/adiary.cgi/0145)

画像が永遠に読み込めない不具合があるので下記設定を導入

```
set policy route PPPOE-IN rule 10 destination address 0.0.0.0/0
set policy route PPPOE-IN rule 10 protocol tcp
set policy route PPPOE-IN rule 10 tcp flags 'SYN,!ACK,!FIN,!RST'
set policy route PPPOE-IN rule 10 set tcp-mss 1360

set interfaces ethernet eth0 policy route PPPOE-IN
```

### ポートフォワーディング

外部からアクセスできるようにフォワードする

```
set nat destination rule 1000 inbound-interface pppoe0
set nat destination rule 1000 destination port 22
set nat destination rule 1000 protocol tcp
set nat destination rule 1000 translation port 22
set nat destination rule 1000 translation address 192.168.0.11
```

```
set nat destination rule 1001 inbound-interface pppoe0
set nat destination rule 1001 destination port 60000-61000
set nat destination rule 1001 protocol tcp_udp
set nat destination rule 1001 translation port 60000-61000
set nat destination rule 1001 translation address 192.168.0.12
```

こんな感じでつらつらと設定していく


### まとめ

ISPと接続してIPマスカレードができてDHCPが振れて  
ポートフォワーディングができるVyatta最高です。  
  
設定変更する度に回線切れて60秒待つとかいう苦行もなくなったし  
AirPlay毎日できて最高です。  
  
興味があれば、まずquick startのPDFだけでも見てみるといいかもです。  
@mikedaさんも書かれていますが、上記設定をするだけなら簡単にできます。  
  
よかったらお試しください。
