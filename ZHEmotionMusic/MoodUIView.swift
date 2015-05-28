//
//  MoodUIView.swift
//  ZHEmotionMusic
//
//  Created by 钟桓 on 15/5/28.
//  Copyright (c) 2015年 ZH. All rights reserved.
//

import UIKit

class MoodUIView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var moods = [Emotion.happy , Emotion.sad]
    
    @IBOutlet var moodImageViews: [UIImageView]!
    @IBOutlet var moodLabel : [UILabel]!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
    }
    
    
   

}
