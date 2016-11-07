---
layout: post
title: "CircleCIでDockerコンテナに対してansibleを実行しserverspecでテストをする"
published: true
date: "2014-11-13T21:11:00+09:00"
comments: true


---

### 参考

[KAIZEN platform Inc. における運用自動化 - Speaker Deck](https://speakerdeck.com/naoya/kaizen-platform-inc-niokeruyun-yong-zi-dong-hua)  
[Continous Integration and Delivery with Docker - CircleCI](https://circleci.com/docs/docker)

## TL;DR

CircleCI上でDockerコンテナを立て、  
そのコンテナに対してプロビジョニングを行い、  
プロビジョニング後のコンテナに対してテストを行う

## DockerコンテナにAnsibleを実行する

コミットする度にDockerのimageをpullするのは時間がもったいないので  
`cache_directories`を利用し、imageをexportしておき  
実行時にimportするようにすると多少速くなる。

```
.
├── Dockerfile
├── ansible/
└── circle.yml
```

- Dockerfile

```
FROM kenjiskywalker/dockerfile-centos-ansible
```


- circle.yml

```
machine:
  services:
    - docker

dependencies:
  pre:
    - if [[ -e docker_ansible_image.tar ]]; then cat docker_ansible_image.tar | docker import - kenjiskywalker/dockerfile-centos-ansible ; docker load --input docker_ansible_image.tar ; else docker build . ; docker save -o docker_ansible_image.tar kenjiskywalker/dockerfile-centos-ansible ; fi

  cache_directories:
    - "docker_ansible_image.tar"

test:
  post:
    - docker run -v `pwd`/ansible:/ansible kenjiskywalker/dockerfile-centos-ansible ansible-playbook /ansible/ci.yml -i /ansible/inventory_localhost -c local
```

こんな感じの設定ファイルを置いておくと`ansible`ディレクトリをマウントし  
Dockerコンテナがansibleを実行できる状態であればDockerコンテナに対して  
ansibleが実行できる。この続きにServerspecを記述することで  

1. リポジトリにansibleのファイルをコミットする
2. CircleCI上にてDockerコンテナを起動
3. Dockerコンテナに対してansibleでプロビジョニング
4. そのプロビジョニング結果をServerspecでテストをする

のようなことができる。  

## wercker

werckerでも同じようなことができる。  
CircleCIと同様にファイルをキャッシュするには  
`$WERCKER_CACHE_DIR`を利用すればよいかと。


- wercker.yml

```
box: wercker-labs/docker
build:
  steps:
    - script:
        name: docker build
        code: docker build .
    - script:
        name: docker run
        code: docker run -v `pwd`/ansible:/ansible dockerfile/ansible ansible-playbook /ansible/ci.yml -i /ansible/inventory_localhost -c local
```

以上、メモです。
