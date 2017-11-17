//
//  RefreshView.swift
//  reuseTest
//
//  Created by wanwu on 2017/4/10.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit
import WebKit


enum PullToRefreshState: Int {
    ///  刷新中，    开始拉动， 结束， 拉动中， 普通状态,   拉满
    case refreshing, begin, end, pulling, wait, pullingComplate, noMoreData
}

enum PullToRefreshType: Int {
    case header, footer
}

class PullToRefreshView: UIView, UIScrollViewDelegate {
    weak var scrollView: UIScrollView!
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    var originalTop: CGFloat = 0.0
    var originalBottom: CGFloat = 0.0
    var hideWhenComplete = true
    
    ///当滑动到底部时自动加载，不需要上拉，仅对上拉加载有效
    var autoLoadWhenIsBottom = true
    
    private var actions = [PullToRefreshState:() -> Void]()
    
    var refreshHeight: CGFloat = 100.0
    ///修改此属性更改提示信息， 前提是写得有
    var titles: [PullToRefreshState:String] = [.pulling:"下拉刷新", .pullingComplate:"松开刷新", .refreshing:"更新中...", .end:"完成"]
    
    ///头部距离下边 或 底部距离上边的距离
    var margin: CGFloat = 10
    
    var marginDely: CGFloat = 10
    
    var type = PullToRefreshType.header {
        didSet {
            if type == .footer {
                titles = [.pulling:"上拉加载更多", .pullingComplate:"松开加载", .refreshing:"加载中...", .end:"完成", .noMoreData:"没有更多数据"]
            }
        }
    }
    var state: PullToRefreshState = .wait {
        didSet {
            //特殊标记
            if state == .noMoreData {
                return
            }
            
            if oldValue != state {
                switch state {
                case .refreshing:
                    whenRefreshing()
                    self.isHidden = false
                case .begin:
                    self.originalTop = self.scrollView.contentInset.top
                    self.originalBottom = self.scrollView.contentInset.bottom
                default:
                    break
                }
                
                if let action = actions[state] {
                    action()
                }
            }
        }
    }
    
    //头，尾视图显示进度
    var progress: CGFloat = 0.0
    
    required convenience init(frame: CGRect, scrollView: UIScrollView) {
        self.init(frame: frame)
        self.scrollView = scrollView
        self.refreshHeight = frame.height
    }
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.isHidden = hideWhenComplete && state != .refreshing
        scrollView.addSubview(self)
    }
    
    ///add actions
    @discardableResult
    func addAction(with state: PullToRefreshState, action: @escaping () -> Void) -> Self {
        actions[state] = action
        return self
    }
    
    ///刷新中
    func whenRefreshing() {
        if type == .header {
            scrollView.contentInset.top = refreshHeight + originalTop
        } else {
            var blank: CGFloat = 0.0
            if scrollView.contentSize.height < scrollView.frame.height {
                blank = scrollView.frame.height - scrollView.contentSize.height
            }
            scrollView.contentInset.bottom = refreshHeight + originalBottom + blank
        }
    }
    
    func endRefresh(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.6, animations: {
            if self.type == .header {
                self.scrollView.contentInset.top = self.originalTop
            } else {
                self.scrollView.contentInset.bottom = self.originalBottom
            }
        }, completion: { (f) in
            completion?()
            self.isHidden = self.hideWhenComplete
        })
        self.state = .end
    }
    
    func beginRefresh() {
        self.originalTop = self.scrollView.contentInset.top
        self.originalBottom = self.scrollView.contentInset.bottom
        if state == .noMoreData {
            return
        }
        self.state = .refreshing
        
        UIView.animate(withDuration: 0.6, animations: {
            if self.type == .header {
                self.scrollView.contentOffset.y = -(self.refreshHeight + self.originalTop) //- self.scrollView.contentInset.top
            } else {
                if self.scrollView.contentSize.height < self.scrollView.frame.height {
                    self.scrollView.contentOffset.y = self.refreshHeight + self.originalBottom
                } else {
                    self.scrollView.contentOffset.y = max(self.scrollView.contentSize.height, self.scrollView.frame.height) + self.originalBottom + self.refreshHeight - self.scrollView.contentInset.top - self.scrollView.frame.height
                }
            }
        }, completion: { (f) in
            
        })
    }
    
    deinit {
        debugPrint(" 刷新视图死了 ")
    }
}


