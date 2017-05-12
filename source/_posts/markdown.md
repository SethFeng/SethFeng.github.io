title: 常用Markdown语法
date: 2015-12-23 19:11:23
tags: [blog, markdown]
categories: Language
---
Markdown语法还是比较简单的。经常使用的有：
# 目录
目录的层级使用1-6个`#`，分别相当于HTML里的H1-H6。一般可用一个`# content`表示一级标题。
# 斜体
一颗星：
`*content*` *content*

<!-- more -->

# 加粗 
两颗星：
`**content**` **content** 

# 斜体并加粗
你猜对了，三颗星：
`***content***` ***content***

# 文本片段
文本片段可把重要句内关键词强调出来。如文件名、代码中类名。
段内文本片段可使用
```
这个类`FragmentActivity`很重要。
```
效果为：
这个类`FragmentActivity`很重要。

# 引用
`> content` 
> 某位伟人的名句

# 列表
列表分为有标号列表和无标号列表。

有标号列表使用`标号. 内容`：
```
1. a
2. b
3. c
```
效果为：
1. a
2. b
3. c

不同的主题把Mardown文件转化成的网页效果可能不一样，有的主题支持有标号列表写法：
```
1. a
- b
- c
```
也会达成上面的效果。不过，写作时还是尽量使用最标准的格式。

无标号列表使用`- 内容`：
```
- a
- b
- c
```
效果为：
- a
- b
- c

# 超链接
- 文本
  格式：`[content](link)`
  `[我的博客](sethfeng.github.io)`
  [我的博客](sethfeng.github.io)
- 图片
  格式：`![content](link)`
  `![我的头像](http://tp3.sinaimg.cn/1795496090/50/5744214883/1)`
  ![](http://tp3.sinaimg.cn/1795496090/50/5744214883/1)
  `[]`里的content貌似没个卵用。

# 表格
表格不是Markdown的强项，用法也是Markdown里最复杂的了。简单的表格格式如下：
```
| name       | age  |    sex |
| ---------- | :--: | -----: |
| Li Lei     |  20  |   male |
| Han Meimei |  18  | female |
```
| name       | age  |    sex |
| ---------- | :--: | -----: |
| Li Lei     |  20  |   male |
| Han Meimei |  18  | female |
如果简单表格不能满足需求，还是想想办法用HTML或者图片代替吧。

# 流程图
## flowchart

## sequence