---
layout: post
title: "Ansible Vaultで暗号化されたファイルをCircleCIで利用する"
published: true
date: "2014-11-17T14:08:00+09:00"
comments: true


---

## TL;DR

CircleCIのEnvironment variablesを利用して  
ファイルにdecryptのパスワードを記入する


## 設定

- [Environment variables - CircleCI](https://circleci.com/docs/environment-variables)
- [Vault - Ansible](http://docs.ansible.com/playbooks_vault.html)


CircleCIの環境変数に値を設定する機能を利用し、  
テスト実行前にその環境変数に設定したVault用の  
パスワードをファイルに出力しておき、ansible実行時には  
そのファイルを見に行くようにする。  

- circle.yml

```
machine:
  services:
    - docker

dependencies:
  pre:
    - if [[ -e docker_ansible_image.tar ]]; then cat docker_ansible_image.tar | docker import - kenjiskywalker/dockerfile-centos-ansible ; docker load --input docker_ansible_image.tar ; else docker build . ; docker save -o docker_ansible_image.tar kenjiskywalker/dockerfile-centos-ansible ; fi
    - echo "${ANSIBLE_VAULT}" > $(pwd)/ansible/vault.txt

  cache_directories:
    - "docker_ansible_image.tar"

test:
  post:
    - docker run -v $(pwd)/ansible:/ansible kenjiskywalker/dockerfile-centos-ansible ansible-playbook /ansible/ci.yml  --vault-password-file /ansible/vault.txt -i /ansible/inventory_localhost -c local
```

他に良いプラクティスあれば教えてください。

