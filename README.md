# Pulltorefresh_Swift

总觉得之前的 刷新控件不够用，所以就自己搞一个吧，addDefaultHeader/addDefaultFooter 用于添加默认的头，尾刷新视图。addGifHeader/addGifFooter可以添加带
gif的图，可以使gif，也可以是图片数组，   只有footer有个.noMoreData。用于提示用户，已经是最后的数据，不能再加载更多，比如可以用于评论，比较少时，设置次
状态，可以防止多次重复加载请求。当下拉更新，footer的状态会自动更新为 .wait。
示例代码在 CustomTableViewController中， 如果要自定义刷新视图，随便继承一个头/尾视图，重写 progress 可以做下拉或者上拉的动画进度。
