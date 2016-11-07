---
layout: post
title: "Redisの2.8.2からsplit brainの対策がされているようです"
published: true
date: "2014-03-12T01:46:00+09:00"
comments: true


---

2.8.2 [FIX] Sentinel better desynchronization to avoid split-brain elections
[https://github.com/antirez/redis/blob/2.8/00-RELEASENOTES#L149](https://github.com/antirez/redis/blob/2.8/00-RELEASENOTES#L149)

Sentinel: better time desynchronization.
[https://github.com/antirez/redis/commit/75347ada7f431925b97b037b56b5e3801e3fd16d](https://github.com/antirez/redis/commit/75347ada7f431925b97b037b56b5e3801e3fd16d)

> Sentinels are now desynchronized in a better way changing the time
> handler frequency between 10 and 20 HZ. This way on average a
> desynchronization of 25 milliesconds is produced that should be larger
> enough compared to network latency, avoiding most split-brain condition
> during the vote.
> 
> Now that the clocks are desynchronized, to have larger random delays when
> performing operations can be easily achieved in the following way.
> Take as example the function that starts the failover, that is
> called with a frequency between 10 and 20 HZ and will start the
> failover every time there are the conditions. By just adding as an
> additional condition something like rand()%4 == 0, we can amplify the
> desynchronization between Sentinel instances easily.

こちらからは以上です。
