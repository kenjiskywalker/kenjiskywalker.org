---
layout: post
title: "AWS CLIでスポットインスタンスリクエストを送る"
published: true
date: "2014-01-07T20:39:00+09:00"
comments: true


---

日本語の情報があまりなかったので共有しておきます。  

> aws cli 1.2.9

## 参考

- [AWS CLI / request-spot-instances](http://docs.aws.amazon.com/cli/latest/reference/ec2/request-spot-instances.html)  
基本のドキュメント。

- [AWS CLI / run-instances](http://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html)  
> --user-data (blob)  
>  
> Specifies additional information to make available to the instance(s). This parameter must be passed as a Base64-encoded string.  

user-dataをbase64で送らなければいけないことはこちらに書いてあった。

- [Launch Your Own NAT Instance in VPC - Indefinable Hacking](http://blog.awsapi.com/blog/2013/09/17/launch-your-own-nat-instance-under-vpc/)  
ヘンリーさんのやり方がとてもセンスがあった。ほぼヘンリーさんのやり方を踏襲した。
  

## exp) spot_instance_request.sh
```
HOST=$1
AMI="AMI"
INSTANCE_TYPE="t1.micro"
PRICE="0.1"
KEYPAIR="KEYPAIR"
AZ="AZ"
USER_DATA=`echo "${HOST}" | openssl enc -base64`
REGION="REGION"
SECURITY_GROUPS="\"default\", \"image\""

### jq check
JQ_COMMAND=`which jq`
if [ -z ${JQ_COMMAND} ]; then
    echo "jq command not found"
    exit 1
fi

### SET JSON
rm -f /tmp/launch_config.json
cat << EOF >> /tmp/launch_config.json
{
  "ImageId": "${AMI}",
  "KeyName": "${KEYPAIR}",
  "InstanceType": "${INSTANCE_TYPE}",
  "Placement": {
    "AvailabilityZone": "${AZ}"
  },
  "Monitoring": {
    "Enabled": true
  },
  "UserData": "${USER_DATA}",
  "SecurityGroups": [
    ${SECURITY_GROUPS}
  ]
}
EOF

### PUT SPOT_REQUEST
aws ec2 request-spot-instances --spot-price ${PRICE} --region ${REGION} --launch-specification file:///tmp/launch_config.json > /tmp/spot_request.json
SIR_ID=`jq '.SpotInstanceRequests[0] | .SpotInstanceRequestId' /tmp/spot_request.json --raw-output`

echo "[INFO] SpotInstanceRequestID: ${SIR_ID}";


### GET SPOT_INSTANCE INSTANCE_ID
rm -f /tmp/spot_instance.json

aws ec2 describe-spot-instance-requests --spot-instance-request-ids ${SIR_ID} --region ${REGION} > /tmp/spot_instance.json
INSTANCE_ID=`jq '.SpotInstanceRequests[0] | .InstanceId' /tmp/spot_instance.json --raw-output`

while [ "${INSTANCE_ID}" == "null" ]
do
    aws ec2 describe-spot-instance-requests --spot-instance-request-ids ${SIR_ID} --region ${REGION} > /tmp/spot_instance.json
    INSTANCE_ID=`jq '.SpotInstanceRequests[0] | .InstanceId' /tmp/spot_instance.json --raw-output`

    sleep 10
done

echo "[INFO] INSTANCE_ID: ${INSTANCE_ID}";

# つづく
```

こんな感じで取得できます。  

- Monitoringが渡せなかった。(バージョンを1.2.9にしたら渡せるようになった)  
- JSON祭り  
- UserDataをbase64にencodeしないといけない  
- SecurityGroupsの渡し方がアレだ  
  
などなどやっていました。今後は`DeleteOnTermination`も有効にしたいです。  
aws cliはバージョンがどんどん上がっているので、そのうち  
JSON祭りもなくなるのではないかと思います。
  
参考になれば幸いです。
