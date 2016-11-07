---
layout: post
title: "Chefのtemplateにrecipeからデータを渡すvariablesについて"
published: true
date: "2013-02-27T01:08:00+09:00"
comments: true


---

Chefで、同じcookbookを利用して  
異なった値を入れてよしなにファイルをつくりたかったメモ。  

@fujiwaraさん++  

  
> 検証環境  
> Chef v11.4.0  
  

Chefにて、同じcookbookを使い、異なった複数の値を与えて  
結果を異なったファイルに出力する場合は、**variables**を利用する。  
  
当初、この課題に対する解決方法として、  
複数の _role_ を作成し、その *role* 内で異なった値をJSONに入れることにより  
実現できると思い込んでいたのだが、run_listでは複数のrecipeとして理解されず、  
複数のroleで同じcookbookを利用した場合には後者のみが採用され、  
最初に読み込まれた *role* は認識されなかった。  
  
## variablesを利用したレシピをみていこう  
  
JSONには **ports** というkeyに対して、"6379"と"6380"という複数のvalueをもたせる  
  

{% gist 5039419 redis.json %}
  
recipe内で  
`ports.each do |port|`と分解して実行するように記述する  
また、わかりづらいのだが  
  
```  
    variables({  
      :port => port  
    })  
```  
  
このように *port* 、この場合でいえば "6379" 、 "6380" の値を  
**@port** に代入している。  
  

{% gist 5039419 recipe-default-recipe.rb %}

template内で、代入された **@port** を利用する   


{% gist 5039419 template-default-redis.conf.erb %}
  
上記内容の結果、出力ファイルとして  
  
{% gist 5039419 etc-redis-6379.conf %}
  
{% gist 5039419 etc-redis-6380.conf %}
  
期待した通り、複数のvalueを受け取り  
それぞれ異なったファイルに出力されることが確認できた。  

もう少しエレガントな方法があるように思うので  
他の方法などがあれば、是非是非コメントを頂きたい。
