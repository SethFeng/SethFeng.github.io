title: Weex下拉刷新和加载更多
date: 2018-08-20 21:00:00
tags:
- weex
categories:
- Weex
---
下拉刷新和加载更多是列表页面常用功能。通过下拉页面的手势刷新页面，通过上啦到页面底部加载下一页内容。

## 相关Weex组件
- `<scroller>`
  当子组件高度超过一屏时，需要使用`scroller`包含所有子组件，以实现内容随手势滚动。（然而，实践证明，Web平台不加`scroller`也能滑动，Android和iOS是滑不动的）。`scroller`可包含任意类型子组件。不过，鉴于`scroller`在Android上布局性能问题，这个控件在子控件较多时谨慎使用。

<div >
  <img src="/assets/weex_scroller_android_layout.png" style="width: 50%;"></img>
</div>

- `<list>`和`<cell>`
  这就是我们常见的列表了。父组件用<list>，包含若干个<cell>子组件。`list`的子组件要求严格，只能包含`cell`/`header`/`refresh`/`loading`四种组件或是fix定位的组件。`cell`显示列表元素内容，`header`实现列表固定头部。
- `<refresh>`
  下拉刷新组件，一般放在`scroller`或`list`头部
- `<loading>`
  加载更多组件，一般放在`scroller`或`list`尾部

<!-- more -->

## 下拉刷新
下拉刷新通过`refresh`组件实现。示例：
```javascript
<template>
  <list>
    <refresh class="refresh" @refresh="onrefresh" @pullingdown="onpullingdown" :display="refreshing ? 'show' : 'hide'">
      <text class="indicator-text">Refreshing ...</text>
      <loading-indicator class="indicator"></loading-indicator>
    </refresh>
    <cell class="cell" v-for="num in lists">
      <div class="panel">
        <text class="text">{{num}}</text>
      </div>
    </cell>
  </list>
</template>

<script>
  const modal = weex.requireModule('modal')

  export default {
    data () {
      return {
        refreshing: false,
        lists: [1, 2, 3, 4, 5]
      }
    },
    methods: {
      onrefresh (event) {
        modal.toast({ message: 'Refreshing', duration: 1 })
        this.refreshing = true
        setTimeout(() => {
          this.lists = [6, 7, 8, 9, 0]
          this.refreshing = false
        }, 2000)
      },
      onpullingdown (event) {
        console.log("dy: " + event.dy)
        console.log("pullingDistance: " + event.pullingDistance)
        console.log("viewHeight: " + event.viewHeight)
        console.log("type: " + event.type)
      }
    }
  }
</script>

<style scoped>
  .refresh {
    width: 750;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
  .indicator-text {
    color: #888888;
    font-size: 42px;
    text-align: center;
  }
  .indicator {
    margin-top: 16px;
    height: 40px;
    width: 40px;
    color: blue;
  }
  .panel {
    width: 600px;
    height: 250px;
    margin-left: 75px;
    margin-top: 35px;
    margin-bottom: 35px;
    flex-direction: column;
    justify-content: center;
    border-width: 2px;
    border-style: solid;
    border-color: #DDDDDD;
    background-color: #F5F5F5;
  }
  .text {
    font-size: 50px;
    text-align: center;
    color: #41B883;
  }
</style>
```
`refresh`组件支持`refresh`和`pullingdown`事件。手势拖动时，`pullingdown`持续触发，松开手后形成完整的下拉刷新手势触发`refresh`事件。

## 加载更多
加载更多可以直接在`list`实现监听，也可以通过`loading`实现监听。
- 直接使用`list`
示例：
```javascript
<template>
  <list @loadmore="fetch" loadmoreoffset="10">
    <cell v-for="(num, i) in lists" :key="i">
      <div class="panel">
        <text class="text">{{num}}</text>
      </div>
    </cell>
  </list>
</template>

<script>
  const modal = weex.requireModule('modal')
  const LOADMORE_COUNT = 4

  export default {
    data () {
      return {
        lists: [1, 2, 3, 4, 5]
      }
    },
    methods: {
      fetch (event) {
        modal.toast({ message: 'loadmore', duration: 1 })

        setTimeout(() => {
          const length = this.lists.length
          for (let i = length; i < length + LOADMORE_COUNT; ++i) {
            this.lists.push(i + 1)
          }
        }, 800)
      }
    }
  }
</script>

<style scoped>
  .panel {
    width: 600px;
    height: 250px;
    margin-left: 75px;
    margin-top: 35px;
    margin-bottom: 35px;
    flex-direction: column;
    justify-content: center;
    border-width: 2px;
    border-style: solid;
    border-color: rgb(162, 217, 192);
    background-color: rgba(162, 217, 192, 0.2);
  }
  .text {
    font-size: 100px;
    text-align: center;
    color: #41B883;
  }
</style>
```

