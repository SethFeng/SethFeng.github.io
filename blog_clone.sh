#!/bin/bash

# git clone git@github.com:SethFeng/sethfeng.github.io.git
# cd sethfeng.github.io
git checkout source
npm install hexo-cli -g
hexo init temp
mv temp/node_modules .
mv temp/package.json .
sleep 3
rm -rf temp
git clone https://github.com/iissnan/hexo-theme-next themes/next
hexo clean
hexo g
hexo s
