---
layout: post
title: "RailsのARで取ってきたオブジェクトにアクセスする"
published: true
date: "2015-08-08T20:57:00+09:00"
comments: true


---

考えたら当たり前なんだけど

```
mysql> desc people;
+---------------+--------------+------+-----+---------+----------------+
| Field         | Type         | Null | Key | Default | Extra          |
+---------------+--------------+------+-----+---------+----------------+
| id            | int(11)      | NO   | PRI | NULL    | auto_increment |
| name          | varchar(255) | YES  |     | NULL    |                |
| prefecture    | varchar(255) | YES  |     | NULL    |                |
| created_at    | datetime     | YES  |     | NULL    |                |
| updated_at    | datetime     | YES  |     | NULL    |                |
+---------------+--------------+------+-----+---------+----------------+
7 rows in set (0.00 sec)

mysql>
```

みたいなものがあってView側で

```
    @prefecture_name = People.group(:prefecture)
```

みたいな感じでprefectureをまとめておいて  
プルダウンでprefectureを選択してsubmitして

```
    <%= form_tag({:action=>"list"}, {:method=>"get"}) do %>
      # all_peoplesはpeoples
      <%= select_tag 'prefecture', options_from_collection_for_select(@prefecture_name, "prefecture", "prefecture") %>
      <%= submit_tag 'subsubsub' %>
    <% end %>
```

で`prefecture`を`params`で受け取れるようにしておいて

```
  def list
    @people_selected_by_prefecture = People.where(prefecture: params[:prefecture])
  end
```

みたいな感じでControllerで選択されたprefectureでレコードを抜いておいて  

```
<% @people_selected_by_prefecture.each do |p| %>
  <%= p.name %> | <%= p.prefecture %><br>
<% end %>
```

みたいな感じでプルダウンで選んだprefectureに該当する人間を選ぶ  
みたいな感じ

```
<% @people_selected_by_prefecture.each do |p| %>
  <%= p[0] %> | <%= p[1] %><br>
<% end %>
```

とかでやろうとしていたけどそもそもHashではない




