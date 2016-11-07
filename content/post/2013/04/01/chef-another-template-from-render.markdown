---
layout: post
title: "Chef 11からtemplateの中でtemplateを呼び出せるようになっていた"
published: true
date: "2013-04-01T18:20:00+09:00"
comments: true


---

[Opscode Chef 11 Release / OpsCode blog](http://www.opscode.com/blog/2013/02/04/chef-11-released/)

> Long time contributor and past-MVP Andrea Campi added support for partial templates. This is a significant feature if you have templates with large sections that change based on attributes. You can now render additional templates inside a template with <%= render 'other_template.erb' %>. This functionality expands the capability of the template reasource in a huge way.

ということで、  

- /chef/cookboof/hoge/templates/default/hoge.conf.erb

の中で 

```
<%= render 'homhom.conf.erb' %>
```

と書くと


- /chef/cookboof/hoge/templates/default/homhom.conf.erb

が呼び出されて、templateの中でtemplateを呼び出すことができる。  
だいぶ便利っぽい
