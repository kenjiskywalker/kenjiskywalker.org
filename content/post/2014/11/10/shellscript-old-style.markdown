---
layout: post
title: "シェルスクリプトで外部コマンドを利用する場合の注意点"
published: true
date: "2014-11-10T15:37:00+09:00"
comments: true


---

## TL;DR

シェルスクリプトでbackquoteを見つけたら  
オールドスタイルおじさんを探し、矯正させよう

> GNU Bash-2.05 manual

```
       When the old-style backquote form of substitution is used, backslash retains its  lit-  
       eral  meaning except when followed by $, `, or \.  The first backquote not preceded by  
       a backslash terminates the command substitution.  When using the $(command) form,  all  
       characters between the parentheses make up the command; none are treated specially.
```


```bash
#!/bin/bash

#!/bin/bash

a=`echo '\'`
echo ${a} # \

b=`echo "\\"`
echo ${b} # unexpected EOF while looking for matching `"'

c=$(echo '\')
echo ${c} # \

d=$(echo "\\")
echo ${d} # \
```

## 参考

[http://hyperpolyglot.org/unix-shells#cmd-subst-note](http://hyperpolyglot.org/unix-shells#cmd-subst-note)


## 追記

<blockquote class="twitter-tweet" lang="en"><p>csh系では動かないのでは？というご意見を頂いておりますが、csh系を利用されている方は基本的に強い意思を持って取り組まれているかと存じますので、わざわざ説明することはないと判断しております</p>&mdash; kenjiskywalker (@kenjiskywalker) <a href="https://twitter.com/kenjiskywalker/status/531709951777857536">November 10, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