- 使用`loading`组件
示例：

```javascript
<template>
  <list>
    <cell class="cell" v-for="num in lists">
      <div class="panel">
        <text class="text">{{num}}</text>
      </div>
    </cell>
    <loading class="loading" @loading="onloading" :display="loadinging ? 'show' : 'hide'">
      <text class="indicator-text">Loading ...</text>
      <loading-indicator class="indicator"></loading-indicator>
    </loading>
  </list>
</template>

<script>
  const modal = weex.requireModule('modal')
  const LOADMORE_COUNT = 4

  export default {
    data () {
      return {
        loadinging: false,
        lists: [1, 2, 3, 4, 5]
      }
    },
    methods: {
      onloading (event) {
        modal.toast({ message: 'Loading', duration: 1 })
        this.loadinging = true
        setTimeout(() => {
          const length = this.lists.length
          for (let i = length; i < length + LOADMORE_COUNT; ++i) {
            this.lists.push(i + 1)
          }
          this.loadinging = false
        }, 2000)
      },
    }
  }
</script>

<style scoped>
  .loading {
    width: 750;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
  .indicator-text {
    color: #888888;
    font-size: 42px;
    text-align: center;
  }
  .indicator {
    margin-top: 16px;
    height: 40px;
    width: 40px;
    color: blue;
  }
  .panel {
    width: 600px;
    height: 250px;
    margin-left: 75px;
    margin-top: 35px;
    margin-bottom: 35px;
    flex-direction: column;
    justify-content: center;
    border-width: 2px;
    border-style: solid;
    border-color: #DDDDDD;
    background-color: #F5F5F5;
  }
  .text {
    font-size: 50px;
    text-align: center;
    color: #41B883;
  }
</style>
```

然而，在iOS中，加载到下一页数据UI刷新时抖动了。

<div>
  <video  width="50%" autoPlay="true" loop="true" style="display:block; margin: 0 auto;">
    <source src="/assets/weex_list_loading_ios_shake.mp4" type="video/mp4">
  Your browser does not support the video tag.
  </video>
</div>

去掉`loading`里的所有子组件就正常了。
如果要显示加载下一页的footer UI，就不要用`list` + `loading`了。自定义一个`cell`子组件吧。
```javascript
<template>
  <list @loadmore="onloading">
    <cell class="cell" v-for="num in lists">
      <div class="panel">
        <text class="text">{{num}}</text>
      </div>
    </cell>
    <cell class="loading">
      <text class="indicator-text">Loading ...</text>
    </cell>
  </list>
</template>

<script>
  const modal = weex.requireModule('modal')
  const LOADMORE_COUNT = 4

  export default {
    data () {
      return {
        loadinging: false,
        lists: [1, 2, 3, 4, 5]
      }
    },
    methods: {
      onloading (event) {
        modal.toast({ message: 'Loading', duration: 1 })
        this.loadinging = true
        setTimeout(() => {
          const length = this.lists.length
          for (let i = length; i < length + LOADMORE_COUNT; ++i) {
            this.lists.push(i + 1)
          }
          this.loadinging = false
        }, 2000)
      },
    }
  }
</script>

<style scoped>
  .loading {
    width: 750;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
  .indicator-text {
    color: #888888;
    font-size: 42px;
    text-align: center;
  }
  .panel {
    width: 600px;
    height: 250px;
    margin-left: 75px;
    margin-top: 35px;
    margin-bottom: 35px;
    flex-direction: column;
    justify-content: center;
    border-width: 2px;
    border-style: solid;
    border-color: #DDDDDD;
    background-color: #F5F5F5;
  }
  .text {
    font-size: 50px;
    text-align: center;
    color: #41B883;
  }
</style>
```

