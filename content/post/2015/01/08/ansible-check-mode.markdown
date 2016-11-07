---
layout: post
title: "Ansibleはcheck modeだとshellやcommandは実行されない"
published: true
date: "2015-01-08T11:46:00+09:00"
comments: true


---

最近は深刻なjinja2とAnsible疲れです。

```
TASK: [ruby | check ruby rbenv installed] *************************************
skipping: [192.0.2.100]
ok: [192.0.2.100] => {"msg": "check mode not supported for command", "skipped": true}

TASK: [ruby | rbenv install {{ ruby_version }}] *******************************
fatal: [192.0.2.100] => error while evaluating conditional: ruby_installed.find(2.1.4)

FATAL: all hosts have already failed -- aborting
```

こんなエラーが出た。

[Check Mode (Dry Run)](http://docs.ansible.com/playbooks_checkmode.html)

dry runでは`shell`や`command`はskipされるとのことなので

```
- name: check ruby rbenv installed
  shell: cd; bash -lc "rbenv versions | grep {{ ruby_version }} | tr '*' ' ' | sed -e 's/\s\+//' | cut -f1 -d' '"
  register: ruby_installed
  always_run: yes
  ignore_errors: yes
  tags:
    - ruby
    - ruby:install
    - install
```

のように`always_run: yes`にしなければならない。  
自分メモ。
