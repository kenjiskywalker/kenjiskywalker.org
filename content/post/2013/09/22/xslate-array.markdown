---
layout: post
title: "Text::Xslateで配列"
published: true
date: "2013-09-22T13:30:00+09:00"
comments: true


---

配列の要素数と配列の中身を渡したかっただけだったのに  
2時間ぐらい時間つかいました。  
`\@hoge`を`@hoge`で渡してたからだった。  


```
#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use 5.010; 

use Text::Xslate;
use Data::Section::Simple;

my @hoge = qw/foo bar baz hage/;

my $vpath = Data::Section::Simple->new()->get_data_section();
my $tx = Text::Xslate->new(path => [$vpath]);


my $template = $tx->render("template.tx",
    {
        hage => \@hoge
    }
);

printf $template;

1;

__DATA__

@@ template.tx

: for $hage -> $item {
   item is <: $item :>
   Number is <: $~item.index :>

: }
```

ちなみにRubyだと

```
#!/usr/bin/env ruby

require 'erb'

hoge = ["foo", "bar", "baz", "hage"]
hage = 1

puts ERB.new(DATA.read).result(binding)

__END__
<% hoge.each_with_index do |h, i| %>item is <%= h %>
number is <%= i %>

<% end %>
```

こんな感じでした。  
`$~item.index`と`each_with_index`を覚えました。  
  
```
my @list = (1, 4, 3, 2, 4, 6);
say $#list;
```
`$#`、趣きがありますね。  
Perl、どこか東山文化の風を感じますね。


### 追記

<blockquote class="twitter-tweet"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> hage =&gt; に @ hoge を渡すと、展開されるから例えば @ hoge が ( dame, leon, bar) だとすると、( hage =&gt; &#39;dame&#39;, leon =&gt; &#39;bar&#39;) になるお</p>&mdash; soh335 (@soh335) <a href="https://twitter.com/soh335/statuses/381652207138902016">September 22, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> 合ってるよ。あと$<a href="https://twitter.com/search?q=%23%E3%81%AF%E8%AA%AD%E3%81%BF%E3%81%A5%E3%82%89%E3%81%84%E3%81%AE%E3%81%A7%E9%85%8D%E5%88%97%E3%81%AE%E8%A6%81%E7%B4%A0%E6%95%B0%E3%82%92%E6%B1%82%E3%82%81%E3%82%8B&amp;src=hash">#は読みづらいので配列の要素数を求める</a> scalar @ foo を使うほうがいいですね</p>&mdash; fujiwara (@fujiwara) <a href="https://twitter.com/fujiwara/statuses/381653503489220608">September 22, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> 基本リファレンスでやってれば解決</p>&mdash; 柴崎優季 (@shiba_yu36) <a href="https://twitter.com/shiba_yu36/statuses/381652730680332289">September 22, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
  
リファレンスで渡さないとハッシュ化します。おぼえました。  
要素数求める場合は`scalar(@hoge)`使います。`scalar()`おぼえました。  
ありがとうございます。
  
某面白法人、YAPCスピーカーが多くて大変素晴らしい環境です。  
某はてな社、YAPCスピーカーが多くて大変素晴らしい環境です。

