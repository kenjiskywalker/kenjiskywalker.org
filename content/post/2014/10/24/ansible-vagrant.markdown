---
layout: post
title: "Ansibleを利用してRailsが動くVagrantfileを作成する"
published: true
date: "2014-10-24T05:56:00+09:00"
comments: true


---

![http://cdn2.hubspot.net/hub/330046/file-769078190-png/Official_Logos/ansible_wordlogo_whiteonblack_small.png?t=1414090782106](http://cdn2.hubspot.net/hub/330046/file-769078190-png/Official_Logos/ansible_wordlogo_whiteonblack_small.png?t=1414090782106)

## TL;DR

Ansibleを利用したからって複雑な処理がシンプルになるわけではない

### 1st

対象のサーバに何か設定をする必要はないので  
このように少量のコードでやりたいことが実現できる。

```
['-']%
['-']% cat hosts
ansible.example.com
['-']%
['-']% ansible -m ping -i hosts ansible.example.com
ansible.example.com | success >> {
    "changed": false,
    "ping": "pong"
}

['-']%
['-']% cat playbook.yml
- hosts: all

  tasks:
  - name: Install dstat
    yum: name=dstat
['-']%
['-']%
['-']% ansible-playbook -i hosts playbook.yml

PLAY [all] ********************************************************************

GATHERING FACTS ***************************************************************
ok: [ansible.example.com]

TASK: [Install dstat] *********************************************************
ok: [ansible.example.com]

PLAY RECAP ********************************************************************
ansible.example.com            : ok=2    changed=0    unreachable=0    failed=0

['-']%
```

Inventoryファイル(上記でいうとhostsファイル)の動的更新  
各社独自で工夫してるんだろうな...

## Role

1.2から使える機能とのこと、詳しくは  
[Playbook Roles and Include Statements](http://docs.ansible.com/playbooks_roles.html)を読んでもらいたい.  
Chefを利用している人は馴染みがあるというか  
そういう構成なのか、とすんなりと理解できると思う.  
  
Chefでいうcookbookの構成に近いというか  
Chefを意識したつくりになっている気がする.  
ある程度の規模になったらRoleを利用しないとつらいと思う.


## Railsの環境をAsibleで用意してみる

[https://github.com/kenjiskywalker/ansible](https://github.com/kenjiskywalker/ansible)  

```
['-']% tree .
.
├── dev.yml
└── roles
    ├── mysql
    │   └── tasks
    │       └── main.yml
    ├── rails
    │   └── tasks
    │       └── main.yml
    └── ruby
        ├── files
        ├── handlers
        ├── tasks
        │   ├── main.yml
        │   ├── rbenv.yml
        │   ├── ruby-build.yml
        │   └── ruby-install.yml
        └── templates
            └── rbenv.sh.j2

10 directories, 8 files
```

### 軽く書いてみて気がついたこと

- `command`がコマンドだけで`shell`がパイプも使えるとか気が付かなくてハマった
- `ohai`がいないので`apt`や`yum`など、ディストリビューションのパッケージ管理ツールを`package`みたいにラッピングしてくれない
- `register`の概念が面白かった

```
- name: check Rails installed
  shell: rails -v | cut -f 2 -d ' '
  register: rails_installed
  ignore_errors: yes
  tags:
    - ruby
    - ruby:install
    - install

- name: gem install rails -v {{ rails_version }}
  command: gem install rails -v {{ rails_version }}
  when: rails_installed.stdout != rails_version
  tags:
    - rails
    - install
```

のように書くと、`rails -v | cut -f 2 -d ' '`のコマンドの実行結果を  
`rails_installed`という変数に格納し、その変数を利用して  
条件分岐などを行うことができる.


### Vagrantfile

```
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos65"
  config.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"
  config.vm.define :"dev" do |dev|
    dev.vm.network :private_network, ip: '192.168.77.11'
  end
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "./ansible/dev.yml"
  end
end
```

このようにVagrantのprovisonerにansibleを利用することが可能です。  
READMEに書いてあるように、`vagrant up`を発行するとdev.ymlを利用した  
ansibleが実行されます.

```
$ vagrant provision
```

とコマンドを発行することで、実行中のVagrantのインスタンスに対して  
プロビジョニングすることが可能です。


### Chefの闇はAnsibleで光を得るのか

- 構成や管理方法が複雑であれば何を使ってもあまり変わらない
- 新しく覚える時間が許されるなら両方試してみれば良いのでは
- 上から下に実行されるだけ(ruby_blockとか使わなくていい)のは良い


### 個人的感想

- Ansible縛りでなければ[Itamae](https://github.com/ryotarai/itamae)試したかった
- まだちょっとしかさわってないので知見があればシェアさせて頂きます


## 参考

- [Playbook Roles and Include Statements - Ansible](http://docs.ansible.com/playbooks_roles.html)  
- [Best Practices - Ansible](http://docs.ansible.com/playbooks_best_practices.html)  
- [ansibleを使ってみる - そこはかとなく書くよん。](http://tdoc.info/blog/2013/04/20/ansible.html)  
