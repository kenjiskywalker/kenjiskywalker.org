---
layout: post
title: "flunetd、forward先がダメだった時にforward元である程度ログを担保したい"
published: true
date: "2014-04-01T13:18:00+09:00"
comments: true


---

fluentdのbufferとforwardについて調べたのでメモ。

> fluentd v0.10.45


## 追記( 04/02 00:27)

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/kenjiskywalker">@kenjiskywalker</a> flushしようとしてできなかったbufferにもlimitまで溜まるから、1kbのbufferが128個で限界にはならないような気がしますが</p>&mdash; fujiwara (@fujiwara) <a href="https://twitter.com/fujiwara/statuses/451015148627456000">April 1, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/fujiwara">@fujiwara</a> 今手元で試したんですけどflush_interval関係なさそうですね。普通にflush_interval 1s buffer_chunk_limit 10とか指定してもそれ以上のbuffer保持してました</p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/statuses/451018249442836483">April 1, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/tagomoris">@tagomoris</a> <a href="https://twitter.com/fujiwara">@fujiwara</a> なるほど〜！</p>&mdash; ブラッド・ピット (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/statuses/451019439786307585">April 1, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

とのことです。

こちらも参照してください。

[fluentd の buffer あふれ改善議論 - togetter](http://togetter.com/li/650177)

`flush_interval`はあくまでflushするだけであって  
貯まる分は

`buffer_chunk_limit x buffer_queue_limit`

が影響する。ということですね。  

update( 04/02 11:40 )

## 参考

[fluentd - Buffer Plugin Overview](http://docs.fluentd.org/en/articles/buffer-plugin-overview)  
[tagomorisのメモ置き場 - FluentdでバッファつきOutputPluginを使うときのデフォルト値](http://d.hatena.ne.jp/tagomoris/20130123/1358929254)

### 構成

- 各ホストから集約サーバへ`foward`している
- 集約サーバはログを受け取ってゴニョゴニョしている

### Buffer

[BasicBuffer](https://github.com/fluent/fluentd/blob/master/lib/fluent/buffer.rb#L116)  
[FileBuffer](https://github.com/fluent/fluentd/blob/master/lib/fluent/plugin/buf_file.rb#L76)  
[MemoryBuffer](https://github.com/fluent/fluentd/blob/master/lib/fluent/plugin/buf_memory.rb#L67)

#### buffer_chunk_limit

FileBuffer = デフォルト(8MB)  
MemoryBuffer = デフォルト(8MB)

#### buffer_queue_limit

FileBuffer = デフォルト(256)  
MemoryBuffer = [64](https://github.com/fluent/fluentd/blob/master/lib/fluent/plugin/buf_memory.rb#L76)

#### 総バッファサイズ

- FileBuffer  
= 8 * 256 = 2048(2GB)

- MemoryBuffer  
= 8 * 64 = 512(512MB)


#### flush_interval

flush_interval = デフォルト([60s](https://github.com/fluent/fluentd/blob/master/lib/fluent/output.rb#L175))


### Bufferされる値を算出する

[fluentd - Buffer Plugin Overview](http://docs.fluentd.org/en/articles/buffer-plugin-overview)

> When the top chunk exceeds the specified size or time limit  
> (buffer_chunk_limit and flush_interval, respectively),  
> a new empty chunk is pushed to the top of the queue.  
> The bottom chunk is written out immediately when new chunk is pushed.

例えば

```
<match **>
  type forward
  flush_interval 1s
  buffer_queue_limit 128
  buffer_chunk_limit 1g
  <server>
    host localhost
    port 24225
  </server>
</match>
```

と設定していた場合、`buffer_queue_limit 1G`と`flush_interval 1s`の  
どちらかの閾値を超えた場合にflushされます。  

> If the bottom chunk write out fails,  
> it will remain in the queue and Fluentd will  
> retry after waiting several seconds (retry_wait).  
> If the retry count exceeds the specified limit (retry_limit),  
> the chunk is trashed. The retry wait time doubles each time  
> (1.0sec, 2.0sec, 4.0sec, …).  
> If the queue length exceeds the specified limit (buffer_queue_limit),  
> new events are rejected.

例えば上記設定例で

- `forward`先にデータが転送できなかった
- ログファイルは`1kB/sec`の書き込み

である場合、`buffer_chunk_limit 1g`に達する前に`flush_interval 1s`に引っかかり  
`flush_interval 1s` x `buffer_queue_limit 128`(128kB)分のバッファを確保した後  
新しいqueueは受け付けられなくなるかと思いきや、flushはあくまでflushなので  
バッファする量は

- buffer_chunk_limit x buffer_queue_limit 

で決まるとのこと。  
  
forward時にログの転送元でどれだけのバッファを担保したいかは  
ログの流量と転送元と転送先のスペックによって変わるので  
みんなよしなにやっているのではないかと思います。


### forward

結論から先に書いておくと

```
<match **>
  type forward
  hard_timeout 180s
  phi_threshold 100
  <server>
    host a
    port 24224
  </server>
  <server>
    host un
    port 24224
    standby
  </server>
  <secondary>
    type file
    path /var/log/fluent/forward-failed
  </secondary>
</match>
```

上記のような冗長構成にできるのは、forward先が  
いずれのサーバであっても同様の処理が行える時に限る。  
ということです。  
  
例えば`a`に障害があって`hard_timeout`で設定している  
180秒を超えた場合、転送先が`un`に変わります。  
しかし、結局`a`で処理していたログと`un`に流れたログを  
どこかでmergeしたりする必要があるのであれば、  
冗長構成を設定しない方が運用は楽かと。  
  
デフォルトの設定であれば

- retry_limit [17](https://github.com/fluent/fluentd/blob/master/lib/fluent/output.rb#L177)
- retry_wait [1.0s](https://github.com/fluent/fluentd/blob/master/lib/fluent/output.rb#L178)

となっており、最大`131072 sec`リトライしてくれます。  
ログの流量によってはその前に

- `buffer_chunk_limit` x `buffer_queue_limit` 

上記の閾値に引っかかる可能性がありますが、  
閾値に引っかかる前に`a`のサーバの状態を復活させた方が  
オペレーション的には楽だと思います。  
  
絶対ロストしてはいけないデータだから冗長構成は必須！！！  
という場合はそもそもfluentdの冗長構成の前にやることがあると思います。  
  
というようなことを書いたのですが、認識に誤りなどあれば  
ご指摘頂ければ幸いです。  
  
[fluentd の buffer あふれ改善議論 - togetter](http://togetter.com/li/650177)



