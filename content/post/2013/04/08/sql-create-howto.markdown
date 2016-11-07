---
layout: post
title: "tweets.zipを読みこませるSQLを書いた時のメモ"
published: true
date: "2013-04-08T01:19:00+09:00"
comments: true


---

[MySQL Casual Talks vol.4](http://atnd.org/events/38091)で話してみて  
ってmyfinderさんからお声がけしてもらって、SQL周りノータッチで生きてきて  
今色々勉強しだしてるけど、正直当日までに有用な話ができる気がしてない。  
  
再来週のオレが今のオレよりもう少し有意義な情報を持ち合わせているようにしたい。  
  
この前[tweets.zipをMySQLに突っ込んでSQLを学ぶ(導入編)](http://blog.kenjiskywalker.org/blog/2013/04/04/tweets_zip_big_data/)というのを書いて  
ホッテントリー入ったねとか、何回もブクマ数数えたでしょ？とか  
コンテンツ力高いとか、正直中身ないでしょアレとか。色々言われたんだけど  
SQLをはじめて作成するにあたって勉強になったので、その時のメモ
  
#### 参考: [MySQL 5.1 リファレンスマニュアル :: 10 データタイプ :: 10.1 データタイプ概要 :: 10.1.4 データタイプデフォルト値](http://dev.mysql.com/doc/refman/5.1/ja/data-type-defaults.html)  
TEXTタイプでは`NOT NULL`が使えない

#### 参考: [MySQL 5.1 リファレンスマニュアル :: 10 データタイプ :: 10.2. 数値タイプ](http://dev.mysql.com/doc/refman/5.1/ja/numeric-types.html)  
必要な数値タイプのバイト数の参考

#### 参考: [MySQL 5.1 リファレンスマニュアル :: 10 データタイプ :: 10.5 データタイプが必要とする記憶容量](http://dev.mysql.com/doc/refman/5.1/ja/storage-requirements.html)  
VARCHAR(255)が1バイトで、VARCHAR(256)で2バイト
utf8の日本語(マルチバイト)は1文字で3バイト。4byteのUTF8とかはutf8mb4
 
#### 参考: [MySQL 5.1 リファレンスマニュアル :: 10 データタイプ :: 10.4 文字列タイプ :: 10.4.1 CHAR と VARCHAR タイプ](http://dev.mysql.com/doc/refman/5.1/ja/char.html)  
参考程度

#### 参考: [MySQL 5.1 リファレンスマニュアル (オンラインヘルプ) :: 6 データ型 :: 6.3 日付と時刻型 :: 6.3.1 DATETIME、DATE、そして TIMESTAMP 型](http://dev.mysql.com/doc/refman/5.1-olh/ja/datetime.html)  
日付と時刻を入れる時の適切なタイプについての確認


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

- `UNSIGED` = 符号なしで正の値のみを扱う
- `VARCHAR(140)` = VARCHAR(n)は文字数。Twitterは140文字制限なので140決め打ちでイケる  
- `VARCHAR(255)` = マルチバイト文字列が入らず、255文字以内であれば1byteで済むので(255)  
- `TIMESTAMP` = `2013-03-13 08:52:14 +0000`を`2013-03-13 08:52:14 +0900`としても型自体が`YYY-MM-DD HH:MM:SS`しかサポートしていない為、その後のGMTの指定は破棄されたことを確認

ジャンパーソンみたいにMySQLのオフィシャルのリファレンスぺら読みしただけで  
全部の内容を記憶できる能力あったら便利っぽい。  
