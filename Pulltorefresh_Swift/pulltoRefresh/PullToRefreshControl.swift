//
//  PullToRefreshTool.swift
//  reuseTest
//
//  Created by wanwu on 2017/4/11.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

/**
 *  header和footer只可以添加一个，后面的覆盖前面的
 */
class PullToRefreshControl: NSObject {
    var header: PullToRefreshView?
    var footer: PullToRefreshView?
    var scrollView: UIScrollView!
    
    convenience init(scrollView: UIScrollView) {
        self.init()
        self.scrollView = scrollView
        
        setup()
    }
    
    //MARK: 横向
    @discardableResult
    func addDefaultHorizontalHeader(config: ((_ header: PullToRefreshDefaultHorizontalHeader) -> Void)? = nil) -> Self {
        let x = -scrollView.contentInset.left - 40
        header = PullToRefreshDefaultHorizontalHeader(frame: CGRect(x: x, y: 0, width: 40, height: scrollView.frame.height), scrollView: scrollView)
        scrollView.insertSubview(header!, at: 0)
        config?(header as! PullToRefreshDefaultHorizontalHeader)
        return self
    }
    
    @discardableResult
    func addDefaultHorizontalFooter(config: ((_ footer: PullToRefreshDefaultHorizontalFooter) -> Void)? = nil) -> Self {
        let width = max(scrollView.contentSize.width, scrollView.frame.width)
        let x = width + scrollView.contentInset.right
        footer = PullToRefreshDefaultHorizontalFooter(frame: CGRect(x: x, y: 0, width: 40, height: scrollView.frame.height), scrollView: scrollView)
        scrollView.insertSubview(footer!, at: 1)
        config?(footer as! PullToRefreshDefaultHorizontalFooter)
        return self
    }
    
    
    //MARK: 纵向
    @discardableResult
    func addDefaultFooter(config: ((_ footer: PullToRefreshDefaultFooter) -> Void)? = nil) -> Self {
        let y = maxHeight() + scrollView.contentInset.bottom
        footer = PullToRefreshDefaultFooter(frame: CGRect(x: 0, y: y, width: scrollView.frame.width, height: 50), scrollView: scrollView)
        scrollView.insertSubview(footer!, at: 1)
        config?(footer as! PullToRefreshDefaultFooter)
        return self
    }
    
    @discardableResult
    func addDefaultHeader(config: ((_ header: PullToRefreshDefaultHeader) -> Void)? = nil) -> Self {
        let y = -scrollView.contentInset.top - 60
        header = PullToRefreshDefaultHeader(frame: CGRect(x: 0, y: y, width: scrollView.frame.width, height: 60), scrollView: scrollView)
        scrollView.insertSubview(header!, at: 0)
        
        config?(header as! PullToRefreshDefaultHeader)
        return self
    }
    
    @discardableResult
    func addGifHeader(config: (_ header: PullToRefreshDefaultGifHeader) -> Void) -> Self {
        let y = -scrollView.contentInset.top - 80
        let gifHeader = PullToRefreshDefaultGifHeader(frame: CGRect(x: 0, y: y, width: scrollView.frame.width, height: 80), scrollView: scrollView)
        header = gifHeader
        scrollView.insertSubview(header!, at: 0)
        
        config(gifHeader)
        
        gifHeader.gifFrame = CGRect(x: 40, y: 20, width: 100, height: 60)
        
        return self
    }
    
    @discardableResult
    func addGifFooter(config: (_ footer: PullToRefreshDefaultGifFooter) -> Void) -> Self {
        let y = maxHeight() + scrollView.contentInset.bottom
        let gifFooter = PullToRefreshDefaultGifFooter(frame: CGRect(x: 0, y: y, width: scrollView.frame.width, height: 60), scrollView: scrollView)
        footer = gifFooter
        footer?.margin = 0
        scrollView.insertSubview(gifFooter, at: 0)
        
        config(gifFooter)
        
        gifFooter.gifFrame = CGRect(x: 40, y: gifFooter.margin, width: 100, height: 60)
        
        return self
    }
    
