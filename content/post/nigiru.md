+++
date = "2016-12-07T22:01:16+09:00"
description = "nigiru"
title = "itamae が nigiru ための nigiru.rb という社内プロビジョニングツールについて"

+++

このエントリは [Classi Advent Calendar 2016](http://qiita.com/advent-calendar/2016/classi) 9日目の記事です。  

# itamaeについて

## [http://itamae.kitchen](http://itamae.kitchen)  
> Configuration management tool inspired by Chef,  
> but simpler and lightweight. Formerly known as Lightchef.  

chefに疲れた人類は一縷の望みを懐き向かった先こそがitamae。  

## 使い方

[ここ](http://itamae.kitchen)を見てもらえばわかる通り、chefを利用したことがある人は特に迷いなく利用できる。  
利用したことがなくても第一歩については一瞬で実行可能なのでとにかくチャレンジしてみてほしい。  
itamaeは裏側で[Specinfra](https://githunob.com/mizzy/specinfra)を利用していたりしてそれもかわいい。  
コード全体の見通しがよく、問題があっても（今まで問題はない）コード見て特定できる。  
見通しが良いコードは、あらゆる面において最高なので、とにかくitamaeは最高ということがわかる。

## provisioning is dead ?

時代はコンテナでアプリケーションをポン置き。  
まだプロビジョニングで疲弊しているの？という世界はまぁわかる。  

# nigiru.rb について

itamaeを利用している各社においては、各々のitamae管理ツールなるものを運用していると思う。  
弊社もそれ相応のものを運用しているのでこの場をお借りして軽く紹介したい。

## 構成

基本は[Best Practice](https://github.com/itamae-kitchen/itamae/wiki/Best-Practice)を参考にしている

```
.
├── REAME.md
├── bootstrap.rb
├── cookbooks
├── initializer.rb
├── nigiru.rb
├── recipe_helper.rb
├── roles
└── tools
```


## nigiruの内部処理

### option設定周りとEC2タグの確認


- `-n` で itamae の `--dry-run` を呼び出し
- `-r` で role の指定
- `--init` で `initializer`(OS起動時のみ実行したい処理)を指定

EC2は`EC2_TAG_ROLE`と`EC2_TAG_STAGE`という環境変数を持っており  
その環境変数を見て色々と処理を分けている。  
`EC2_TAG_ROLE`はitamaeの`roles`の部分と対を成している。

```
opt = OptionParser.new

@options = {
  dry_run: false,
  init: false
}

@logfile = '/var/log/itamae.log'

opt.on('-n', '--dry-run')   { @options[:dry_run] = true }
opt.on('-r ROLE', '--role') { @options[:role] = v }
opt.on('--init')            { @options[:init] = true }
opt.parse!(ARGV)

def before_check_ec2_tag
  if ENV['EC2_TAG_ROLE'].nil?
    puts "ENV['EC2_TAG_ROLE'] が設定されていません"
    exit 1
  end
  if ENV['EC2_TAG_STAGE'].nil?
    puts "ENV['EC2_TAG_STAGE'] が設定されていません"
    exit 1
  end
end
```

### itamaeの実行コマンドを生成

```
def make_itamae_command
  # itamaeの実行ファイルを指定
  itamae_bin = `which itamae`.chomp

  # --init であれば initializer.rb を指定する
  if @options[:init]
    # initializer は role とは関係がないので before_check_ec2_tag は不要
    command = "#{itamae_bin} local --no-color --ohai #{__dir__}/initializer.rb"
  else
    before_check_ec2_tag
    command = "#{itamae_bin} local --no-color --ohai #{__dir__}/bootstrap.rb"
  end

  # dyr-runの確認
  command += ' -n' if @options[:dry_run]

  command
end
```

### itamaeの実行　

```
# itamae実行箇所
def exec_itamae
  # itamaeの実行
  stdout, status = Open3.capture2(itamae_command)

  # nigiru 自身の exit code として itamaeの exit status を利用
  itamae_exit_status = status.exitstatus

  # 標準出力に出力する
  puts stdout

  # ファイルにアウトプットする
  write_out_file(stdout)

  itamae_exit_status
end
```

### itamaeの実行ログをファイルに出力している

```
def write_out_file(stdout)
  return if @options[:dry_run]

  File.open(@logfile, 'w') do |file|
    file.puts stdout
  end
end
```

### nigiruの通知周り

メールの通知はログとして冗長であってもそこまで問題ではないにしろ、  
Slackへの通知は情報量が多すぎるのでもう少し整理したい。  
この辺の通知周りについての知見を知りたい。

```
def notify_log_to_slack(message)
  return if @options[:dry_run]

  # --init だとわかるように情報を付与
  message += " INITIALIZE" if @options[:init]

  if ENV['EC2_TAG_STAGE'] == "production"
    slack_channel = '#CHANNEL'
  else
    slack_channel = '#CHANNEL'
  end

  now = `date +%Y/%m/%d:%H:%M`.chomp
  hostname = `hostname`.chomp

  `curl -s https://slack.com/api/chat.postMessage \
     -X POST -d 'link_names=1' \
             -d 'channel=#{slack_channel}' \
             -d 'text=#{now}: HOSTNAME: *#{hostname}* : #{message} :sushi: ' \
             -d 'username=itamae' \
             -d 'icon_emoji=:itamae:' \
             -d 'token=#{ENV['SLACK_TOKEN']}'`
end
```

`hostname`全体で持てばいいな...

```
def notify_log_to_mail
  return if @options[:dry_run]

  now      = `date +%Y/%m/%d:%H:%M`.chomp
  hostname = `hostname`.chomp

  `cat #{@logfile} | col -b | mail -s "ITAMAE LOG #{hostname} : #{now}" #{mail_to}`
end
```

### mainの処理

```
# itamaeの実行の通知
notice_log_by_slack("ITAMAE START")

# itamaeを実行して実行ステータスをitamae_exit_status に入れる
itamae_exit_status = exec_command

# 実行した内容をメールで送る
notice_log_by_mail

# 実行内容をSlackへ通知
notice_log_by_slack(File.read(@logfile))

# 完了後の通知実行箇所
if itamae_exit_status != 0
  notice_log_by_slack(":anger: ITAMAE ERROR!!!")
else
  notice_log_by_slack("ITAMAE DONE")
end

exit itamae_exit_status
```

# initializer.rbとbootstrap.rbについて

## initializer.rb

`./cookbooks/initializer/default.rb`と  
`./cookbooks/common/default.rb`を読み込んでいる。

```
#!/usr/bin/env ruby

require File.join(__dir__, "./recipe_helper.rb")

# Roleのattributeを優先する
include_attributes :role, "initializer"
include_attributes :role, "common"

# 何も指定しない場合は ENV['EC2_TAG_ROLE'] のroleを実行するようにしよう
include_recipe File.join('roles', 'initializer', 'default.rb')
```

- recipe_helper.rb

`include_cookbook`と`include_attributes`をhelperで実装。

```
module RecipeHelper
  def include_cookbook(name)
    include_recipe File.join(__dir__, "cookbooks", name, "default.rb")
  end

  # type: :roles or :cookbooks
  def include_attributes(type, name)
    unless %i(role cookbook).include?(type)
      raise "type must be #{type}"
    end

    filepath =File.join(__dir__, "#{type}s", name, "attributes.rb")
    if File.exists?(filepath)
      include_recipe filepath
    else
      Itamae.logger.warn "attribute not found: #{filepath}"
    end
  end
end

Itamae::Recipe::EvalContext.include(RecipeHelper)
```

- ./cookbooks/initializer/default.rb

OS起動時に必要な処理を色々とやっている

```
include_recipe './boot_file.rb'
include_recipe './directorys.rb'
include_recipe './os_settings.rb'
include_recipe './swap.rb'
...
```


## bootstrap.rb

`roles/ROLE/default.rb`を読み込むための設定。  
各種インストールパッケージや、agent周りの設定は`common`に記載している。

```
require File.join(__dir__, "./recipe_helper.rb")

# Roleのattributeを優先する
include_attributes :role, ENV['EC2_TAG_ROLE']
include_attributes :role, "common"

# 共通のrecipeはここで読み込む
include_recipe File.join('roles/common/default.rb')

# 何も指定しない場合は ENV['EC2_TAG_ROLE'] のroleを実行する
include_recipe File.join('roles', ENV['EC2_TAG_ROLE'], 'default.rb')
```

# nigiruをどうやって実行しているか

## CIに連動したプロビジョニング

CircleCI + CodeDeployでpull型のdeployを実装している。  
しかし、逐次処理の処理速度の遅さと、一括処理による失敗時のリスクのバランスの取り方が  
適切ではない。全体のn%に対してプロビジョニングを行うなども感がているが  
みんなどうやっているのか知見を知りたい。

## インスタンス起動時に実行

`/var/lib/cloud/scripts/per-boot/002_itamae.sh`  

というファイルを用意しておき、インスタンス起動時には  
最新のmasterをpullし、`nigiru`ようにしている。  
ご覧の通り、001や003、004など色々な処理をインスタンス起動時にしているが  
数字に特に意味はない。

# おわりに

全体的な流れをつらつらと書いたが、雰囲気だけでも理解してもらえればありがたい。  
また、この記事を元に、いや、うちではこうしている、その処理はこうすべき、と  
議論に発展すればなおありがたい💪☺️  

COOKPAD社の方のソフトウェアには色々とお世話になってはいるが、  
物理的にお会いしたことがないので、お会いした際には是非感謝の意を伝えたい🙏  

また、itamaeに関しては、chef -> ansible -> itamaeという  
プロビジョニングツールを利用してきた遍歴から、多少はプロビジョニングについての  
ノウハウのようなものを習得したかもしれない前提であっても、  
自分で細かい処理が実装できる点において、itamaeは最高としか言いようがない。  
[ryotaarai](https://github.com/ryotarai)さんありがとうございます🙏  

明日はkitaharamikiyaさんの「Appiumを使ってみた話」です。