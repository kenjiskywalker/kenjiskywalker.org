---
layout: post
title: "CodeDeployのfailをSlackに通知して原因までたどりやすくする"
published: true
date: "2016-03-14T11:03:00+09:00"
comments: true


---

[AWS CodeDeploy Adds Push Notification Support](https://aws.amazon.com/jp/about-aws/whats-new/2016/02/aws-codedeploy-adds-push-notification-support/)  
  
ということで、これができるまではひたすらstate毎にslackに通知していたけど  
failしたらfailしたよって通知するようにした。  
  
流れ的にはこう

```
CodeDeploy fail -> AWS SNS -> AWS Lambda -> Slack
```

## やり方

### AWS SNSで受け口をつくる

CodeDeployがfailした歳に利用するSNSを用意する

- NotifyCodeDeployErrorToSlack

みたいな感じで。開発環境やステージングなどでslackの通知グループが別れる場合は  
都度SNSをつくっているんだけど、これもっと良いやり方ないのかな？

### CodeDeployのtriggerに先ほどつくったSNSを設定する

![https://dl.dropboxusercontent.com/u/5390179/capture-CodeDeployTrigger.png](https://dl.dropboxusercontent.com/u/5390179/capture-CodeDeployTrigger.png)

fail以外にもステータスがあるのでそこでhookかけても良いですね。  
自分のところはstate毎に通知させているので一旦この形です。

### AWS LambdaでSlackへの通知を行う

- NotifyCodeDeployErrorToSlackFunction

とか適当な名前でfunctionをつくる

```js
// Ref: https://gist.github.com/vgeshel/1dba698aed9e8b39a464
console.log('Loading function');

const https = require('https');
const url = require('url');
// to get the slack hook url, go into slack admin and create a new "Incoming Webhook" integration
const slack_url = '';
const region = 'ap-northeast-1'
const codedeploy_url = 'https://' + region + '.console.aws.amazon.com/codedeploy/home?region=' + region + '#/deployments/'
const slack_req_opts = url.parse(slack_url);
slack_req_opts.method = 'POST';
slack_req_opts.headers = {'Content-Type': 'application/json'};

exports.handler = function(event, context) {
  (event.Records || []).forEach(function (rec) {
    if (rec.Sns) {
      var req = https.request(slack_req_opts, function (res) {
        if (res.statusCode === 200) {
          context.succeed('posted to slack');
        } else {
          context.fail('status code: ' + res.statusCode);
        }
      });
      
      req.on('error', function(e) {
        console.log('problem with request: ' + e.message);
        context.fail(e.message);
      });
      
      var message = JSON.parse(rec.Sns.Message);
      var str = '*' + 'Application: ' + message.applicationName + ' deploymentGroupName: ' + message.deploymentGroupName + ' deploymentId: ' + message.deploymentId + '*' + ' ' + codedeploy_url + message.deploymentId;
      req.write(JSON.stringify({text: str})); // for testing: , channel: '@vadim'
      
      req.end();
    }
  });
};
```

`slack_url`に自前のIncoming Webhookを入れる

## 通知される

![](https://dl.dropboxusercontent.com/u/5390179/capture-CodeDeployError.png)

ご覧のとおりFail時に通知され、かつURLをクリックしたらCodeDeployのエラー画面にとべて便利なので  
ご利用ください。
