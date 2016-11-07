---
layout: post
title: "EC2をTerminateした時にEBSも削除してほしい"
published: true
date: "2013-08-20T19:35:00+09:00"
comments: true


---

<blockquote class="twitter-tweet"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> DeleteOnTerminationをTrueにすると、Instance がTerminationしたときに一緒に消え去ってくれますよー</p>&mdash; con_mame (@con_mame) <a href="https://twitter.com/con_mame/statuses/369439049037017089">August 19, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>  
  
AWSで悩みがあったら大体@con_mameさんが解決してくれるんだ。  
お会いしたらbeerをおごりたい。  
  
[先日のAuto Scalingの検証時](http://blog.kenjiskywalker.org/blog/2013/08/14/aws-vpc-autoscaling/)に、インスタンスがTerminateされても  
利用されたEBSがうんちみたいに残ってしまうことがあった。  
  
残したくない場合は、AMI作成時に  

![https://dl.dropboxusercontent.com/u/5390179/ami_create.png](https://dl.dropboxusercontent.com/u/5390179/ami_create.png)  
  
上記のように`DeleteOnTermination`を有効化すれば良い。  
Auto Scalingで`DeleteOnTermination`を有効化したAMIを指定すれば  
EC2のインスタンスがTerminateされた時に、同時にEBSボリュームも削除してくれる。  
  
便利だ。
