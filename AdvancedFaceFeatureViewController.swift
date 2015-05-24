//
//  AdvancedFaceFeatureViewController.swift
//  ZHEmotionMusic
//
//  Created by 钟桓 on 15/5/24.
//  Copyright (c) 2015年 ZH. All rights reserved.
//

import UIKit

class AdvancedFaceFeatureViewController: SIDFaceFeatureViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureFaceFeatureViewWithDuration(10, withFrameWidth: 320, high: 320)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
