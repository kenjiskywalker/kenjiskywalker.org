---
layout: post
title: "対象のディレクトリの拡張子一覧を取得する方法と便利コマンド少々"
published: true
date: "2014-03-27T03:00:00+09:00"
comments: true


---

bashの奥は深い。

- ext-list.sh

```
#!/bin/bash

dir=`pwd`
list=`find ${dir} -type f -perm 755`

# not = !
# list=`find ${dir} -type f ! -perm 755`

for file in $list
do
    filename=`basename $file`
    ext=${filename##*.}
    ext_list=("${ext_list[@]}" ${ext})
done

echo ${ext_list[@]} | tr ' ' '\n' | sort | uniq -c | sort -n
```

などというスクリプトを作成しておいて  
確認したいディレクトリでそのスクリプトを叩けば取得できます。

__/usr/local/Cellar__で実行したら  

```
['-']% sh /tmp/ext-list.sh | tail -n10
   5 1
   5 6
   6 0
   7 py
  10 test
  11 sh
  16 pl
  27 result
  62 so
 116 la
['-']% 
```

こんな感じの結果になりました。

### 便利コマンド

- basename

```
['-']% basename /usr/local/bin/zsh
zsh
['-']%
```

- dirname

```
['-']% dirname /usr/local/bin/zsh
/usr/local/bin
['-']%
```

- シャープ

```
['-']% hoge=/usr/local/Cellar/zsh/5.0.2/lib/zsh/zutil.so
['-']%
['-']% echo ${hoge##*.}
so
['-']% echo ${hoge#*.}
0.2/lib/zsh/zutil.so
['-']%
```

- パーセント

```
['-']% hoge=/usr/local/Cellar/zsh/5.0.2/lib/zsh/zutil.so
['-']%
['-']% echo ${hoge%%.*}
/usr/local/Cellar/zsh/5
['-']%
['-']% echo ${hoge%.*}
/usr/local/Cellar/zsh/5.0.2/lib/zsh/zutil
['-']%
```
