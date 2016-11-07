---
layout: post
title: "Consulでkey/valueを叩く"
published: true
date: "2014-09-09T23:09:00+09:00"
comments: true


---

## TL;DR

Consulでkey/valueを叩く


```
['-']% curl -X PUT -d 'bar' http://127.0.0.1:8500/v1/kv/foo
true
['-']%
['-']%
['-']% curl -s http://127.0.0.1:8500/v1/kv/foo | jq .
[
  {
    "CreateIndex": 538,
    "ModifyIndex": 538,
    "LockIndex": 0,
    "Key": "foo",
    "Flags": 0,
    "Value": "YmFy"
  }
]
['-']%
['-']% curl -s http://127.0.0.2:8500/v1/kv/foo | jq .
[
  {
    "CreateIndex": 538,
    "ModifyIndex": 538,
    "LockIndex": 0,
    "Key": "foo",
    "Flags": 0,
    "Value": "YmFy"
  }
]
['-']%
['-']% curl -X PUT -d 'barbar' http://127.0.0.2:8500/v1/kv/foofoo
true
['-']%
['-']% curl -s http://127.0.0.1:8500/v1/kv/foofoo | jq .
[
  {
    "CreateIndex": 540,
    "ModifyIndex": 540,
    "LockIndex": 0,
    "Key": "foofoo",
    "Flags": 0,
    "Value": "YmFyYmFy"
  }
]
['-']%
['-']%
```


### delete

```
['-']%
['-']% curl -X DELETE -d 'barbar' http://127.0.0.2:8500/v1/kv/foofoo
['-']%
['-']%
['-']% curl -s http://127.0.0.1:8500/v1/kv/foofoo | jq .
['-']%
['-']%
['-']% curl -X PUT -d 'barbar' http://127.0.0.2:8500/v1/kv/foofoo
true%                                                                                                  ['-']%
['-']%
['-']%
```

### 再帰もいける

```
['-']% curl -s 'http://127.0.0.1:8500/v1/kv/?recurse' | jq .
[
  {
    "CreateIndex": 555,
    "ModifyIndex": 555,
    "LockIndex": 0,
    "Key": "foofoo",
    "Flags": 0,
    "Value": "YmFyYmFy"
  },
  {
    "CreateIndex": 538,
    "ModifyIndex": 538,
    "LockIndex": 0,
    "Key": "foo",
    "Flags": 0,
    "Value": "YmFy"
  }
]
['-']%
```


### flags

```
['-']%
['-']% curl -s http://127.0.0.2:8500/v1/kv/foofoo | jq .
[
  {
    "CreateIndex": 555,
    "ModifyIndex": 559,
    "LockIndex": 0,
    "Key": "foofoo",
    "Flags": 0,
    "Value": null
  }
]
['-']%
['-']% curl -X PUT 'barbar' -s 'http://127.0.0.1:8500/v1/kv/foofoo?flags=1' | jq .
true
['-']%
['-']% curl -s http://127.0.0.2:8500/v1/kv/foofoo | jq .
[
  {
    "CreateIndex": 555,
    "ModifyIndex": 560,
    "LockIndex": 0,
    "Key": "foofoo",
    "Flags": 1,
    "Value": null
  }
]
['-']%
```


### 階層化とdecode

> BSD の base64 コマンドだと  
> -dがdebugで-Dがdecodeだった

```
['-']% curl -X PUT -d 'bazbazbaz' -s 'http://127.0.0.1:8500/v1/kv/foo/bar/baz'
true
['x']%
['x']% curl -s 'http://127.0.0.1:8500/v1/kv/foo/bar/baz' | jq '.[]'
{
  "CreateIndex": 565,
  "ModifyIndex": 568,
  "LockIndex": 0,
  "Key": "foo/bar/baz",
  "Flags": 0,
  "Value": "YmF6YmF6YmF6"
}
['-']%
['-']%
['-']% curl -s 'http://127.0.0.1:8500/v1/kv/foo/bar/baz' | jq '.[].Value' -r | base64 -D
bazbazbaz
['-']%
```

