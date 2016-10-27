title: 使用Hexo生成博客
date: 2015-12-23 19:47:47
tags: [blog, hexo]
categories: Tools
---
Markdown对于写博客简直利器，在写之前心里就已经有了样式。有了语法支持，让程序员更激动的以为写作就是在Coding。
要将Markdown文件发布到博客，得转化成HTML。Hexo就是一个非常容易使用的工具。
#### 安装Hexo
```
npm install hexo-cli -g
```

<!-- more -->

#### 新建一个博客
```
hexo init blog
cd blog
npm install
```
#### 新建一篇文章
```
hexo new first-blog
```
新建的md文件路径在`source/_post/first-blog.md`。
#### 编辑文章
使用自己喜欢的Markdown编辑器修改first-blog.md。当然，一般的文本编辑器也是可以的。个人使用到较多的是[Sublime](http://www.sublimetext.com)编辑，使用[**typora**](http://www.typora.io)预览、转PDF。
#### 生成Html
```
hexo generate
```
可简写成：
```
hexo g
```
#### 部署本地服务器
```
hexo server
```
同：
```
hexo s
```
浏览器可输入`http://0.0.0.0:4000`浏览本地网站了。
#### 部署到服务器
如果自己有HTTP服务器，可以将博客发布上去。配置github账号信息，可以部署到自己的`github.io`博客。
```
hexo deploy
```
同：
```
hexo d
```

#### 其它常用命令
- hexo list post
- hexo clean

#### Tips
- 使用主题可以让博客更有趣，如[**yilia**](https://github.com/litten/hexo-theme-yilia)。
- md文件名称中文可能导致`hexo g`出错，文件命名最好用英文，如`first-blog.md`。
- 头部无`date`每次生成的都是当前生成网页的时间，会造成博客不按照时间顺序。
- 把文章关键词提取添加到`tag`，可以生成以tags为索引的文章目录列表。单个tag可直接赋值，多个tag需用`[]`或者`-`。
单个tags：
```
tags: one
```
多个tags：
```
tags: [one, two, three]
```
或者：
```
tags:
- one
- two
- three
```
当然，单个tag也可用多个tag的书写格式，如`tags: [one]`
- 声明文章的分类`catagories`，可以生成以catagories为索引的文章目录列表。书写格式同tag。
- 附件可在`source/`下新建一个目录专门存放，如`source/assets/blog.png`，部署到github后路径为`http://yourname.github.io/assets/blog.png`
- 博客首页文章预览默认显示整篇，在每篇文章截断处使用`<!-- more -->`标识。