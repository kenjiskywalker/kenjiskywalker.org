---
layout: post
title: "EC2のバージョン上げる時にreleasever=latestになってないとバージョン上がらなかった"
published: false
date: "2013-04-03T12:12:00+09:00"
comments: true


---

入れないとアップグレードできなかった

```
releasever=latest
```

```
[root@kr-quiz-admin01 ~]#
[root@kr-quiz-admin01 ~]# yum install mosh
Loaded plugins: etckeeper, priorities, security, update-motd, upgrade-helper
574 packages excluded due to repository priority protections
Setting up Install Process
Resolving Dependencies
--> Running transaction check
---> Package mosh.x86_64 0:1.2.3-1.el6 will be installed
--> Processing Dependency: libprotobuf.so.6()(64bit) for package: mosh-1.2.3-1.el6.x86_64
--> Finished Dependency Resolution
Error: Package: mosh-1.2.3-1.el6.x86_64 (epel)
           Requires: libprotobuf.so.6()(64bit)
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
[root@kr-quiz-admin01 ~]#
```

```
===================================================================================================================================================================================================================================
Installing:
 mosh                                                   x86_64                                               1.2.3-1.el6                                                  epel                                               211 k
Installing for dependencies:
 protobuf                                               x86_64                                               2.3.0-7.el6                                                  epel                                               287 k

Transaction Summary
===================================================================================================================================================================================================================================
Install       2 Package(s)
```
