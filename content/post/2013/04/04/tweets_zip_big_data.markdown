---
layout: post
title: "tweets.zipをMySQLに突っ込んでSQLを学ぶ(導入編)"
published: true
date: "2013-04-04T23:59:00+09:00"
comments: true


---

Twitterの過去ログが落とせるようになったので  
SQLに学ぶには丁度いいや。ということで  
カジュアルにOSX上でhomebrewを使ってMySQLに入れてみました。

> MySQL ver.5.6 (homebrew install)  
> OS /   OSX 10.8.3  

## なにはともあれアーカイブをダウンロード

Twitterの個人設定っぽいところから

![https://dl.dropbox.com/u/5390179/3f23b1e38c307f8ed59378435ff5097a.png](https://dl.dropbox.com/u/5390179/3f23b1e38c307f8ed59378435ff5097a.png)

ポチポチするとダウンロードリンクが貼られたメールが送られてくるので  
ポチポチして`tweets.zip`をダウンロード。

## tweets.csvを探す

![https://dl.dropbox.com/u/5390179/829186d4.png](https://dl.dropbox.com/u/5390179/829186d4.png)

`tweets.zip`を解凍すると、中身がこんな感じに出てきて  
`index.html`をブラウザで開くと、過去のツウィートが見れたりします。  
  
> 時間泥棒なのでおすすめしません
  
  
そして、`tweets.csv`が目的のファイルで、中身を開くと  

```
"tweet_id","in_reply_to_status_id","in_reply_to_user_id","retweeted_status_id","retweeted_status_user_id","timestamp","source","text","expanded_urls"
"311761607619391489","","","","","2013-03-13 08:52:14 +0000","<a href=""http://sites.google.com/site/yorufukurou/"" rel=""nofollow"">YoruFukurou</a>","さよならインターネット"
```

こんな感じのCSVファイルになっていることがわかります。  


## MySQL側でデータベースとテーブルを用意する

これをよしなにMySQLに格納するためのデータベースとテーブルをつくります。

### データベースをつくる

```
mysql> CREATE DATABASE tw DEFAULT CHARACTER SET utf8;
Query OK, 1 row affected (0.01 sec)

mysql> use tw
Database changed
mysql>
mysql> SHOW TABLE STATUS;
Empty set (0.00 sec)

mysql>
```

### CSVに対応したテーブルをつくる

つくったりけしたりしやすいようにSQLファイルで読み込ませます

`tweets_csv_to_sql.sql`
```
CREATE TABLE tweets (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tweet_id` BIGINT UNSIGNED,
  `in_reply_to_status_id` BIGINT UNSIGNED,
  `in_reply_to_user_id` BIGINT UNSIGNED,
  `retweeted_status_id` BIGINT UNSIGNED,
  `retweeted_status_user_id` BIGINT UNSIGNED,
  `timestamp` TIMESTAMP DEFAULT 0,
  `source` VARCHAR(255),
  `text` VARCHAR(140),
  `expanded_urls` VARCHAR(255),
  PRIMARY KEY (id) )
ENGINE = InnoDB DEFAULT CHARACTER SET utf8;
```

### いれる

```
$ mysql -u root tw < tweets_csv_to_sql.sql
```

### 確認する

```
mysql> DESC tweets;
+--------------------------+---------------------+------+-----+---------------------+----------------+
| Field                    | Type                | Null | Key | Default             | Extra          |
+--------------------------+---------------------+------+-----+---------------------+----------------+
| id                       | int(10) unsigned    | NO   | PRI | NULL                | auto_increment |
| tweet_id                 | bigint(20) unsigned | YES  |     | NULL                |                |
| in_reply_to_status_id    | bigint(20) unsigned | YES  |     | NULL                |                |
| in_reply_to_user_id      | bigint(20) unsigned | YES  |     | NULL                |                |
| retweeted_status_id      | bigint(20) unsigned | YES  |     | NULL                |                |
| retweeted_status_user_id | bigint(20) unsigned | YES  |     | NULL                |                |
| timestamp                | timestamp           | NO   |     | 0000-00-00 00:00:00 |                |
| source                   | varchar(255)        | YES  |     | NULL                |                |
| text                     | varchar(140)        | YES  |     | NULL                |                |
| expanded_urls            | varchar(255)        | YES  |     | NULL                |                |
+--------------------------+---------------------+------+-----+---------------------+----------------+
10 rows in set (0.01 sec)
```

今回は空データとかがあるので楽するためにNULLを許可するようにしています。

### CSVファイルを読みこませる


```
mysql>
mysql> LOAD DATA INFILE '/Users/kenjiskywalker/Downloads/tweets/tweets.csv' INTO TABLE tweets FIELDS \
TERMINATED BY "," \
ENCLOSED BY '"' \
LINES TERMINATED BY "\n" \
IGNORE 1 LINES \
(tweet_id, in_reply_to_status_id, in_reply_to_user_id, retweeted_status_id, retweeted_status_user_id, timestamp, source, text, expanded_urls);
Query OK, 23315 rows affected, 65535 warnings (0.61 sec)
Records: 23315  Deleted: 0  Skipped: 0  Warnings: 126199
mysql>
```

[12.2.5. LOAD DATA INFILE 構文 / MySQL 5.1 リファレンスマニュアル :: 12 SQL ステートメント構文 :: 12.2 データ取り扱いステートメント](http://dev.mysql.com/doc/refman/5.1/ja/load-data.html)  
詳しくはこちらのオフィシャルページを参照してください。

##### LOAD DATA INFILE 
テキストファイルからテーブルに行を読み込む。

#### TERMINATED BY
フィールドの区切りを指定。

#### ENCLOSED BY
`'"'`としてダブルクォーテーションを指定することで値を囲むだけの意味にする。

#### LINES TERMINATED BY
行の終わりを指定。Windowsなら`"\r\n"`かな？

#### IGNORE n LINES
1行目は説明行なので、無視するように指定。

各カラムを直接指定してるのは、一番最初のカラムにPRYMARY KEYを置いてるからで  
これがなければ各カラムを指定しなくても入るはず。


### 上手く読み込んでくれない場合

```
ERROR 1366 (HY000): Incorrect integer value: '' for column 'in_reply_to_user_id' at row 1
```

みたいにエラーになる場合、*Strict Mode*が有効になっている可能性が高い。  
個人的にここにハマってすごい時間使った...

```
mysql>
mysql> SELECT @@SESSION.sql_mode;
+---------------------+
| @@SESSION.sql_mode  |
+---------------------+
| STRICT_TRANS_TABLES |
+---------------------+
1 row in set (0.00 sec)

mysql>
```

こんな感じで有効になってる場合は、`my.cnf`などを確認してみた方がいい。

```
mysql>
mysql> SELECT @@GLOBAL.sql_mode;
+------------------------+
| @@GLOBAL.sql_mode      |
+------------------------+
| NO_ENGINE_SUBSTITUTION |
+------------------------+
1 row in set (0.00 sec)

mysql>
```

これならWarningsになるだけでデータは入ってくれる。

```
mysql>
mysql> SHOW WARNINGS LIMIT 5;
+---------+------+----------------------------------------------------------------------------+
| Level   | Code | Message                                                                    |
+---------+------+----------------------------------------------------------------------------+
| Warning | 1366 | Incorrect integer value: '' for column 'in_reply_to_status_id' at row 1    |
| Warning | 1366 | Incorrect integer value: '' for column 'in_reply_to_user_id' at row 1      |
| Warning | 1366 | Incorrect integer value: '' for column 'retweeted_status_id' at row 1      |
| Warning | 1366 | Incorrect integer value: '' for column 'retweeted_status_user_id' at row 1 |
| Warning | 1265 | Data truncated for column 'timestamp' at row 1                             |
+---------+------+----------------------------------------------------------------------------+
5 rows in set (0.00 sec)

mysql>
```

### とうことでめでたくデータベースの中にツウィートが入った

```
mysql>
mysql> SELECT COUNT(*) FROM tweets;
+----------+
| COUNT(*) |
+----------+
|    23315 |
+----------+
1 row in set (0.01 sec)

mysql>
mysql>
```

入ってるっぽい

```text
mysql> SELECT text FROM tweets WHERE text LIKE '%カミさん%' LIMIT 3;
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| text                                                                                                                                                                                                         |
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 335とひさいち、Perl Girlsのオーガナイザーになって女の子とウハウハになればいいじゃんって思った。オレ？オレがやったらカミさんに手榴弾抱えさせられて相模湾にダイブキメなきゃならないから無理                    |
| カミさんに見られたら毎晩説教くらうので家ではFacebookもTwitterもクソだって言ってる                                                                                                                            |
| そういえば昨日カミさんがシルク・ドゥ・ソレイユとマイケル・ジャクソン来るから見に行こうって言ってて、マイケル・ジャクソン来ないよ。死んだじゃん。って言ったら、あっ！！！みたいなリアクションしてて無視した   |
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
3 rows in set (0.00 sec)

mysql>
```

貴重なカミさん情報だ

<a href="http://www.amazon.co.jp/gp/product/4873112818/ref=as_li_tf_il?ie=UTF8&camp=247&creative=1211&creativeASIN=4873112818&linkCode=as2&tag=13nightcrows-22"><img border="0" src="http://ws.assoc-amazon.jp/widgets/q?_encoding=UTF8&ASIN=4873112818&Format=_SL110_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=13nightcrows-22" ></a><img src="http://www.assoc-amazon.jp/e/ir?t=13nightcrows-22&l=as2&o=9&a=4873112818" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />  
今これ読んでる。MySQL 4.11とかだいぶ古い感じしてる...
    

