---
layout: post
title: "GNUのsedとBSDのsed"
published: true
date: "2014-07-18T10:57:00+09:00"
comments: true


---

OSXでsedコマンドを実行した際に、正規表現が上手く動作しなかった。

## TL;DR

BSD sedがイケてないのではなく、  
GNU sedが独自で拡張正規表現を実装していただけっぽい。  

- OSX

```
['-']%
['-']% echo "hogeee" | sed -e 's/e\+//'
hogeee
['-']%
['-']% sed --version
sed: illegal option -- -
usage: sed script [-Ealn] [-i extension] [file ...]
       sed [-Ealn] [-i extension] [-e script] ... [-f script_file] ... [file ...]
['x']% 
```


- Linux

```
['-']#
['-']# echo "hogeee" | sed -e 's/e\+//'
hog
['-']#
['-']#
['-']# sed --version
GNU sed version 4.2.1
Copyright (C) 2009 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE,
to the extent permitted by law.

GNU sed home page: <http://www.gnu.org/software/sed/>.
General help using GNU software: <http://www.gnu.org/gethelp/>.
E-mail bug reports to: <bug-gnu-utils@gnu.org>.
Be sure to include the word ``sed'' somewhere in the ``Subject:'' field.
['-']#
```

### Reference

[3.3 Overview of Regular Expression Syntax - GNU sed Programs](http://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html#Regular-Expressions)  
[POSIX Basic Regular Expressions - Regular-Expressions.info](http://www.regular-expressions.info/posix.html)  

そもそもPOSIXで定義されている基本的な正規表現(_Basic Regular Expressions_)に  
`+`やら`?`やら`|`はなくて(_Extended Reuglar Exression_)  
GNU sedはそれを独自で使えるようにしている(_GNU extension_)。  
BSD sedは拡張はしていないから使えない。  
使うなら`-E`のオプションを利用する。って感じなのかな。


## 追記

そういえばBSDのsedで上書きしようとする場合は  

```
$ sed -i '' -e 's/foo/bar/' FILENAME
```

みたいに`-i ''`でファイル名に空文字与えないと  
ファイルに上書きされないのもハマった記憶ある。
