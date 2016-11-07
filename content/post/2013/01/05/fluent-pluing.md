---
layout: post
title: "超初級！Fluentdのプラグインを書きたくなった時の下地づくり"
published: true
date: "2013-01-05T00:52:00+09:00"
comments: true


---

fluentdをまともに動かしたことないけど  
プラグイン書いたらわかるのでは！！？  
と思い立って取り敢えず下地だけつくったのでメモ。

#### 参考  
 - [fluentdのためのプラグインをイチから書く手順(bundler版) / tagomorisのメモ置き場](http://d.hatena.ne.jp/tagomoris/20120221/1329815126)  
 - [Writing plugins / fluentd](http://docs.fluentd.org/articles/plugin-development)  
 - [fluent-plugin-imkayac / fujiwara](https://github.com/fujiwara/fluent-plugin-imkayac)  
 - [fluent-plugin-r18 / studio3104](https://github.com/studio3104/fluent-plugin-r18)

基本はもりす先生の手順にそって行えば問題なし。  
参考にオフィシャルのドキュメントと  
@fujiwaraさんのシンプルなプラグイン  
@studio3104さんの下地を見ながら書くとなおよし。


また、rake testまで通したものを

[https://github.com/kenjiskywalker/fluent-plugin-hoge](https://github.com/kenjiskywalker/fluent-plugin-hoge)

こちらに上げておきました。ここから遊んでみても良いのではないかと思います。

  
### 作成手順

#### bunldeで作成

```
$ bundle gem fluent-plugin-hoge
$ cd fluent-plugin-hoge/
$ mkdir -p lib/fluent/plugin
$ mv lib/fluent-plugin-hoge.rb lib/fluent/plugin/out_hoge.rb
$ rm lib/fluent-plugin-hoge/version.rb
$ rmdir lib/fluent-plugin-hoge
$ mkdir -p test/plugin
$ touch test/plugin/test_out_hoge.rb
```

#### gemspecファイルの修正

`fluent-plugin-hoge.gemspec`
```
# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-hoge"
  gem.version       = "0.0.1"
  gem.authors       = ["kenjiskywalker"]
  gem.email         = ["git@kenjiskywalker.org"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency "fluentd"
  gem.add_runtime_dependency "fluentd"
end
```
version周りの設定の変更とfluentdの依存周りの設定の追加


#### out_hoge.rbの作成

`fluent-plugin-hoge/lib/fluent/plugin/out_hoge.rb`
```
class Fluent::HogeOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('hoge', self)

  include Fluent::SetTagKeyMixin
  config_set_default :include_tag_key, false

  include Fluent::SetTimeKeyMixin
  config_set_default :include_time_key, true

  # config_param :hoge, :string, :default => 'hoge'

  def initialize
    super
    # require 'hogepos'
  end

  def configure(conf)
    super
    # @path = conf['path']
  end

  def start
    super
    # init
  end

  def shutdown
    super
    # destroy
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def write(chunk)
    records = []
    chunk.msgpack_each { |record|
      # records << record
    }
    # write records
  end
end
```

#### test周りの設定

`fluent-plugin-hoge/test/helper.rb`

```
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'fluent/test'
unless ENV.has_key?('VERBOSE')
  nulllogger = Object.new
  nulllogger.instance_eval {|obj|
    def method_missing(method, *args)
      # pass
    end
  }
  $log = nulllogger
end

require 'fluent/plugin/out_hoge'

class Test::Unit::TestCase
end
```

`fluent-plugin-hoge/test/plugin/test_out_hoge.rb`

```
require 'helper'
# require 'time'

class HogeOutputTest < Test::Unit::TestCase
  # TMP_DIR = File.dirname(__FILE__) + "/../tmp"

  def setup
    Fluent::Test.setup
    # FileUtils.rm_rf(TMP_DIR)
    # FileUtils.mkdir_p(TMP_DIR)
  end

  CONFIG = %[
  ]
  # CONFIG = %[
  #   path #{TMP_DIR}/out_file_test
  #   compress gz
  #   utc
  # ]

  def create_driver(conf = CONFIG)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::HogeOutput).configure(conf)
  end

  def test_configure
    #### set configurations
    # d = create_driver %[
    #   path test_path
    #   compress gz
    # ]
    #### check configurations
    # assert_equal 'test_path', d.instance.path
    # assert_equal :gz, d.instance.compress
  end

  def test_format
    d = create_driver

    # time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    # d.emit({"a"=>1}, time)
    # d.emit({"a"=>2}, time)

    # d.expect_format %[2011-01-02T13:14:15Z\ttest\t{"a":1}\n]
    # d.expect_format %[2011-01-02T13:14:15Z\ttest\t{"a":2}\n]

    # d.run
  end

  def test_write
    d = create_driver

    # time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    # d.emit({"a"=>1}, time)
    # d.emit({"a"=>2}, time)

    # ### FileOutput#write returns path
    # path = d.run
    # expect_path = "#{TMP_DIR}/out_file_test._0.log.gz"
    # assert_equal expect_path, path

    # data = Zlib::GzipReader.open(expect_path) {|f| f.read }
    # assert_equal %[2011-01-02T13:14:15Z\ttest\t{"a":1}\n] +
    #                 %[2011-01-02T13:14:15Z\ttest\t{"a":2}\n],
    #              data
  end
end
```

#### Rakefileの設定

`Rakefile`

```
#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
```

#### rake testの実行

```
$ rake test
# Running tests:

...

Finished tests in 0.065174s, 46.0306 tests/s, 0.0000 assertions/s.

3 tests, 0 assertions, 0 failures, 0 errors, 0 skips
```

うおおおおおおおおお！！！自分で何も書いてないけどテストが通った喜びッッ！！！  

ということで、ここからつくりあげていく感じになるでしょうか。  
当初、何もわかっていない状態で*fluent-plugin-postfix-logger*などと  
ドヤ顔でつくりはじめたのですが、ファイルの関係性とか全く理解していない状態で  
ややこしいファイル名にすると間違っている箇所が特定しづらいので  
最初は*fluent-plugin-hoge*などと作成して、最低限自分が確認したい状態まで  
持っていった上で確認していくのがいいという、初心者っぽい気付きがありました。  

初心者ながら地道にやっていきたいということで超初級の恥ずかしいメモを  
アップしました。誤りなどありましたら教えてくださいませ！
