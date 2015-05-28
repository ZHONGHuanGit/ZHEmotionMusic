//
//  File.swift
//  ZHEmotionMusic
//
//  Created by 钟桓 on 15/5/26.
//  Copyright (c) 2015年 ZH. All rights reserved.
//

import Foundation

import UIKit

/**
标示消失的方向

- Left:  左边消失
- Right: 右边消失
*/
enum DisappearDirection {
    case Left
    case Right
}

protocol SwitchingTapDelegate{
    func handleTap(on : Bool)
}

class SwitchingImageView: UIView {
    
    /// 屏幕大小
    let screenSize: CGRect!
    
    /// 拖动手势
    var panGestureRecognizer : UIPanGestureRecognizer!
    
    /// 轻点手势
    var tapGestureRecognizer : UITapGestureRecognizer!
    
    //初始的中间的位置
    var originalPoint:CGPoint!
    
    /// 是否播放
    var on : Bool  = true
    
    var delegate : SwitchingTapDelegate!
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect){
        screenSize = UIScreen.mainScreen().bounds
        super.init(frame : frame)
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("paned:"))
        self.backgroundColor = UIColor.greenColor()
        self.addGestureRecognizer(panGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        loadStyle()
    }
    
    required init(coder aDecoder: NSCoder) {
        screenSize = UIScreen.mainScreen().bounds
        super.init(coder: aDecoder)
        
    }
    
    /**
    加载SwitchingImageView的Style
    */
    func loadStyle(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSizeMake(5.00, 5.00)
        self.layer.shadowRadius = 5
    }
    
    /**
    是否展示阴影
    
    :param: show Bool
    */
    func shouldShowShadow(show:Bool){
        if (show) {
            self.layer.shadowOpacity = 0.5
        } else {
            self.layer.shadowOpacity = 0.0
        }
    }
    
    
    /**
    pan手势处理函数，依据当前位置，判断是否应当移除当前SwitchingImageView
    
    :param: gestureRecognizer  : UIPanGestureRecognizer
    */
    func paned(gestureRecognizer: UIPanGestureRecognizer) {
        let xDistance:CGFloat = gestureRecognizer.translationInView(self).x
        let yDistance:CGFloat = gestureRecognizer.translationInView(self).y
        
        switch(gestureRecognizer.state){
        case UIGestureRecognizerState.Began:
            self.originalPoint = self.center
            shouldShowShadow(true)
        case UIGestureRecognizerState.Changed:
            
            let rotationStrength:CGFloat = min((xDistance/320),1)
            let rotationAngel:CGFloat = (1.50*CGFloat(M_PI)*CGFloat(rotationStrength) / 15.00)
            let scaleStrength:CGFloat = 1.00 - CGFloat(fabsf(Float(rotationStrength))) / 4.00
            let scale:CGFloat = max(scaleStrength, 0.93);
            
            self.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance)
            
            let transform:CGAffineTransform = CGAffineTransformMakeRotation(rotationAngel)
            let scaleTransform:CGAffineTransform = CGAffineTransformScale(transform, scale, scale)
            self.transform = scaleTransform
            self.backgroundColor = UIColor.redColor()
            
        case UIGestureRecognizerState.Ended:
            let hasMovedToFarLeft = CGRectGetMaxX(self.frame) < screenSize.width / 2
            let hasMovedToFarRight = CGRectGetMinX(self.frame)  > screenSize.width / 2
            if (hasMovedToFarLeft) {
                removeViewFromParentWithAnimation(disappearDirection: .Left)
            } else if (hasMovedToFarRight) {
                removeViewFromParentWithAnimation(disappearDirection: .Right)
            } else {
                self.resetViewPositionAndTransformations()
            }
        default:
            break
        }
    }
    
    /**
    Tap 手势处理函数
    
    :param: gestureRecognizer : UITapGestureRecognizer
    */
    func tapped(gestureRecognizer: UITapGestureRecognizer){
        delegate.handleTap(on)
    }
    
    /**
    将当前SwitchingImageView恢复至初始的位置
    */
    func resetViewPositionAndTransformations(){
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
            self.center = self.originalPoint
            self.transform = CGAffineTransformMakeRotation(0)
            self.shouldShowShadow(false)
            }, completion: {success in })
    }
    
    /**
    移除SwitchingImageView
    
    :param: disappearDirection 移除的方向
    */
    func removeViewFromParentWithAnimation(#disappearDirection:DisappearDirection){
        var animations:(()->Void)!
        switch disappearDirection {
        case .Left:
            animations = {self.center.x = -self.frame.width}
        case .Right:
            animations = {self.center.x = self.screenSize.width + self.frame.width}
        default:
            break
        }
        
        UIView.animateWithDuration(0.2, animations: animations , completion: {success in
            self.removeFromSuperview()})
    }
    
}
