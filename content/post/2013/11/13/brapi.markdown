---
layout: post
title: "シンデレラのようにブラピになる方法"
published: true
date: "2013-11-13T23:28:00+09:00"
comments: true


---

- TwitterのDevelopersサイトで必要な権限を取得(これは色んなところに載っているから省略)
- 実行したい時間にcronでスクリプトを叩く
  
これだけです。

## brapi.rb
```
#!/usr/bin/env ruby

# encoding: utf-8

require 'twitter'

YOUR_CONSUMER_KEY       = ''
YOUR_CONSUMER_SECRET    = ''
YOUR_OAUTH_TOKEN        = ''
YOUR_OAUTH_TOKEN_SECRET = ''

Twitter.configure do |config|
  config.consumer_key       = YOUR_CONSUMER_KEY
  config.consumer_secret    = YOUR_CONSUMER_SECRET
  config.oauth_token        = YOUR_OAUTH_TOKEN
  config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
end

img = open('./brapi.png')
Twitter.update_profile_image(img)
Twitter.update_profile(:name => "ブラッド・ピット")
```

## modoru.rb
```
#!/usr/bin/env ruby

# encoding: utf-8

require 'twitter'

YOUR_CONSUMER_KEY       = ''
YOUR_CONSUMER_SECRET    = ''
YOUR_OAUTH_TOKEN        = ''
YOUR_OAUTH_TOKEN_SECRET = ''

Twitter.configure do |config|
  config.consumer_key       = YOUR_CONSUMER_KEY
  config.consumer_secret    = YOUR_CONSUMER_SECRET
  config.oauth_token        = YOUR_OAUTH_TOKEN
  config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
end

img = open('./twitter.jpg')

Twitter.update_profile_image(img)
Twitter.update_profile(:name => "kenjiskywalker")
```

`Twitter.update_profile_image`で画像をアップロードして  
`Twitter.update_profile(:name => "name")`で名前を変更する。  
  
やり方さえわかれば簡単ですね。

