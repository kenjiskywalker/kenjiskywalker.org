---
layout: post
title: "homebrewでバージョンを固定してインストールしたい"
published: true
date: "2014-06-19T18:11:00+09:00"
comments: true


---

homebrewがバージョン指定してインストールできないので  
packageを作成してインストールする方法を記載します。  
  
> バージョン指定してインストールできるようにするissueとかp-rあるだろう  
> と思って探してみたんですが見つからなかった。探し方が悪いかもしれない。

### TL;DR

`Brewfile`などでバージョン指定してインストールできないので  
自分で利用したいバージョンのpackageを作成してそれをインストールする


### Ref
[brew tap - Homebrew/homebrew](https://github.com/Homebrew/homebrew/wiki/brew-tap)  
[Formula Cookbook - Homebrew/homebrew](https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook)  
[HomeBrewで自作ツールを配布する - SOTA](http://deeeet.com/writing/2014/05/20/brew-tap/)  
[Homebrew vs Boxen を比較して、brewproj に着手 - ja.ngs.io](http://ja.ngs.io/2014/05/08/homebrew-boxen/)  


### How To  

例えばnginxの1.2.8のバージョンを静的に指定してインストールしたい場合
  
1. GitHubの自分の利用したいアカウントにて、`homebrew-foo`というリポジトリを作成する。
2. `brew versions nginx`を実行してgitのハッシュを取得する
3. `/usr/local/Library/`配下にて_2._で取得したハッシュをcheckout
4. `/usr/local/Library/Formula/nginx.rb`を`homebrew-foo/nginx128.rb`という名前で保存
5. `nginx128.rb`

- before
```
class Nginx < Formula
```

- after
```
class Nginx128 < Formula
```

上記のようにclass名を変更

6. `nginx128.rb` をcommitしてpush
7. `brew tap username/foo`のコマンドを発行して`nginx128.rb`を取得
8. `brew search nginx`のコマンドを発行して

```
nginx          nginx128
```

と出れくれば成功。

9. `brew install nginx128`のコマンドを発行してインストール
10. nginx -v でバージョンを確認  
(/etc/pathsで/usr/bin/より先に/usr/local/bin/を見に行くようにしておく)
  
上記流れで、自前のtapリポジトリを作成し、  
そこに必要な分の静的なバージョンを指定したソフトウェアの設定を格納することで  
バージョン指定がバリバリの環境も無難に構築することが可能になります。  
  
ちなみに既存のhomebrewでインストールしたnginxを上書きしたくない場合は  
`nginx128.rb`の中身をよしなに変更することで可能です。  
  

<blockquote class="twitter-tweet" lang="en"><p>brewでバージョン固定したソフトウェアを配布しまくる雑なノウハウが溜まっていく</p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/statuses/479544803370102784">June 19, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>  
  
<blockquote class="twitter-tweet" data-conversation="none" lang="en"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> うちは redis24.rb で class Redis24 とか雑に変えて独自の tap リポジトリにつっこんでますよ</p>&mdash; そらは (@sora_h) <a href="https://twitter.com/sora_h/statuses/479545416204025856">June 19, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>  
  
<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> 仲間!</p>&mdash; そらは (@sora_h) <a href="https://twitter.com/sora_h/statuses/479545592897490944">June 19, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>


こちらからは以上です。
