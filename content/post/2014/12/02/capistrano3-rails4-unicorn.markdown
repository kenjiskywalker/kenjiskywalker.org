---
layout: post
title: "capistrano3を利用してRails4をdeployしunicornを使う"
published: true
date: "2014-12-02T23:30:00+09:00"
comments: true


---

> Rails v4.1.2  
> capistrano v3.3.3

## TL;DR

cap3でrails4のデプロイとbundle install  
unicornの操作をできるようにするまでのメモ

### 手元のマシンでcap3をインストール

```
$ gem install capistrano
```

Railsアプリケーションのあるパスに移動

```
$ cd app_name
```


### cap install

```
$ cap install
mkdir -p config/deploy
create config/deploy.rb
create config/deploy/staging.rb
create config/deploy/production.rb
mkdir -p lib/capistrano/tasks
create Capfile
Capified
$ 
```

`app_name/config`配下にdeploy用の各種設定テンプレートが格納され、  
独自rake taskを格納する`app_name/lib/capistrano/tasks/`ディレクトリが作成され、  
capistrano用の設定ファイル?であるCapfileのひな形が作成される.


## deployの設定

#### config/deploy.rb

汎用的な設定はここに書くのかな

```
lock '3.3.3'

# 自分のアプリケーション名
set :application, 'app_name'

# 自分のリポジトリ名.capistranoはrsyncではなくgit pullする
set :repo_url, 'git@github.com:kenjiskywalker/app_name.git'

# デプロイ先
set :deploy_to, '/home/foo/app_name'

# cap stage unicorn:start などの実行対象の role . デフォルトは app
set :unicorn_roles, :all

set :ssh_options, {

# ここのオプションは ssh_config に記載されていれば不要
# port: 2222,
# keys: [File.expand_path('~/.ssh/hoge.key')],

}

# ここは cap install するとコメントアウトで入るのでそのコメントアウトを解除
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
```

### config/deploy/stage.rb

汎用的な設定はdeploy.rbに書き、stage毎の設定はstage.rbに書くのかな

- config/deploy/development.rb

```
# RAILS_ENV の指定
set :rails_env, 'development'

# unicorn で利用する RACK_ENV の指定
set :unicorn_rack_env, 'development'

# ここの user も ssh_config に記載されていれば不要
server 'dev-web1', user: 'foo', roles: %w{web}
```

- config/deploy/staging.rb

```
# RAILS_ENV の指定
set :rails_env, 'staging'

# unicorn で利用する RACK_ENV の指定
set :unicorn_rack_env, 'staging'

# ここの user も ssh_config に記載されていれば不要
server 'stg-web1', user: 'foo', roles: %w{web}
```

- config/deploy/production.rb

```
# RAILS_ENV の指定
set :rails_env, 'production'

# unicorn で利用する RACK_ENV の指定
set :unicorn_rack_env, 'production'

# ここの user も ssh_config に記載されていれば不要
server 'web1', user: 'foo', roles: %w{web}
```


### Gemfile

capistranoで利用するgemを追加

```
group :development, :staging, :production do
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
  gem 'capistrano3-unicorn'
  gem 'unicorn'
end
```



### Capfile

consoleとbundlerとunicornを有効化

```
# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'
require 'capistrano/console' # cap stage console とかやると便利

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#
# require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
require 'capistrano/bundler' # deploy:updated の前に bundle install してくれる
require 'capistrano3/unicorn' # cap3で unicorn を操作できるようにしてくれる
# require 'capistrano/rails/assets'
# require 'capistrano/rails/migrations'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
```

### config/unicorn/stage.rb

[:unicorn_config_path](https://github.com/tablexi/capistrano3-unicorn/blob/master/lib/capistrano3/tasks/unicorn.rake#L4) を参考にすると  
`config/unicorn.rb`ではなく`config/unicorn/satge.rb`を記載する

unicorn 設定例 : [example.rb](https://github.com/tablexi/capistrano3-unicorn/blob/master/examples/unicorn.rb)

上記設定例を参考に設定.取り敢えず変更箇所は`app_path`ぐらい

- config/unicorn/stage.rb

```
# paths
app_path = "/home/foo/app_name"
working_directory "#{app_path}/current"
pid               "#{app_path}/current/tmp/pids/unicorn.pid"

# listen
listen "/tmp/hoge-api.socket", :backlog => 64

# logging
stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log"

# workers
worker_processes 3

# use correct Gemfile on restarts
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{app_path}/current/Gemfile"
end

# preload
preload_app true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
```

## 動作チェック

### deploy

```
$ bundle exec cap development deploy:check
$ bundle exec cap development deploy
$ bundle exec cap staging deploy
$ bundle exec cap production deploy
```

### unicorn

```
$ bundle exec cap development unicorn:start
$ bundle exec cap development unicorn:legacy_restart
$ bundle exec cap development unicorn:stop
```

### 学び

rsyncではなくgit pullなので混乱することがある.  
currentやrelease, sharedなど見たらわかる面白構造.  
当たり前だけど上手くいかない時は手を動かすよりドキュメントとコードを読んだ方が早い.  
  
以上簡単なメモです.
