---
layout: post
title: "AWSのVPCでAuto Scalingを試した記録"
published: true
date: "2013-08-14T17:41:00+09:00"
comments: true


---

# [Auto Scaling](http://aws.amazon.com/jp/autoscaling/)  

ELBにぶら下がっているVPC内のEC2のインスタンスのCPU使用率が  
n%以上になったらインスタンス増やして負荷を分散する。
  
普段AWSはGUIでしか操作していない為  
GUIが用意されていないAuto Scaling(以後:AS)を使うのは不安だった。  
全体像が掴めればそんなに困ることはない感じだ。  

大抵AWSの設定でハマるのはregionの指定のところだろう。  
これはマニュアルやコマンドのhelpはregionの省略を止めるべきだと思う。  


# 設定する必要のある項目  
  
### LaunchConfig
1. 起動するAMIの指定
2. そのAMIを利用して起動するインスタンスタイプの指定
3. 適応するセキュリティグループ名(VPCに適用するセキュリティグループ名)
4. 対象のリージョン

### AutoScalingGroup
1. ぶら下がるELBの指定
2. 立ち上がった後のインスタンスの状態の確認方法(今回はELB)
3. HelthCheckが走るまで待機する時間
> これを60秒とか短めに設定するとインスタンスが立ち上がる前にチェックが走って  
> 間に合わなくてターミネイトされて起動してターミネイトされてという地獄みたいな状態になった
4. 立ち上げるインスタンスを配置する予定のアベイラビリティゾーン
5. Auto Scalingで立ち上げる最小インスタンス
6. Auto Scalingで立ち上げる最大インスタンス
7. 立ち上げるVPCのサブネット
8. 対象のリージョン

### ScalingPolicyを設定する

> これはスケールアウト(インスタンス増加)とスケールイン(インスタンス減少)  
> の2つのパターンを作成する

1. 何台増加(減少)させるかの指定
2. typeがよくわからない
3. 次にスケールするまでの待機時間(cooldown)
4. 対象のリージョン

### CloudWatch

1. アラートの設定

> CPUUtilization が n分間 m% の使用率以上(以下)であったらアラートを発行  
という設定を行う。このアラートがスケールアウト(スケールイン)のトリガーとなる

# 設定していく


### LaunchConfig

```
# 作成
$ as-create-launch-config ExampleLaunchSetting --image-id ami-XXXXXXXX --instance-type m1.small --region ap-northeast-1 --group sg-XXXXXXXX

# 削除
$ as-delete-launch-config ExampleLaunchSetting --region ap-northeast-1

# 確認
$ as-describe-launch-configs --region ap-northeast-1
```

- `--image-id` ASで利用するAMI
- `--instance-type` ASで起動するEC2のインスタンスサイズ
- `--group` 起動するインスタンスに適用するSecurityGroup

# AutoScalingGroup

```
# 作成
$ as-create-auto-scaling-group ExampleScaleOutGroup --launch-configuration ExampleLaunchSetting --load-balancers example-vpc-elb --health-check-type ELB  --grace-period 300 --availability-zones ap-northeast-1b,ap-northeast-1c --min-size 1 --max-size 2 --desired-capacity 1 --vpc-zone-identifier subnet-XXXXXXXb,subnet-XXXXXXXc --region ap-northeast-1

# 削除
$ as-delete-auto-scaling-group ExampleScaleOutGroup (--force-delete) --region ap-northeast-1

# 確認
$ as-describe-auto-scaling-groups --region ap-northeast-1
```

- `--launch-configuration` 上記で作成した起動設定
- ` --load-balancers` ELB配下にぶら下げるので対象のELBを指定
- `--health-check-type` ELB以外のチェック方法調べてない
- `--grace-period` ヘルスチェックをはじめるまでの時間
> これを60秒とか短めに設定するとインスタンスが立ち上がる前にチェックが走って
> ターミネイトされて起動してターミネイトされてという地獄みたいな状態になった
- `--availability-zones` ASで起動させるインスタンスを置くAZを指定(複数可)
- `--min-size` ASの最小インスタンス数  
- `--max-size` ASの最大インスタンス数  
- `--desired-capacity` よくわかってない
- `--vpc-zone-identifier` VPCにアサインされているサブネットの指定(複数可)

この時点で設定に問題がなければインスタンスが起動してくる。  
インスタンスが起動しない、もしくは起動した後すぐにTerminateされるとしたら  
設定に誤りがあるか、`--grace-period`の閾値が厳しいのかのどちらかだろう。

