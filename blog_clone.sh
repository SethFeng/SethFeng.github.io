#!/bin/bash

# git clone git@github.com:SethFeng/sethfeng.github.io.git
# cd sethfeng.github.io
git checkout source
npm install hexo --save
hexo init temp
mv temp/node_modules .
hexo install hexo-deployer-git --save
sleep 3
rm -rf temp
git clone https://github.com/iissnan/hexo-theme-next themes/next
hexo g
hexo s
