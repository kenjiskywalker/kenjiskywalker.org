---
layout: post
title: "大変便利なMySQL::Sandboxのインストールメモ(GTID有効編)"
published: true
date: "2015-06-28T00:07:00+09:00"
comments: true


---

以前MySQLの師匠のyoku0825さんに教えてもらったMySQL::Sandboxが  
大変便利だったので改めてインストール方法をメモしておく

参考URL

- [MySQL Sandboxを使ってみる - まめ畑](http://d.conma.me/entry/20100616/1276683437)  
- [Easily testing MySQL 5.6 GTID in a sandbox - The Data Charmer](http://datacharmer.blogspot.jp/2013/01/easily-testing-mysql-56-gtid-in-sandbox.html)

> 環境  
> OS X 10.10.3  
> MySQL-Sandbox v3.0.50

## cpanmでMySQL::Sandboxをインストール

```
['-']% cpanm MySQL::Sandbox
--> Working on MySQL::Sandbox
Fetching http://www.cpan.org/authors/id/G/GM/GMAX/MySQL-Sandbox-3.0.50.tar.gz ... OK
Configuring MySQL-Sandbox-v3.0.50 ... OK
Building and testing MySQL-Sandbox-v3.0.50 ... OK
Successfully installed MySQL-Sandbox-v3.0.50
1 distribution installed
['-']% 
```


## MySQL 5.6.25のレプリケーションを作成する

`$HOME/mysqls`というディレクトリにMySQLをインストールする

```
['-']% mkdir ~/mysqls
['-']% cd ~/mysqls
```

```
['-']% make_replication_sandbox 5.6.25
installing and starting master
installing slave 1
installing slave 2
starting slave 1
.. sandbox server started
starting slave 2
.. sandbox server started
initializing slave 1
initializing slave 2
replication directory installed in $HOME/sandboxes/rsandbox_5_6_25
['-']%
```

これだけでインストールとレプリケーションが完了。  
  
ちゃんと入っているか確認

```
['-']% cd ~/sandboxes/rsandbox_5_6_25/
['-']%
['-']% ./check_slaves
master
             File: mysql-bin.000001
         Position: 2696
slave # 1
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 2696
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
          Exec_Master_Log_Pos: 2696
slave # 2
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 2696
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
          Exec_Master_Log_Pos: 2696
['-']%
```

## GTIDモードに変更

```
['-']%
['-']% ./enable_gtid
# option 'master-info-repository=table' added to master configuration file
# option 'relay-log-info-repository=table' added to master configuration file
# option 'gtid_mode=ON' added to master configuration file
# option 'log-slave-updates' added to master configuration file
# option 'enforce-gtid-consistency' added to master configuration file
# option 'master-info-repository=table' added to node1 configuration file
# option 'relay-log-info-repository=table' added to node1 configuration file
# option 'gtid_mode=ON' added to node1 configuration file
# option 'log-slave-updates' added to node1 configuration file
# option 'enforce-gtid-consistency' added to node1 configuration file
# option 'master-info-repository=table' added to node2 configuration file
# option 'relay-log-info-repository=table' added to node2 configuration file
# option 'gtid_mode=ON' added to node2 configuration file
# option 'log-slave-updates' added to node2 configuration file
# option 'enforce-gtid-consistency' added to node2 configuration file
# executing "stop" on /Users/kenjiskywalker/sandboxes/rsandbox_5_6_25
executing "stop" on slave 1
executing "stop" on slave 2
executing "stop" on master
# executing "start" on /Users/kenjiskywalker/sandboxes/rsandbox_5_6_25
executing "start" on master
. sandbox server started
executing "start" on slave 1
.. sandbox server started
executing "start" on slave 2
. sandbox server started
['-']%
```

これだけでGTIDモードへ変更される。  
何をやったかはコメントアウトで出力されていて大変便利。  
  
先ほどと同様にレプリケーションのチェック

```
['-']% ./check_slaves
master
             File: mysql-bin.000002
         Position: 151
slave # 1
              Master_Log_File: mysql-bin.000002
          Read_Master_Log_Pos: 151
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
          Exec_Master_Log_Pos: 151
slave # 2
              Master_Log_File: mysql-bin.000002
          Read_Master_Log_Pos: 151
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
          Exec_Master_Log_Pos: 151
['-']%
```

正常にレプリケーションがされいているようだ。

## テストデータの投入とGTIDのチェック

- m = master
- s1 = slave 1
- s2 = slave 2

```
['-']% ./m -e 'CREATE TABLE test.t1(i INT NOT NULL PRIMARY KEY)'
['-']%
['-']% ./m -e 'INSERT INTO test.t1 VALUES (1)'
['-']% ./m -e 'INSERT INTO test.t1 VALUES (2)'
['-']%
['-']% ./m -e 'SHOW MASTER STATUS;'
+------------------+----------+--------------+------------------+------------------------------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+------------------+----------+--------------+------------------+------------------------------------------+
| mysql-bin.000002 |      825 |              |                  | c924fe80-1cda-11e5-89ae-14d803869455:1-3 |
+------------------+----------+--------------+------------------+------------------------------------------+
['-']%
['-']% ./m -e 'SHOW BINLOG EVENTS IN "mysql-bin.000002"'
+------------------+-----+----------------+-----------+-------------+-------------------------------------------------------------------+
| Log_name         | Pos | Event_type     | Server_id | End_log_pos | Info                                                              |
+------------------+-----+----------------+-----------+-------------+-------------------------------------------------------------------+
| mysql-bin.000002 |   4 | Format_desc    |         1 |         120 | Server ver: 5.6.25-log, Binlog ver: 4                             |
| mysql-bin.000002 | 120 | Previous_gtids |         1 |         151 |                                                                   |
| mysql-bin.000002 | 151 | Gtid           |         1 |         199 | SET @@SESSION.GTID_NEXT= 'c924fe80-1cda-11e5-89ae-14d803869455:1' |
| mysql-bin.000002 | 199 | Query          |         1 |         317 | CREATE TABLE test.t1(i INT NOT NULL PRIMARY KEY)                  |
| mysql-bin.000002 | 317 | Gtid           |         1 |         365 | SET @@SESSION.GTID_NEXT= 'c924fe80-1cda-11e5-89ae-14d803869455:2' |
| mysql-bin.000002 | 365 | Query          |         1 |         440 | BEGIN                                                             |
| mysql-bin.000002 | 440 | Query          |         1 |         540 | INSERT INTO test.t1 VALUES (1)                                    |
| mysql-bin.000002 | 540 | Xid            |         1 |         571 | COMMIT /* xid=29 */                                               |
| mysql-bin.000002 | 571 | Gtid           |         1 |         619 | SET @@SESSION.GTID_NEXT= 'c924fe80-1cda-11e5-89ae-14d803869455:3' |
| mysql-bin.000002 | 619 | Query          |         1 |         694 | BEGIN                                                             |
| mysql-bin.000002 | 694 | Query          |         1 |         794 | INSERT INTO test.t1 VALUES (2)                                    |
| mysql-bin.000002 | 794 | Xid            |         1 |         825 | COMMIT /* xid=32 */                                               |
+------------------+-----+----------------+-----------+-------------+-------------------------------------------------------------------+
['-']%
['-']%
```

## SLAVEの状態チェック

```
['-']% ./check_slaves
master
             File: mysql-bin.000002
         Position: 825
slave # 1
              Master_Log_File: mysql-bin.000002
          Read_Master_Log_Pos: 825
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
          Exec_Master_Log_Pos: 825
slave # 2
              Master_Log_File: mysql-bin.000002
          Read_Master_Log_Pos: 825
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
          Exec_Master_Log_Pos: 825
['-']%
```

## GTIDのチェック

```
['-']% ./s1 -e 'SHOW SLAVE STATUS\G' | egrep 'Running|Gtid'
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
      Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
           Retrieved_Gtid_Set: c924fe80-1cda-11e5-89ae-14d803869455:1-3
            Executed_Gtid_Set: c924fe80-1cda-11e5-89ae-14d803869455:1-3
['-']% ./s2 -e 'SHOW SLAVE STATUS\G' | egrep 'Running|Gtid'
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
      Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
           Retrieved_Gtid_Set: c924fe80-1cda-11e5-89ae-14d803869455:1-3
            Executed_Gtid_Set: c924fe80-1cda-11e5-89ae-14d803869455:1-3
['-']%
```

# 更にテストデータを追加

```
['-']% ./m -e 'INSERT INTO test.t1 VALUES (3)'
['-']% ./m -e 'SHOW MASTER STATUS;'
+------------------+----------+--------------+------------------+------------------------------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+------------------+----------+--------------+------------------+------------------------------------------+
| mysql-bin.000002 |     1079 |              |                  | c924fe80-1cda-11e5-89ae-14d803869455:1-4 |
+------------------+----------+--------------+------------------+------------------------------------------+
['-']% ./m -e 'SHOW BINLOG EVENTS IN "mysql-bin.000002"'
+------------------+------+----------------+-----------+-------------+-------------------------------------------------------------------+
| Log_name         | Pos  | Event_type     | Server_id | End_log_pos | Info                                                              |
+------------------+------+----------------+-----------+-------------+-------------------------------------------------------------------+
| mysql-bin.000002 |    4 | Format_desc    |         1 |         120 | Server ver: 5.6.25-log, Binlog ver: 4                             |
| mysql-bin.000002 |  120 | Previous_gtids |         1 |         151 |                                                                   |
| mysql-bin.000002 |  151 | Gtid           |         1 |         199 | SET @@SESSION.GTID_NEXT= 'c924fe80-1cda-11e5-89ae-14d803869455:1' |
| mysql-bin.000002 |  199 | Query          |         1 |         317 | CREATE TABLE test.t1(i INT NOT NULL PRIMARY KEY)                  |
| mysql-bin.000002 |  317 | Gtid           |         1 |         365 | SET @@SESSION.GTID_NEXT= 'c924fe80-1cda-11e5-89ae-14d803869455:2' |
| mysql-bin.000002 |  365 | Query          |         1 |         440 | BEGIN                                                             |
| mysql-bin.000002 |  440 | Query          |         1 |         540 | INSERT INTO test.t1 VALUES (1)                                    |
| mysql-bin.000002 |  540 | Xid            |         1 |         571 | COMMIT /* xid=29 */                                               |
| mysql-bin.000002 |  571 | Gtid           |         1 |         619 | SET @@SESSION.GTID_NEXT= 'c924fe80-1cda-11e5-89ae-14d803869455:3' |
| mysql-bin.000002 |  619 | Query          |         1 |         694 | BEGIN                                                             |
| mysql-bin.000002 |  694 | Query          |         1 |         794 | INSERT INTO test.t1 VALUES (2)                                    |
| mysql-bin.000002 |  794 | Xid            |         1 |         825 | COMMIT /* xid=32 */                                               |
| mysql-bin.000002 |  825 | Gtid           |         1 |         873 | SET @@SESSION.GTID_NEXT= 'c924fe80-1cda-11e5-89ae-14d803869455:4' |
| mysql-bin.000002 |  873 | Query          |         1 |         948 | BEGIN                                                             |
| mysql-bin.000002 |  948 | Query          |         1 |        1048 | INSERT INTO test.t1 VALUES (3)                                    |
| mysql-bin.000002 | 1048 | Xid            |         1 |        1079 | COMMIT /* xid=44 */                                               |
+------------------+------+----------------+-----------+-------------+-------------------------------------------------------------------+
['-']%
['-']% ./s1 -e 'SHOW SLAVE STATUS\G' | egrep 'Running|Gtid'
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
      Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
           Retrieved_Gtid_Set: c924fe80-1cda-11e5-89ae-14d803869455:1-4
            Executed_Gtid_Set: c924fe80-1cda-11e5-89ae-14d803869455:1-4
['-']% ./s2 -e 'SHOW SLAVE STATUS\G' | egrep 'Running|Gtid'
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
      Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
           Retrieved_Gtid_Set: c924fe80-1cda-11e5-89ae-14d803869455:1-4
            Executed_Gtid_Set: c924fe80-1cda-11e5-89ae-14d803869455:1-4
['-']%
```

これでテスト環境が完成した

## 高速に検証が可能になる

```
['-']%
['-']% ./s2 -e 'SELECT i FROM test.t1'
+---+
| i |
+---+
| 1 |
| 2 |
| 3 |
+---+
['-']%
['-']% ./use_all 'SELECT i FROM test.t1'
# master
i
1
2
3
# server: 1:
i
1
2
3
# server: 2:
i
1
2
3
['-']%
```

うーむ、便利だ。