class PullToRefreshDefaultHeader: PullToRefreshView {
    lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.adjustsFontSizeToFitWidth = true
        l.text = "下拉刷新"
        l.textColor = UIColor.gray
        l.textAlignment = .center
        return l
    }()
    
    var progressViewWidth: CGFloat = 30
    
    lazy var progressView: CircleProgressView = {
        let c = CircleProgressView(frame: CGRect(x: 0, y: 0, width: self.progressViewWidth, height: self.progressViewWidth))
        c.progress = 0
        c.changeWithTimer = false
        c.tipLabel.isHidden = true
        c.lineWidth = 2
        c.circleColor = UIColor.blue
        return c
    } ()
    
    required convenience init(frame: CGRect, scrollView: UIScrollView) {
        self.init(frame: frame)
        self.scrollView = scrollView
        self.refreshHeight = frame.height
        self.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        
        self.addSubview(titleLabel)
        self.addSubview(progressView)
    }
    
    override var state: PullToRefreshState {
        didSet {
            if state != oldValue {
                titleLabel.text = titles[state]
            }
        }
    }
    
    override var progress: CGFloat {
        didSet {
            animationForPulling()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let ratio: CGFloat = 0.34
        let centerY = frame.height - margin - progressViewWidth / 2
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: frame.width * (1 - ratio), height: 60)
        titleLabel.center = CGPoint(x: self.frame.width / 2, y: centerY)
        progressView.center = CGPoint(x: ratio * frame.width - progressViewWidth / 2, y: centerY)
        activityIndicator.center = progressView.center
    }
    
    func animationForPulling() {
        progressView.progress = Double(self.progress)
    }
    
    override func whenRefreshing() {
        super.whenRefreshing()
        self.progressView.isHidden = true
        self.activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.center = progressView.center
    }
    
    override func endRefresh(completion: (() -> Void)? = nil) {
        super.endRefresh()
        self.progressView.isHidden = false
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}



class PullToRefreshDefaultFooter: PullToRefreshDefaultHeader {
    
    override var state: PullToRefreshState {
        didSet {
            if state == .noMoreData {
                self.activityIndicator.isHidden = true
                self.progressView.isHidden = true
            }
        }
    }
    
    required convenience init(frame: CGRect, scrollView: UIScrollView) {
        self.init(frame: frame)
        self.scrollView = scrollView
        self.refreshHeight = frame.height
        self.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        self.addSubview(titleLabel)
        self.addSubview(progressView)
        
        self.type = .footer
        titles = [.pulling:"上拉加载更多", .pullingComplate:"松开加载", .refreshing:"加载中...", .end:"完成", .noMoreData:"没有更多数据"]
    }
}

class PullToRefreshGifItem: NSObject {
    var imgDataArr = [UIImage]()
    var gifData: Data?
    var animationTime = 0.0
    var isGif = false
    
    init(imgDataArr: [UIImage], animationTime: Double?) {
        super.init()
        self.imgDataArr = imgDataArr
        self.animationTime = animationTime ?? 0.0
    }
    
    init(gifData: Data) {
        super.init()
        self.gifData = gifData
        self.isGif = true
    }
}

class PullToRefreshDefaultGifHeader: PullToRefreshDefaultHeader {
    fileprivate let gifImgArrView = UIImageView()
    fileprivate let gifView = WKWebView()
    
