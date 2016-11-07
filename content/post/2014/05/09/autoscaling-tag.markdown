---
layout: post
title: "AWSのAutoScalingGroupにタグを付けて起動されるEC2インスタンスにもタグが自動的に付与される"
published: true
date: "2014-05-09T18:00:00+09:00"
comments: true


---

[【AWS発表】オートスケールされたEC2インスタンスにタグ付け可能に - Amazon Web Services ブログ](http://aws.typepad.com/aws_japan/2014/05/tag-your-auto-scaled-ec2-instances.html)

こちらの便利機能が追加されたので早速設定してみました。

## [AWS CLI - create-or-update-tags](http://docs.aws.amazon.com/cli/latest/reference/autoscaling/create-or-update-tags.html)


> --tags ResourceId=string,ResourceType=string,Key=string,Value=string,PropagateAtLaunch=boolean

```
aws --region REGION autoscaling create-or-update-tags \
    --tags ResourceId=AUTOSCALINGGROUP_NAME, \
           ResourceType=auto-scaling-group, \
           Key=KEY, \
           Value=VALUE, \
           PropagateAtLaunch=true
```

- ResourceId

tagを設定するAutoScalingGroupの名前を指定

- ResourceType

他に何の設定があるのかは不明ですが`auto-scaling-group`を指定しておけば問題ないかと

- Key

tagのKey名

- Value

tagのValue名

- PropagateAtLaunch

設定したtagをAutoScalingGroupによって起動されたEC2インスタンスにも適用させるかどうか


上記の設定を行うことで、AutoScalingGroupにて起動されたEC2インスタンスへ  
タグが適用されるようになります。大変便利ですね。ありがとうございます。
