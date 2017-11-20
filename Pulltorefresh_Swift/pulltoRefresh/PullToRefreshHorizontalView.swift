//
//  PullToRefreshHorizontalView.swift
//  Pulltorefresh_Swift
//
//  Created by wanwu on 2017/11/20.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class PullToRefreshHorizontalView: PullToRefreshView {
    
    var originalLeft: CGFloat = 0.0
    var originalRight: CGFloat = 0.0
    
    override var type: PullToRefreshType {
        didSet {
            if type == .footer {
                titles = [.pulling:"左拉加载更多", .pullingComplate:"松开加载", .refreshing:"加载中...", .end:"完成", .noMoreData:"没有更多数据"]
            } else {
                titles = [.pulling:"右边拉刷新", .pullingComplate:"松开刷新", .refreshing:"更新中...", .end:"完成"]
            }
        }
    }
    
    required convenience init(frame: CGRect, scrollView: UIScrollView) {
        self.init(frame: frame)
        self.scrollView = scrollView
        self.refreshHeight = frame.width
        //横向的距离较短，不需要延迟
        self.margin = 4
        self.marginDely = 5
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
    
    ///刷新中
    override func whenRefreshing() {
        self.originalLeft = self.scrollView.contentInset.left
        self.originalRight = self.scrollView.contentInset.right
        if type == .header {
            scrollView.contentInset.left = refreshHeight + originalLeft
        } else {
            var blank: CGFloat = 0.0
            if scrollView.contentSize.width < scrollView.frame.width {
                blank = scrollView.frame.width - scrollView.contentSize.width
            }
            scrollView.contentInset.right = refreshHeight + originalRight + blank
        }
    }
    
    override func endRefresh(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.6, animations: {
            if self.type == .header {
                self.scrollView.contentInset.left = self.originalLeft
            } else {
                self.scrollView.contentInset.right = self.originalRight
            }
        }, completion: { (f) in
            completion?()
            self.isHidden = self.hideWhenComplete
        })
        self.state = .end
    }
    
    override func beginRefresh() {
        self.originalLeft = self.scrollView.contentInset.left
        self.originalRight = self.scrollView.contentInset.right
        if state == .noMoreData {
            return
        }
        self.state = .refreshing
        
        UIView.animate(withDuration: 0.6, animations: {
            if self.type == .header {
                self.scrollView.contentOffset.x = -(self.refreshHeight + self.originalLeft) //- self.scrollView.contentInset.top
            } else {
                if self.scrollView.contentSize.width < self.scrollView.frame.width {
                    self.scrollView.contentOffset.x = self.refreshHeight + self.originalRight
                } else {
                    self.scrollView.contentOffset.x = max(self.scrollView.contentSize.width, self.scrollView.frame.width) + self.originalRight + self.refreshHeight - self.scrollView.contentInset.left - self.scrollView.frame.width
                }
            }
        }, completion: { (f) in
            
        })
    }
    
    deinit {
        debugPrint(" 刷新视图死了 ")
    }
}



class PullToRefreshDefaultHorizontalHeader: PullToRefreshHorizontalView {
    lazy var titleLabel: UILabel = {
        let l = UILabel()
//        l.adjustsFontSizeToFitWidth = true
        l.text = "左拉刷新"
        l.textColor = UIColor.gray
        l.textAlignment = .center
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 13)
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
        self.refreshHeight = frame.width
        self.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        self.type = .header
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
        
        let ratio: CGFloat = 0.24
        let centerX = progressViewWidth / 2 + 4
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: 17, height: frame.height * (1 - ratio))
        titleLabel.center = CGPoint(x: centerX, y: self.frame.height / 2)
        progressView.center = CGPoint(x: centerX, y: ratio * frame.height - progressViewWidth / 2)
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



class PullToRefreshDefaultHorizontalFooter: PullToRefreshDefaultHorizontalHeader {
    
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
        self.refreshHeight = frame.width
        self.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        self.addSubview(titleLabel)
        self.addSubview(progressView)
        
        self.type = .footer
        titles = [.pulling:"左拉加载更多", .pullingComplate:"松开加载", .refreshing:"加载中...", .end:"完成", .noMoreData:"没有更多数据"]
    }
}
