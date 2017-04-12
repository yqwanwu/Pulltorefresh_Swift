//
//  RefreshView.swift
//  reuseTest
//
//  Created by wanwu on 2017/4/10.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit


enum PullToRefreshState: Int {
    ///  刷新中，    开始拉动， 结束， 拉动中， 普通状态,   拉满     
    case refreshing, begin, end, pulling, wait, pullingComplate
}

enum PullToRefreshType: Int {
    case header, footer
}

class PullToRefreshView: UIView, UIScrollViewDelegate {
    weak var scrollView: UIScrollView!
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    var originalTop: CGFloat = 0.0
    var originalBottom: CGFloat = 0.0
    
    ///当滑动到底部时自动加载，不需要上拉，仅对上拉加载有效
    var autoLoadWhenIsBottom = true
    
    private var actions = [PullToRefreshState:() -> Void]()
    
    var refreshHeight: CGFloat = 100.0
    ///头部距离下边 或 底部距离上边的距离
    var margin: CGFloat = 10
    var type = PullToRefreshType.header
    var state: PullToRefreshState = .wait {
        didSet {
            if oldValue != state {
                switch state {
                case .refreshing:
                    whenRefreshing()
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
        self.originalTop = self.scrollView.contentInset.top
        self.originalBottom = self.scrollView.contentInset.bottom
    }
    
    ///add actions
    @discardableResult
    func addAction(with state: PullToRefreshState, action: @escaping () -> Void) -> Self {
        actions[state] = action
        return self
    }
    
    func whenRefreshing() {
        if type == .header {
            scrollView.contentInset.top = refreshHeight + originalTop
        } else {
            scrollView.contentInset.bottom = refreshHeight + originalBottom
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
        })
        self.state = .end
    }
    
    func beginRefresh() {
        self.state = .refreshing
        UIView.animate(withDuration: 0.6, animations: {
            if self.type == .header {
                self.scrollView.contentOffset.y = -(self.refreshHeight + self.originalTop)
            } else {
                self.scrollView.contentOffset.y  = self.scrollView.contentSize.height + self.scrollView.contentInset.bottom + self.refreshHeight - self.scrollView.contentInset.top - self.scrollView.frame.height
            }
        }, completion: { (f) in
            
        })
    }
    
    deinit {
        print(" 刷新视图死了 ")
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
    ///修改此属性更改提示信息， 前提是写得有
    var titles: [PullToRefreshState:String] = [.pulling:"下拉刷新", .pullingComplate:"松开刷新", .refreshing:"更新中...", .end:"完成"]
    
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
            animationForPullinf()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let ratio: CGFloat = 0.34
        let centerY = frame.height - margin - progressViewWidth / 2
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: frame.width * (1 - ratio), height: 60)
        titleLabel.center = CGPoint(x: self.frame.width / 2, y: centerY)
        progressView.center = CGPoint(x: ratio * frame.width - progressViewWidth / 2, y: centerY)
    }
    
    func animationForPullinf() {
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
        super.endRefresh(completion: {
            self.progressView.isHidden = false
            self.activityIndicator.stopAnimating()
        })
        self.activityIndicator.isHidden = true
    }
}



class PullToRefreshDefaultFooter: PullToRefreshView {
    lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.adjustsFontSizeToFitWidth = true
        l.text = "上拉加载更多"
        l.textAlignment = .center
        l.textColor = UIColor.gray
        return l
    }()
    
    required convenience init(frame: CGRect, scrollView: UIScrollView) {
        self.init(frame: frame)
        self.scrollView = scrollView
        self.refreshHeight = frame.height
        self.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        self.addSubview(titleLabel)
        self.addSubview(progressView)
        
        self.type = .footer
    }
    
    var progressViewWidth: CGFloat = 30
    ///修改此属性更改提示信息， 前提是写得有
    var titles: [PullToRefreshState:String] = [.pulling:"上拉加载更多", .pullingComplate:"松开加载", .refreshing:"加载中...", .end:"完成"]
    
    lazy var progressView: CircleProgressView = {
        let c = CircleProgressView(frame: CGRect(x: 0, y: 0, width: self.progressViewWidth, height: self.progressViewWidth))
        c.progress = 0
        c.changeWithTimer = false
        c.tipLabel.isHidden = true
        c.lineWidth = 2
        c.circleColor = UIColor.blue
        return c
    } ()
    
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
        let centerY = margin + progressViewWidth / 2
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: frame.width * (1 - ratio), height: 60)
        titleLabel.center = CGPoint(x: self.frame.width / 2, y: centerY)
        progressView.center = CGPoint(x: ratio * frame.width - progressViewWidth / 2, y: centerY)
        
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
        super.endRefresh(completion: {
            self.progressView.isHidden = false
            self.activityIndicator.stopAnimating()
        })
        self.activityIndicator.isHidden = true
    }
    
}






