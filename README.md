# Pulltorefresh_Swift

总觉得之前的 刷新控件不够用，所以就自己搞一个吧，addDefaultHeader/addDefaultFooter 用于添加默认的头，尾刷新视图。addGifHeader/addGifFooter可以添加带
gif的图，可以使gif，也可以是图片数组，   只有footer有个.noMoreData。用于提示用户，已经是最后的数据，不能再加载更多，比如可以用于评论，比较少时，设置次
状态，可以防止多次重复加载请求。当下拉更新，footer的状态会自动更新为 .wait。
示例代码在 CustomTableViewController中， 如果要自定义刷新视图，随便继承一个头/尾视图，重写 progress 可以做下拉或者上拉的动画进度。



压缩gif时不小心留下了他们的水印
基本的接口用的是链式，所以可以直接连续的用“.”语法, config属于可选值。在这里面可以进行配置具体样式，demo中都是在cell数目大于40条后设置上拉只提示，不加载，模拟数据已请求完成
### 默认的视图：
`p = PullToRefreshControl(scrollView: tableView).addDefaultHeader(config: { (header) in`
            `header.titleLabel.textColor = UIColor.red`
        `}).addDefaultFooter()`

![](https://github.com/yqwanwu/Pulltorefresh_Swift/blob/master/Pulltorefresh_Swift/default.gif)

其中：setImgArr(state: .refreshing, imgs: imgArr, animationTime: 2.0)， 在拉动过程中，设置animationTime就是自动播放，不设置的话，就根据进度播放对应的图片数组的图片

![](https://github.com/yqwanwu/Pulltorefresh_Swift/blob/master/Pulltorefresh_Swift/gif.gif)

addDefaultHeader/addDefaultFooter 用于添加默认的头，尾刷新视图。addGifHeader/addGifFooter可以添加带 gif的图，可以使gif，也可以是图片数组， 只有footer有个.noMoreData。用于提示用户，已经是最后的数据，不能再加载更多，比如可以用于评论，比较少时，设置次 状态，可以防止多次重复加载请求。当下拉更新，footer的状态会自动更新为 .wait。 示例代码在 CustomTableViewController中， 如果要自定义刷新视图，随便继承一个头/尾视图，重写 progress 可以做下拉或者上拉的动画进度。
