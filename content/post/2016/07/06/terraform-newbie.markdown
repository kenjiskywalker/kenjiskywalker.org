---
layout: post
title: "Terraformを始める上でのresourceの命名規則について"
published: true
date: "2016-07-06T09:52:00+09:00"
comments: true


---

## Terraformとは

[https://www.terraform.io](https://www.terraform.io)ここ見てください。  
`INFRASTRUCTURE AS CODE`と書いてあります。

## 何が便利か

たとえばAWSの新規VPCの作成など画面ポチポチで設定していくオペレーションをコードに落とせる。  

> それってAPI叩けば同じでは？  
PaaSが[色々](https://www.terraform.io/docs/providers/index.html)対応している。MySQLにも対応しているの...

## 伝えたいこと

たとえばVPCを構築するとして

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">Terraformの有識者にどうにかしてresourceの名前にvariableの値を入れる方法を教えてほしい🤔</p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/status/750200917312417792">July 5, 2016</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

```
resource "aws_vpc" "${var.prefix}-${var.environment_name}-vpc" {
    cidr_block           = "${var.vpc.cidr_block}"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
        "Name" = "${var.environment_name}-vpc"
    }
}
```

などと`resource`名をユニークな感じでやろうとしたのだけれど

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">so this is by design.と言われればそれまでだ <a href="https://t.co/Im2kwIqiQa">https://t.co/Im2kwIqiQa</a></p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/status/750218349884301313">July 5, 2016</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

`by design`と言われていたので、なんだか使いづらいな〜と考えていた。が

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">そもそもresourceは固有な名前を設定すべきではないという思想が理解できていなかった、例えばpublicであればfoo-development-publicなどとうい名前を付けるべきではなかった</p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/status/750243305481396224">July 5, 2016</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

そうなのだ。そもそもこの発想で良く、`resource`はあくまでTerraform内での管理するためだけの命名であるので

- vpc.tf

```
resource "aws_vpc" "main-vpc" {
    cidr_block           = "${var.vpc.cidr_block}"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
        "Name" = "${var.environment_name}-vpc"
    }
}
```

このように`Name Tags`でユニークな情報を付与すれば良かった。    
このことに気付かず`resource`にひたすら`variable`の値を入れようと頑張っていた。  
  
結局、上記のように`resource`にユニークな情報を入れない仕組みで汎用性は担保できた。  
これで似たような環境も

- vpc.tf

```
# Create Subnet
# - ec2:CreateSubnet
resource "aws_subnet" "some-subnet-a" {
    vpc_id            = "${aws_vpc.main-vpc.id}"
    cidr_block        = "${var.vpc.public_subnet_a}"
    availability_zone = "${var.availability_zone.a}"
    tags {
        Name = "${var.environment_name}-some-subnet-a"
    }
}
```

- variables.tf

```
variable "region" {
    default = "ap-northeast-1"
}

variable "environment_name" {
    default = "development"
}

variable "availability_zone" {
    default = {
        a = "ap-northeast-1a"
        c = "ap-northeast-1c"
    }
}

variable "vpc" {
    default = {
        cidr_block    = "10.200.0.0/16"
        some_subnet_a = "10.200.210.0/24"
        some_subnet_c = "10.200.211.0/24"
    }
}
```

上記のように`variables.tf`などと値を別のファイルに分けておくことで  
汎用的なテンプレートが作成可能となる。しかし便利だな〜






