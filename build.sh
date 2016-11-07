#!/bin/bash -ex

git subtree pull --prefix=public git@github.com:kenjiskywalker/kenjiskywalker.org.git gh-pages
rm -rf ./public/
hugo
mv ./public/sitemap.xml ./public/atom.xml
cp ./CNAME ./public/CNAME
# git subtree push --prefix=public git@github.com:kenjiskywalker/kenjiskywalker.org.git gh-pages
