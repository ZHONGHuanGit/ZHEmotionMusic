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
import MediaPlayer

/**
    枚举类型，记录心情

- happy: 快乐的心情
- sad:   悲伤的心情
*/
enum Emotion{
    case happy
    case sad
}

class ViewController: UIViewController , SuperIDDelegate , HttpProtocol , CircularProgressViewDelegate{
    
    /// 一登调用接口的实例
    var superIdSdk : SuperID?;
    
    ///ImageView实例
    @IBOutlet weak var imageView: UIImageView!
    
    ///第一个Label标签
    @IBOutlet weak var label1: UILabel!
    
    /// 第二个Label标签
    @IBOutlet weak var label2: UILabel!
    
    /// Circular View
    @IBOutlet weak var circularProgressView: CircularProgressView!
    
    /// 音乐播放器
    var audioPlayer : MPMoviePlayerController = MPMoviePlayerController()  //音乐播放器
    
    /// 当前的心情
    var emotion : Emotion = Emotion.happy
    
    /// 快乐就听摇滚
    let happySongsURL = "http://douban.fm/j/mine/playlist?channel=7"
    
    /// 悲伤就听R&B
    let sadSongsURL = "http://douban.fm/j/mine/playlist?channel=14"

    /// 用来获取网络数据
    var http : HttpController = HttpController()
    
    /// 歌曲列表
    var songs = NSArray()
    
    /// 记录当前播放歌曲在songs内的位置。
    var id = 0;
    
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
        
        //初始化circular的配置
        self.circularProgressView.backColor = UIColor(red: 236.0 / 255.0, green: 236.0 / 255.0, blue: 236.0/255.0, alpha: 1.0)
        self.circularProgressView.progressColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        self.circularProgressView.lineWidth = 5
        self.circularProgressView.delegate = self
        
        //http的处理交给当前实现HttpProtocol的ViewController来处理
        http.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
// MARK: - SuperIDDelegate Method
    
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
//                println(score)
                if result == 1 {
                    //更新心情为happy
                    emotion = Emotion.happy
                    
                    imageView.image = UIImage(named: "happy")
                    label1.text = "诶哟！"
                    label2.text = "今天心情不错哦！"
                    //获取happy歌曲的数据
                    http.onSearch(happySongsURL)
                    
                }else{
                    //更新心情为sad
                    emotion = Emotion.sad
                    
                    imageView.image = UIImage(named: "sad")
                    label1.text = "唉！一言以蔽之"
                    label2.text = "心好涩"
                    //获取sad歌曲的数据
                    http.onSearch(sadSongsURL)
                }
            }
            
        }
        else{
            println("操作失败!")
            
            println("\(error.code)   \(error.description)")
        }
    }
    
// MARK: - Gesture handler Action
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
    
    
    
// MARK: - CircularProgressViewDelegate Method
    
//    - (void)updateProgressViewWithPlayer:(AVAudioPlayer *)player;
//    - (void)updatePlayOrPauseButton;
//    - (void)playerDidFinishPlaying;

    /**
        歌曲暂停时调用
    */
    func updatePlayOrPauseButton() {
        
    }

    /**
        可以使用该方法，通过player的信息，对view进行更新。
    
    :param: player 播放器
    */
    func updateProgressViewWithPlayer(player: MPMoviePlayerController!) {
        
    }
    
    /**
        每当播放结束时调用
    */
    func playerDidFinishPlaying() {
        
        self.id+=1;
//        println(self.id)
        
        //如果最后一首歌曲播放完毕，需要再次访问网络，获取资源
        if self.id == songs.count {
            switch emotion{
            case .happy :
                http.onSearch(happySongsURL)
            case .sad :
                http.onSearch(sadSongsURL)
            }
//            println("songs is over")
            self.id=0
        }
        
        //放在主线程，提高反应速度
        dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let song = self.songs[self.id] as! NSDictionary
            //update song
            self.updateSong(song)
        })
        
    }
    

// MARK: - HttpProtocol Method
    /**
        负责处理从网络上获取的数据
    
    :param: results 获取得到的数据
    */
    func didReceiveResults(results : NSDictionary){
        println("数据成功接收")
//        println(results)
        self.songs = results["song"] as! NSArray
        
        let song = self.songs[0] as! NSDictionary
        
        self.id = 0;
        
        //更新界面UI的操作，放在主线程，提高反应速度
        dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
            
            self.updateSong(song)
            
        })
        
    }
    
    /**
     负责更新歌曲
    
    :param: song 需要更新的歌曲信息
    */
    func updateSong(song : NSDictionary){
        //update audio player
        let songURL =  song["url"] as! String
        self.circularProgressView.stop()
        self.circularProgressView.audioURL = NSURL(string: songURL)
        self.circularProgressView.play()
        
        //update image view
        let imageUrl = song["picture"] as! String
        self.onSetImage(imageUrl)
        
        //update song title --> label1
        label1.text = song["title"] as? String
        
        //update artist  --> label2
        label2.text = song["artist"] as? String
        label2.font = label2.font.fontWithSize(13)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

    /**
        处理图片，调用ImageLoader单例进行图片缓存。
    
    :param: url
    */
    func onSetImage(url : String){
        
        ImageLoader.sharedLoader.imageForUrl(url, completionHandler:{(image: UIImage?, url: String) in
            self.imageView.image = image
        })
        
    }

    
    
    
}