    private func setup() {
        scrollView.addObserver(self, forKeyPath: "panGestureRecognizer.state", options: .new, context: nil)
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        scrollView?.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        scrollView?.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "panGestureRecognizer.state" {
            if let stateNum = change?[.newKey] as? Int {
                var state = PullToRefreshState.wait
                switch stateNum {
                case UIGestureRecognizerState.began.rawValue:
                    state = .begin
                case UIGestureRecognizerState.ended.rawValue, UIGestureRecognizerState.cancelled.rawValue:
                    state = .refreshing
                case UIGestureRecognizerState.changed.rawValue:
                    state = .pulling
                default:
                    break
                }
                
                var visiableHeight_header: CGFloat = 0
                if let _ = header as? PullToRefreshHorizontalView {
                    visiableHeight_header = -scrollView.contentOffset.x - scrollView.contentInset.left
                } else {
                    visiableHeight_header = -scrollView.contentOffset.y - scrollView.contentInset.top
                }
                if visiableHeight_header > 0 {
                    if state != header?.state && header?.state != .refreshing {
                        if state == .refreshing {
                            if header?.state == .pullingComplate {
                                self.footer?.endRefresh()
                                header?.state = state
                                footer?.state = .wait
                            }
                        } else {
                            header?.state = state
                        }
                    }
                } else {
                    if state == .begin && header?.state != .refreshing {
                        header?.state = .begin
                    }
                }
                
                var visiableHeight_footer: CGFloat = 0
                if let _ = footer as? PullToRefreshHorizontalView {
                    let maxWidth = max(scrollView.contentSize.width, scrollView.frame.width)
                    visiableHeight_footer = scrollView.contentOffset.x + scrollView.frame.width - scrollView.contentInset.right - maxWidth
                } else {
                    visiableHeight_footer = scrollView.contentOffset.y + scrollView.frame.height - scrollView.contentInset.bottom - maxHeight()
                }
                if visiableHeight_footer > 0 && state != footer?.state && footer?.state != .refreshing && footer?.state != .noMoreData {
                    if state == .refreshing {
                        if footer?.state == .pullingComplate {
                            self.header?.endRefresh()
                            footer?.state = state
                        }
                    } else {
                        footer?.state = state
                    }
                } else {
                    if state == .begin && footer?.state != .noMoreData && footer?.state != .refreshing {
                        footer?.state = .begin
                    }
                }
            }
        } else if keyPath == "contentOffset" {
            if let point = change?[.newKey] as? CGPoint {
                if let header = header {
                    var p: CGFloat = 0.0
                    
                    var visiableHeight: CGFloat = 0
                    //判断横向还是纵向
                    if let _ = header as? PullToRefreshHorizontalView {
                        visiableHeight = (-point.x - scrollView.contentInset.left)
                    } else {
                         visiableHeight = -point.y - scrollView.contentInset.top
                    }
                    if visiableHeight > 0 && header.state != .refreshing {
                        /// - header.margin - marginDely 防止进度增加过快，进度条还没显示就已经跑了一半的进度，，很尴尬。。。
                        if abs(visiableHeight) < header.margin + header.marginDely {
                            p = 0.001
                            header.progress = p
                        } else {
                            p = min(1.0, (abs(visiableHeight) - header.margin - header.marginDely) / header.refreshHeight)
                            if p >= 0 {
                                header.progress = p
                            }
                        }
                        
                        header.state = header.progress >= 1 ? .pullingComplate : .pulling
                        header.isHidden = header.hideWhenComplete && p <= 0
                    }
                }
                
                if let footer = footer {
                    var visiableHeight: CGFloat = 0
                    
                    if let _ = footer as? PullToRefreshHorizontalView {
                        let maxWidth = max(scrollView.contentSize.width, scrollView.frame.width)
                        visiableHeight = point.x + scrollView.frame.width - scrollView.contentInset.right - maxWidth
                    } else {
                        visiableHeight = point.y + scrollView.frame.height - scrollView.contentInset.bottom - maxHeight()
                    }
                    
                    var p: CGFloat = 0.0
                    
                    if visiableHeight > 0 && footer.state != .refreshing && scrollView.contentSize.height > 0 {
                        /// - header.margin - marginDely 防止进度增加过快，
                        if footer.autoLoadWhenIsBottom && scrollView.contentSize.height > 0 {
                            footer.isHidden = false
                            footer.beginRefresh()
                        } else {
                            if abs(visiableHeight) < footer.margin + footer.marginDely {
                                p = 0.001
                                footer.progress = p
                            } else {
                                p = min(1.0, (abs(visiableHeight) - footer.margin - footer.marginDely) / footer.refreshHeight)
                                if p >= 0 {
                                    footer.progress = p
                                }
                            }
                            
                            if footer.state != .noMoreData {
                                footer.state = footer.progress >= 1 ? .pullingComplate : .pulling
                            }
                        }
                        
                        footer.isHidden = footer.hideWhenComplete && p <= 0
                    }
                    
                    if footer.state == .noMoreData || footer.state == .refreshing {
                        footer.isHidden = false
                    }
                }
            }
        } else if keyPath == "contentSize" {
            guard let footer = footer else { return }
            
            if let f = footer as? PullToRefreshDefaultHorizontalFooter {
                let maxWidth = max(scrollView.contentSize.width, scrollView.frame.width)
                footer.frame.origin.x = maxWidth + f.originalRight
            } else {
                let y = maxHeight() + footer.originalBottom
                footer.frame.origin.y = y
            }
        } else if keyPath == "bounds" {
            if let b = change?[.newKey] as? CGRect {
                if self.header is PullToRefreshHorizontalView || footer is PullToRefreshHorizontalView {
                    header?.bounds.size.height = b.size.height
                    footer?.bounds.size.height = b.height
                    header?.frame.origin.y = 0
                    footer?.frame.origin.y = 0
                } else {
                    header?.bounds.size.width = b.size.width
                    footer?.bounds.size.width = b.width
                    header?.frame.origin.x = 0
                    footer?.frame.origin.x = 0
                }
            }
        }
        
    }
    
    func maxHeight() -> CGFloat {
        return max(scrollView.contentSize.height, scrollView.frame.height)
    }
    
    deinit {
        scrollView?.removeObserver(self, forKeyPath: "panGestureRecognizer.state")
        scrollView?.removeObserver(self, forKeyPath: "contentOffset")
        scrollView?.removeObserver(self, forKeyPath: "contentSize")
        scrollView?.removeObserver(self, forKeyPath: "bounds")
    }
    
}
