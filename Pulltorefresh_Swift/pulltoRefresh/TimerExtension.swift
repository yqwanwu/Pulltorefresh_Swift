//
//  TimerExtension.swift
//  player
//
//  Created by wanwu on 16/8/12.
//  Copyright © 2016年 wanwu. All rights reserved.
//

import Foundation

extension Timer {
    fileprivate class TimerAdapter: Timer {
        fileprivate var action: ((_ timer: Timer) -> Void)?
        fileprivate func scheduledTimer(_ timeInterval: TimeInterval, action: ((_ timer: Timer) -> Void)?, userInfo: AnyObject?, repeats: Bool) -> Timer {
            self.action = action
            return Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(Timer.TimerAdapter.ac(_:)), userInfo: userInfo, repeats: repeats)        
        }
        
        @objc fileprivate func ac(_ sender: Timer) {
            if let action = self.action {
                action(sender)
            }
        }
        
        deinit {
            print("timer 清空")
        }
    }
    
    class func scheduledTimer(_ timeInterval: TimeInterval, action: ((_ sender: Timer) -> Void)?, userInfo: AnyObject?, repeats: Bool) -> Timer {
        return TimerAdapter().scheduledTimer(timeInterval, action: action, userInfo: userInfo, repeats: repeats)
    }
    
    
}
