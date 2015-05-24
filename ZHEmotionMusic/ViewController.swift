//
//  ViewController.swift
//  ZHEmotionMusic
//
//  Created by 钟桓 on 15/5/23.
//  Copyright (c) 2015年 ZH. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController , SuperIDDelegate {
    
    /// 一登调用接口的实例
    var superIdSdk : SuperID?;
    
    ///ImageView实例
    @IBOutlet weak var imageView: UIImageView!
    
    ///第一个Label标签
    @IBOutlet weak var label1: UILabel!
    
    /// 第二个Label标签
    @IBOutlet weak var label2: UILabel!

    /**
    Description
        View将出现时，所做的操作，这里添加了SDK的委托声明
    :param: animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        superIdSdk = SuperID.sharedInstance() // 获取SDK单例
        superIdSdk?.delegate = self //设置委托对象
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageView.layer.masksToBounds = true
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
    Description 
            调用该方法，获取调用相机权限
    */
    func getAuthorityOfCamera(){
        var status:AVAuthorizationStatus =  AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        
        if(status == AVAuthorizationStatus.Authorized) { // authorized
            return;
        }
        else {
            
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
                (Bool granted) -> Void in
                
                //如果用户赋予了权限
                if(granted){
                    
                }
                //如果没有赋予权限
                else{
                    
                }
            })
        }
    }
    
    /**
    Description
            用户在一登 SDK 完成人脸属性检测事件后，SDK 将执行协议中的方法，就是本方法，开发者可本方法中进行根据需要相应事件处理
    :param: sender       SuperID实例
    :param: featureInfo  检测的人脸信息
    :param: error        error == nil 则不发生错误； 否则发生错误。
    */
    func superID(sender: SuperID!, userDidFinishGetFaceFeatureWithFeatureInfo featureInfo: [NSObject : AnyObject]!, error: NSError!) {
        if(error == nil){
            println("操作成功!")
            
            println(featureInfo)
//            var info = featureInfo!
            
            //因为featureInfo和其内部的数据，都是optional类型，需要 unwrap
            if let info = featureInfo {
                var smileResult = info["smiling"]!
                var result = smileResult["result"] as! Int
                var score = smileResult["score"] as! Double
                println(score)
                if result == 1 {
                    imageView.image = UIImage(named: "happy")
                    label1.text = "诶哟！"
                    label2.text = "今天心情不错哦！"
                }else{
                    imageView.image = UIImage(named: "sad")
                    label1.text = "唉！一言以蔽之"
                    label2.text = "心好涩"
                }
            }
            
        }
        else{
            println("操作失败!")
            
            println("\(error.code)   \(error.description)")
        }
    }

    /**
    Description
        处理用户长按屏幕的行动
    
    :param: sender
    */
    @IBAction func longPressAction(sender: AnyObject) {
        getAuthorityOfCamera()
        
        var error : NSError? = nil;
        
        var SIDEmotionViewController  = superIdSdk!.obtainFaceFeatureViewControllerWithError(&error) as? UIViewController;
        
        if let SEV = SIDEmotionViewController{
            //采用present的方式弹出人脸情绪的功能：
            self.presentViewController(SIDEmotionViewController!, animated: true, completion: nil)
            
        }
        else{
            println("\(error?.code)     \(error?.description)")
        }
        
    }
    
}