## 下拉刷新+加载更多
```javascript
<template>
  <list @loadmore="onloading">
    <refresh class="refresh" @refresh="onrefresh" :display="refreshing ? 'show' : 'hide'">
      <text class="indicator-text">Refreshing ...</text>
      <loading-indicator class="indicator"></loading-indicator>
    </refresh>
    <cell class="cell" v-for="num in lists">
      <div class="panel">
        <text class="text">{{num}}</text>
      </div>
    </cell>
    <cell class="loading">
      <text class="indicator-text">Loading ...</text>
    </cell>
  </list>
</template>

<script>
  const modal = weex.requireModule('modal')
  const LOADMORE_COUNT = 4

  export default {
    data () {
      return {
        refreshing: false,
        loadinging: false,
        lists: [1, 2, 3, 4, 5]
      }
    },
    methods: {
      onrefresh (event) {
        modal.toast({ message: 'Refreshing', duration: 1 })
        this.refreshing = true
        setTimeout(() => {
          this.lists = [6, 7, 8, 9, 0]
          this.refreshing = false
        }, 2000)
      },
      onloading (event) {
        modal.toast({ message: 'Loading', duration: 1 })
        this.loadinging = true
        setTimeout(() => {
          const length = this.lists.length
          for (let i = length; i < length + LOADMORE_COUNT; ++i) {
            this.lists.push(i + 1)
          }
          this.loadinging = false
        }, 2000)
      },
    }
  }
</script>

<style scoped>
  .refresh {
    width: 750;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
  .indicator-text {
    color: #888888;
    font-size: 42px;
    text-align: center;
  }
  .indicator {
    margin-top: 16px;
    height: 40px;
    width: 40px;
    color: blue;
  }
  .loading {
    width: 750;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
  .panel {
    width: 600px;
    height: 250px;
    margin-left: 75px;
    margin-top: 35px;
    margin-bottom: 35px;
    flex-direction: column;
    justify-content: center;
    border-width: 2px;
    border-style: solid;
    border-color: #DDDDDD;
    background-color: #F5F5F5;
  }
  .text {
    font-size: 50px;
    text-align: center;
    color: #41B883;
  }
</style>
```
然而，加载更多一次后再下拉刷新一次，iOS又出现了刷新抖动。滑动到底部，web端正常，Android和iOS却无法触发加载更多了。去除`refresh`组件里的所有子组件，可以解决抖动问题。官方提供了`list`重置加载更多的方法`resetLoadmore`，每次下拉刷新后重置一下，下次加载更多即可触发。
```javascript
<template>
  <list ref="list" @loadmore="onloading" loadmoreoffset="10">
    <refresh class="refresh" @refresh="onrefresh" :display="refreshing ? 'show' : 'hide'">
    </refresh>
    <cell class="cell" v-for="num in lists">
      <div class="panel">
        <text class="text">{{num}}</text>
      </div>
    </cell>
    <cell class="loading">
      <text class="indicator-text">Loading ...</text>
    </cell>
  </list>
</template>

<script>
  const modal = weex.requireModule('modal')
  const LOADMORE_COUNT = 4

  export default {
    data () {
      return {
        refreshing: false,
        loadinging: false,
        lists: [1, 2, 3, 4, 5]
      }
    },
    methods: {
      onrefresh (event) {
        modal.toast({ message: 'Refreshing', duration: 1 })
        this.refreshing = true
        setTimeout(() => {
          this.lists = [6, 7, 8, 9, 0]
          this.refreshing = false
          this.$refs.list.resetLoadmore
        }, 2000)
      },
      onloading (event) {
        modal.toast({ message: 'Loading', duration: 1 })
        this.loadinging = true
        setTimeout(() => {
          const length = this.lists.length
          for (let i = length; i < length + LOADMORE_COUNT; ++i) {
            this.lists.push(i + 1)
          }
          this.loadinging = false
        }, 2000)
      },
    }
  }
</script>

<style scoped>
  .refresh {
    width: 750;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
  .indicator-text {
    color: #888888;
    font-size: 42px;
    text-align: center;
  }
  .loading {
    width: 750;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
  .panel {
    width: 600px;
    height: 250px;
    margin-left: 75px;
    margin-top: 35px;
    margin-bottom: 35px;
    flex-direction: column;
    justify-content: center;
    border-width: 2px;
    border-style: solid;
    border-color: #DDDDDD;
    background-color: #F5F5F5;
  }
  .text {
    font-size: 50px;
    text-align: center;
    color: #41B883;
  }
</style>
```
这样，虽然有了下拉刷新和加载更多功能，却没有了下拉刷新的UI。
本想像自定义footer一样自定义一个`cell`作为下拉刷新的UI，但刷新时UI却抖动了。如有完美方案，还请赐教。