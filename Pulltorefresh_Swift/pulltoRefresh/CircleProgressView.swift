//
//  CircleProgressView.swift
//  动画测试zz
//
//  Created by wanwu on 16/12/22.
//  Copyright © 2016年 wanwu. All rights reserved.
//

import UIKit

class CircleProgressView: UIView {
    
    let halfPi = Double.pi / 2
    var circleColor = UIColor.red {
        didSet {
            colorLayer.backgroundColor = circleColor.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    var colorLayer = CALayer()
    var circleLayer = CAShapeLayer()
    let grayLayer = CAShapeLayer()
    var animateFromZero = false
    var changeWithTimer = true
    
    
    var progress = 0.0 {
        didSet {
            if oldValue != progress {
                if animateFromZero {
                    self.currentProgress = 0
                    
                    drawCircle()
                }
                if changeWithTimer {
                    timer?.fireDate = Date.distantPast
                } else {
                    self.currentProgress = progress
                    self.drawCircle()
                }
            }
        }
    }
    var currentProgress = 0.0
    var lineWidth: CGFloat = 6 {
        didSet {
            let w = self.bounds.width
            let h = self.bounds.height
            let grayPath = UIBezierPath(arcCenter: CGPoint(x: w / 2, y: h / 2), radius: w / 2 - lineWidth - 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
            grayLayer.path = grayPath.cgPath
            grayLayer.lineWidth = lineWidth
            
            let startA: CGFloat = CGFloat(-halfPi * 3.0) + 0.13
            let path = UIBezierPath(arcCenter: CGPoint(x: w / 2, y: h / 2), radius: w / 2 - lineWidth - 2, startAngle: startA, endAngle: startA + CGFloat(Double.pi * 2 * currentProgress), clockwise: true)
            circleLayer.path = path.cgPath
            
            circleLayer.lineWidth = lineWidth
        }
    }
    var timer: Timer?

    let tipLabel = UILabel()
    
    func refreshAnimation() {
        
    }
    
    func setup() {
        let w = self.bounds.width
        let h = self.bounds.height
        
        grayLayer.fillColor = UIColor.clear.cgColor
        grayLayer.strokeColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        self.layer.addSublayer(grayLayer)
        
        let bkLayer = CALayer()
        bkLayer.frame = self.bounds
        
        layer.addSublayer(bkLayer)
        
        //MARK: 彩色背景
        
//        let greenLayer = CAGradientLayer()
//        greenLayer.frame = CGRect(x: 0, y: 0, width: w / 2, height: h)
//        greenLayer.colors = [UIColor.yellow.cgColor, UIColor.green.cgColor]
//        greenLayer.locations = [NSNumber(value: 0.3), NSNumber(value: 1)]
//        bkLayer.addSublayer(greenLayer)
//        
//        let redLayer = CAGradientLayer()
//        redLayer.frame = CGRect(x: w / 2, y: 0, width: w / 2, height: h)
//        redLayer.colors = [UIColor.yellow.cgColor, UIColor.red.cgColor]
//        redLayer.locations = [NSNumber(value: 0.3), NSNumber(value: 1)]
//        bkLayer.addSublayer(redLayer)
        
        //MARK: 纯色背景
        let redLayer = CALayer()
        redLayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
        redLayer.backgroundColor = circleColor.cgColor
        bkLayer.addSublayer(redLayer)
        colorLayer = redLayer
        
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.black.cgColor
        
        circleLayer.lineCap = kCALineCapSquare

        bkLayer.mask = circleLayer
        
        tipLabel.frame = self.bounds
        self.addSubview(tipLabel)
        tipLabel.textAlignment = .center
        tipLabel.text = "0%"
        tipLabel.font = UIFont.systemFont(ofSize: 15)
        tipLabel.adjustsFontSizeToFitWidth = true
        
        var flag = true
        
        timer = Timer.scheduledTimer(0.015, action: { (t) in
            flag = self.currentProgress < self.progress
            
            if self.currentProgress < self.progress {
                self.currentProgress += 0.015
            } else {
                self.currentProgress -= 0.015
            }
            
            if (flag && self.currentProgress >= self.progress) || (!flag && self.currentProgress <= self.progress) {
                t.fireDate = Date.distantFuture
                self.currentProgress = self.progress
            }
            
            self.drawCircle()
        }, userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func drawCircle() {
        let w = self.bounds.width
        let h = self.bounds.height
        
        let startA: CGFloat = CGFloat(-halfPi * 3.0) + 0.13
        let p = UIBezierPath(arcCenter: CGPoint(x: w / 2, y: h / 2), radius: w / 2 - self.lineWidth - 2, startAngle: startA, endAngle: startA + CGFloat(Double.pi * 2 * self.currentProgress), clockwise: true)
        self.circleLayer.path = p.cgPath
        self.tipLabel.text = "\((Int)(self.currentProgress * 100))%"
    }
    
    deinit {
        self.timer?.invalidate()
        timer = nil
    }

}