## Auto Scaleの状態の確認
```
$ as-describe-scaling-activities --region ap-northeast-1
```

このコマンドで設定したASの状態が理解できる。  
いわばASの動作ログというところだ。  
AutoScalingGroupでVPCの設定が足りなかったのに気付けた。

> ACTIVITY  XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX  2013-08-13T10:56:45Z  ExampleScaleOutGroup  Failed  VPC security groups may not be used for a non-VPC launch. Launching EC2 instance failed.  
> こんな感じのエラーが出てた

## Auto Scaleによって立ち上がったインスタンスの状態の確認
```
$ as-describe-auto-scaling-instances --region ap-northeast-1
```

## ASの最大インスタンス数と最小インスタンス数の変更
```
$ as-update-auto-scaling-group --min-size 2 --max-size 4 --region ap-northeast-1
```

オンラインでカジュアルに変更できる

### ScalingPolicy

```
# 作成
$ as-put-scaling-policy ScaleUpPolicy   --auto-scaling-group ExampleScaleOutGroup --adjustment=1  --type ChangeInCapacity --cooldown 300 --region ap-northeast-1 
$ as-put-scaling-policy ScaleDownPolicy --auto-scaling-group ExampleScaleOutGroup --adjustment=-1 --type ChangeInCapacity --cooldown 300 --region ap-northeast-1

# ScalingPolicyの確認
$ as-describe-policies  --region ap-northeast-1
```

- `--auto-scaling-group` AutoScalingGroupの指定  
- `--adjustment` トリガーにかかった際に増やす(減らす)数
- `--type` 調べていない  
- `--cooldown` トリガーにかかった際に、連続してインスタンスの増減が発生しないように  
アイドル(クールダウン)の時間を設ける。  
  
# CloudWatchの設定

![https://dl.dropboxusercontent.com/u/5390179/AS1.png](https://dl.dropboxusercontent.com/u/5390179/AS1.png)

`Create Alarm` => `EC2 Aggregated by Auto Scaling Group` => AutoScalingGroupの選択  
今回はトリガー対象が`CPUUtilization`なのでそれを選択

![https://dl.dropboxusercontent.com/u/5390179/AS2.png](https://dl.dropboxusercontent.com/u/5390179/AS2.png)

名前をつける。  
`何分間の間 + CPU使用率が + n%以上(以下)`だったら  
という閾値を設定。画像は５分間の間CPU使用率が50%以上であれば。という設定


![https://dl.dropboxusercontent.com/u/5390179/AS3.png](https://dl.dropboxusercontent.com/u/5390179/AS3.png)

最後にその閾値に引っかかったら、`AutoScalingGroup`の`ScalingPolicy`を選択して  
インスタンスの増減を行う。インスタンスの増減が行われたら通知もしてほしいので、  
合わせて通知の設定も行った方がいいでしょう。  
  
# まとめ

1. ASのグループのCPU使用率が5分間50%以上を継続していた場合はインスタンスをひとつ増やす
2. 更に継続して10分間CPU使用率が50%以上を継続していた場合はインスタンスをひとつ増やす
3. CPU使用率が5分間20%以下を継続していた場合はインスタンスをひとつ減らす
4. CPU使用率が10分間20%以下を継続していた場合はインスタンスをひとつ減らす

という設定を行い、期待した動作を確認することができた。  
  
CPUの負荷を与えるには`stress`コマンドを利用すると便利だ。  
  
以上、検証結果をまとめてはみたものの、やはり色々と設定箇所が多いので  
取っ付きづらい印象はあると思う。  

## 全体を理解する

- LaunchConfig  
起動するインスタンスの設定

- AutoScalingGroup  
インスタンスの増減や対象のELB、VPCなど  
インスタンスの環境の設定。
`LaunchConfig`を参照する。

- ScalingPolicy  
インスタンスを何台増やす、減らすなど
インスタンスを操作するのかを設定。
`AutoScalingGroup`を参照する。

- CloudWatch  
Alarmに`ScalingPolicy`を設定することで  
AutoScalingGroupのメトリクス内容を見て  
`ScalingPolicy`を発動させる。

上記のような関係性を理解して検証をすると  
全体像を把握しやすくなるのではないでしょうか。  
  
  
取り敢えずのメモとして、また、これからAutoScalingを試す人向けに  
多少力添えできればと思い書いてみました。  
  
熟練者様のご指摘お待ちしております。


