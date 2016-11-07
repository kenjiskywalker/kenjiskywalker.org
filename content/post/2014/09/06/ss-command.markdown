---
layout: post
title: "ssコマンドの使えそうなもののメモ"
published: true
date: "2014-09-06T23:11:00+09:00"
comments: true


---

`$ss -lt`と`$ss -ltp`は使える。  
`-i`は面白いけど本当に確認するなら`ngrep`か`tcpdump`だろうな


## セッションを開いているホスト名を名前解決しない(デフォルト)

```bash
$ss -n
```

## セッションを開いているホスト名を名前解決する

```bash
$ss -r
```

## TCPのセッションのみ表示

```bash
$ss -t
```

```bash
$ss -A tcp
```


## UDPのセッションのみ表示

```bash
$ss -u
```

```bash
$ss -A udp
```

## TCPとUDPのセッションのみ表示


```bash
$ss -tu
```

```bash
$ss -A tcp,udp
```

## UNIX Domainのセッションのみ表示


```bash
$ss -x
```

```bash
$ss -A unix
```

## 特定のセッションの状態のものを抽出


```bash
$ss -t state fin-wait-2
```

## TCPでLISTENしているポートを表示

```bash
$ss -lt
```

## TCPでLISTENしているポートのプロセス名を表示

```bash
$ss -ltp
```

コマンド名自体が短いからササッと確認するのには良さそう
