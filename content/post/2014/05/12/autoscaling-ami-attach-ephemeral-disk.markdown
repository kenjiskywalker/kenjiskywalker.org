---
layout: post
title: "AWSのAutoScalingで起動するインスタンスにEhemeral Diskをattachする"
published: true
date: "2014-05-12T18:13:00+09:00"
comments: true


---

AutoScalignのLaunch ConfigurationでEphemeral DiskをAttachすることが可能です。  
存在しない場合は無視されるので、下記のように4本など  
事前に指定しておくのが良いかと思います。

- create-launch-configuration


```
$ aws autoscaling --region REGION create-launch-configuration --launch-configuration-name AUTOSCALINGLAUNGCONFIG \
                  --image-id AMI \
                  --instance-type m1.small \
                  --key-name KEYNAME \
                  --security-groups sg-00000000 sg-00000001 \
                  --block-device-mappings '[ {"DeviceName":"/dev/sdb","VirtualName":"ephemeral0"}, \
                                             {"DeviceName":"/dev/sdc","VirtualName":"ephemeral1"}, \
                                             {"DeviceName":"/dev/sdd","VirtualName":"ephemeral2"}, \
                                             {"DeviceName":"/dev/sde","VirtualName":"ephemeral3"} \
                                           ]'

```

- aws autoscaling --region REGION describe-launch-configurations 

```
{
    "LaunchConfigurations": [
        {
            "UserData": null,
            "EbsOptimized": false,
            "LaunchConfigurationARN": "arn:aws:ARN:REGION:NUM:launchConfiguration:NUM:launchConfigurationName/AUTOSCALINGLAUNGCONFIG",
            "InstanceMonitoring": {
                "Enabled": true
            },
            "ImageId": "AMI",
            "CreatedTime": "2014-01-01T01:00:00.000Z",
            "BlockDeviceMappings": [
                {
                    "DeviceName": "/dev/sdd",
                    "VirtualName": "ephemeral2"
                },
                {
                    "DeviceName": "/dev/sdb",
                    "VirtualName": "ephemeral0"
                },
                {
                    "DeviceName": "/dev/sde",
                    "VirtualName": "ephemeral3"
                },
                {
                    "DeviceName": "/dev/sdc",
                    "VirtualName": "ephemeral1"
                }
            ],
            "KeyName": "KEYNAME",
            "SecurityGroups": [
                "sg-00000000",
                "sg-00000001"
            ],
            "LaunchConfigurationName": "AUTOSCALINGLAUNGCONFIG",
            "KernelId": null,
            "RamdiskId": null,
            "InstanceType": "m1.small"
        }
    ]
}
```
  
突然Ephemeral DiskがAttachされない状態で起動するようになっててハマりました。  