    fileprivate var gifItem = [PullToRefreshState:PullToRefreshGifItem]()
    
    override var state: PullToRefreshState {
        didSet {
            if oldValue != state {
                //                gifImgArrView.stopAnimating()
            }
        }
    }
    
    var gifFrame = CGRect.zero {
        didSet {
            gifImgArrView.frame = gifFrame
            gifView.frame = gifFrame
        }
    }
    
    override var progress: CGFloat {
        didSet {
            if oldValue != progress {
                if let item = gifItem[state], state == .pulling {
                    showGifImg(item: item)
                }
            }
        }
    }
    
    func showGifImg(item: PullToRefreshGifItem) {
        gifView.isHidden = !item.isGif
        gifImgArrView.isHidden = item.isGif
        
        if item.isGif {
            if let gifData = gifItem[state]?.gifData {
                
                if #available(iOS 9.0, *) {
                    gifView.load(gifData, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: ""))
                } else {
                    //为了支持ios8，改为base64
                    let base64 = "<img src=\"data:image/gif;base64," + gifData.base64EncodedString() + "\"/>"
                    gifView.loadHTMLString(base64, baseURL: URL(fileURLWithPath: ""))
                }
            }
            gifImgArrView.stopAnimating()
        } else {
            if item.imgDataArr.count > 0 {
                gifImgArrView.stopAnimating()
                
                if item.animationTime > 0 {
                    gifImgArrView.animationDuration = item.animationTime
                    gifImgArrView.animationImages = item.imgDataArr
                    gifImgArrView.animationRepeatCount = Int.max
                    gifImgArrView.startAnimating()
                } else {
                    let index = Int(progress * CGFloat(item.imgDataArr.count - 1))
                    gifImgArrView.image = item.imgDataArr[index]
                }
            }
        }
    }
    
    override func whenRefreshing() {
        super.whenRefreshing()
        
        if let item = gifItem[state], state == .refreshing {
            activityIndicator.isHidden = true
            showGifImg(item: item)
        }
    }
    
    /** 不设置time，就根据 progress 进度做动画，一般用于 拉动过程 */
    @discardableResult
    func setImgArr(state: PullToRefreshState, imgs: [UIImage], animationTime: Double? = nil) -> Self {
        gifItem[state] = PullToRefreshGifItem(imgDataArr: imgs, animationTime: animationTime)
        return self
    }
    
    @discardableResult
    func setGifData(state: PullToRefreshState, gifData: Data) -> Self {
        gifItem[state] = PullToRefreshGifItem(gifData: gifData)
        
        return self
    }
    
    required convenience init(frame: CGRect, scrollView: UIScrollView) {
        self.init(frame: frame)
        self.scrollView = scrollView
        self.refreshHeight = frame.height
        self.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        
        self.addSubview(titleLabel)
        self.addSubview(gifImgArrView)
        self.addSubview(gifView)
        gifView.sizeToFit()
        gifImgArrView.contentMode = .scaleAspectFill
        gifImgArrView.clipsToBounds = true
    }
    
}

class PullToRefreshDefaultGifFooter: PullToRefreshDefaultGifHeader {
    override var state: PullToRefreshState {
        didSet {
            if state == .noMoreData {
                self.activityIndicator.isHidden = true
                self.progressView.isHidden = true
                self.gifImgArrView.isHidden = true
                self.gifView.isHidden = true
            }
        }
    }
    
    required convenience init(frame: CGRect, scrollView: UIScrollView) {
        self.init(frame: frame)
        
        self.scrollView = scrollView
        self.refreshHeight = frame.height
        self.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        
        self.addSubview(titleLabel)
        self.addSubview(gifImgArrView)
        self.addSubview(gifView)
        gifView.sizeToFit()
        gifImgArrView.contentMode = .scaleAspectFill
        gifImgArrView.clipsToBounds = true
        
        self.type = .footer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame.origin.y = 0
    }
}



