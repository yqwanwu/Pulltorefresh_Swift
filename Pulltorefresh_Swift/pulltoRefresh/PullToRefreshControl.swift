//
//  PullToRefreshTool.swift
//  reuseTest
//
//  Created by wanwu on 2017/4/11.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class PullToRefreshControl: NSObject {    
    var header: PullToRefreshView?
    var footer: PullToRefreshView?
    var scrollView: UIScrollView!
        
    convenience init(scrollView: UIScrollView) {
        self.init()
        self.scrollView = scrollView
        
        setup()
    }
    
    @discardableResult
    func addDefaultFooter(config: ((_ footer: PullToRefreshDefaultFooter) -> Void)? = nil) -> Self {
        let y = scrollView.contentSize.height + scrollView.contentInset.bottom
        footer = PullToRefreshDefaultFooter(frame: CGRect(x: 0, y: y, width: scrollView.frame.width, height: 50), scrollView: scrollView)
        scrollView.insertSubview(footer!, at: 1)
        config?(footer as! PullToRefreshDefaultFooter)
        return self
    }
    
    @discardableResult
    func addDefaultHeader(config: ((_ header: PullToRefreshDefaultHeader) -> Void)? = nil) -> Self {
        header = PullToRefreshDefaultHeader(frame: CGRect(x: 0, y: -60, width: scrollView.frame.width, height: 60), scrollView: scrollView)
        scrollView.insertSubview(header!, at: 0)
        
        config?(header as! PullToRefreshDefaultHeader)
        return self
    }
    
    @discardableResult
    func addGifHeader() -> Self {
        let gifHeader = PullToRefreshDefaultGifHeader(frame: CGRect(x: 0, y: -80, width: scrollView.frame.width, height: 80), scrollView: scrollView)
        header = gifHeader
        scrollView.insertSubview(header!, at: 0)
        var imgArr = [UIImage]()
        for i in 1...8 {
            imgArr.append(UIImage(named: "timg\(i)")!)
        }
        gifHeader.setImgArr(state: .pulling, imgs: imgArr)
        gifHeader.gifFrame = CGRect(x: 40, y: 20, width: 100, height: 60)
        
        gifHeader.setImgArr(state: .refreshing, imgs: imgArr, animationTime: 2.0)
        
        let url = Bundle.main.url(forResource: "luufy", withExtension: "gif")
        let data = try! Data(contentsOf: url!)
        gifHeader.setGifData(state: .pulling, gifData: data)
        
        let url1 = Bundle.main.url(forResource: "timg", withExtension: "gif")
        let data1 = try! Data(contentsOf: url1!)
        gifHeader.setGifData(state: .refreshing, gifData: data1)
        
        return self
    }
    
    private func setup() {
        scrollView.addObserver(self, forKeyPath: "panGestureRecognizer.state", options: .new, context: nil)
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        scrollView?.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
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
                
                let visiableHeight_header = -scrollView.contentOffset.y - scrollView.contentInset.top
                if visiableHeight_header > 0 && state != header?.state && header?.state != .refreshing {
                    if state == .refreshing {
                        if header?.state == .pullingComplate {
                            header?.state = state
                        }
                    } else {
                        header?.state = state
                    }
                }
                
                let visiableHeight_footer = scrollView.contentOffset.y + scrollView.frame.height - scrollView.contentInset.bottom - scrollView.contentSize.height
                if visiableHeight_footer > 0 && state != footer?.state && footer?.state != .refreshing {
                    if state == .refreshing {
                        if footer?.state == .pullingComplate {
                            footer?.state = state
                        }
                    } else {
                        footer?.state = state
                    }
                }
            }
        } else if keyPath == "contentOffset" {
            if let point = change?[.newKey] as? CGPoint {
                if let header = header {
                    let visiableHeight = -point.y - scrollView.contentInset.top
                    if visiableHeight > 0 && header.state != .refreshing {
                        /// - header.margin - 5 防止进度增加过快，进度条还没显示就已经跑了一半的进度，，很尴尬。。。
                        let p = min(1.0, (abs(visiableHeight) - header.margin - 5) / header.refreshHeight)
                        if p >= 0 {
                            header.progress = p
                        }
                        header.isHidden = header.hideWhenComplete && p <= 0
                        header.state = header.progress >= 1 ? .pullingComplate : .pulling
                    }
                    
                    if let footer = footer {
                        let visiableHeight = point.y + scrollView.frame.height - scrollView.contentInset.bottom - scrollView.contentSize.height
                        if visiableHeight > 0 && footer.state != .refreshing && scrollView.contentSize.height > 0 {
                            /// - header.margin - 5 防止进度增加过快，
                            if footer.autoLoadWhenIsBottom && scrollView.contentSize.height > 0 {
                                footer.isHidden = false
                                footer.beginRefresh()
                            } else {
                                let p = min(1.0, (abs(visiableHeight) - footer.margin - 5) / footer.refreshHeight)
                                if p >= 0 {
                                    footer.progress = p
                                }
                                footer.isHidden = footer.hideWhenComplete && p <= 0
                                footer.state = footer.progress >= 1 ? .pullingComplate : .pulling
                            }
                        }
                    }
                }
            }
        } else if keyPath == "contentSize" {
            guard let footer = footer else { return }
            
            let y = scrollView.contentSize.height + footer.originalBottom
            footer.frame.origin.y = y
        }
        
    }
    
    deinit {
        scrollView?.removeObserver(self, forKeyPath: "panGestureRecognizer.state")
        scrollView?.removeObserver(self, forKeyPath: "contentOffset")
        scrollView?.removeObserver(self, forKeyPath: "contentSize")
    }

}
