---
layout: post
title: "AlfredのUTC時間を調べるworkflowをつくった"
published: true
date: "2014-06-22T03:11:00+09:00"
comments: true


---

## [alfred-get-utc-workflow](https://github.com/kenjiskywalker/alfred-get-utc-workflow)

## TL;DR

毎回UTCが何時だか計算してたので機械にやらせる

## Ref

- [An Introduction to Workflows](http://support.alfredapp.com/workflows)
- [Pocketの記事をランダムに表示・検索するAlfred Workflowをつくりました - CreativeStyle](http://kadoppe.com/archives/2014/01/alfred-random-pocket-workflow.html)
- [https://github.com/zhaocai/alfred2-ruby-template](https://github.com/zhaocai/alfred2-ruby-template)

## workflow

- `utc`

だけで現在時刻に対するUTCの時間を

- `utc 20:00`

と`hh:mm`を引数で渡すとその時刻に対してのUTC時刻を表示する  
  
![https://raw.githubusercontent.com/kenjiskywalker/alfred-get-utc-workflow/master/screenshots/caps.png](https://raw.githubusercontent.com/kenjiskywalker/alfred-get-utc-workflow/master/screenshots/caps.png)
