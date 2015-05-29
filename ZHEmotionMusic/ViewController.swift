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
enum Emotion : String{
    case happy = "http://douban.fm/j/mine/playlist?channel=7"
    case sad = "http://douban.fm/j/mine/playlist?channel=16"
    case calm = "http://douban.fm/j/mine/playlist?channel=8"
    case angry = "http://douban.fm/j/mine/playlist?channel=14"
}

class ViewController: UIViewController , SuperIDDelegate , HttpProtocol , CircularProgressViewDelegate{
    
    /// 一登调用接口的实例
    var superIdSdk : SuperID?;
    
    ///ImageView实例
    @IBOutlet weak var imageView: UIImageView!
    var originalPoint:CGPoint!

    ///第一个Label标签
    @IBOutlet weak var label1: UILabel!
    
    /// 第二个Label标签
    @IBOutlet weak var label2: UILabel!
    
    /// Circular View
    @IBOutlet weak var circularProgressView: CircularProgressView!
    
    /// mood View
    @IBOutlet weak var moodView: UIView!
    
     /// mood 图标
    @IBOutlet var moodImages: [UIImageView]!
    
    /// mood label
    @IBOutlet var moodLabels: [UILabel]!
    
    /// 拖动的view
    @IBOutlet weak var controlView: UIView!
    
    /// 暂停 label
    @IBOutlet weak var pauseLabel: UILabel!
    
    ///    /// 下一首 label
    @IBOutlet weak var nextLabel: UILabel!
    
    
    /// 扫描后的心情
    @IBOutlet weak var moodImage: UIImageView!
    
    
    /// 当前的心情
    var emotion : Emotion = Emotion.happy
    
//    /// 快乐就听摇滚
//    let happySongsURL = "http://douban.fm/j/mine/playlist?channel=7"
//    
//    /// 悲伤就听R&B
//    let sadSongsURL = "http://douban.fm/j/mine/playlist?channel=14"

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
        
        //一开始不要出现
        self.circularProgressView.hidden = true
        
        //http的处理交给当前实现HttpProtocol的ViewController来处理
        http.delegate = self
        
        //添加Swipgesture
        var up = UISwipeGestureRecognizer(target: self, action: "swipeHandler:")
        var down = UISwipeGestureRecognizer(target: self, action: "swipeHandler:")
        
        up.direction = .Up
        down.direction = .Down
        
        self.view.addGestureRecognizer(up)
        self.view.addGestureRecognizer(down)
        
        //添加pan gesture
        var pan = UIPanGestureRecognizer(target: self, action: "drag:")
        self.controlView.addGestureRecognizer(pan)
        
        self.originalPoint = self.controlView.center
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
            var info = featureInfo!
            
            //因为featureInfo和其内部的数据，都是optional类型，需要 unwrap
            if let info = featureInfo {
                var emotions = info["emotions"] as! Dictionary<String,Double>
                var emoArr = Array<Double>()
                emoArr.append(emotions["happy"]!)
                emoArr.append(emotions["sad"]!)
                emoArr.append(emotions["calm"]!)
                emoArr.append(emotions["angry"]!)
                
                var emoID = 0
                for var i = 1 ; i < emoArr.count ; i++ {
                    if emoArr[i] > emoArr[emoID]{
                        emoID = i
                    }
                }
                
                switch emoID {
                case 0:
                    emotion = Emotion.happy
                case 1:
                    emotion = Emotion.sad
                case 2:
                    emotion = Emotion.calm
                default:
                    emotion = Emotion.angry
                }
                
               
                self.moodChanged()
             
            }
            
        }
        else{
            println("操作失败!")
            
            println("\(error.code)   \(error.description)")
        }
    }
    
    
    func moodChanged(){
        
        switch emotion{
        case .happy:
            moodImage.image = UIImage(named: "mood_happy")
        case .sad:
            moodImage.image = UIImage(named: "mood_sad")
        case .calm:
            moodImage.image = UIImage(named: "mood_calm")
        case .angry:
            moodImage.image = UIImage(named: "mood_angry")
            
        }
        
        self.moodImage.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1, 1), CGAffineTransformMakeTranslation(0, 0))
        
        self.http.onSearch(self.emotion.rawValue)
        
        //播放动画
        UIView.animateWithDuration( 2 , delay: 1 , options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            self.moodImage.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.2, 0.2), CGAffineTransformMakeTranslation( 0.2 * self.moodImage.frame.width - self.view.center.x , self.view.frame.height - self.view.center.y + 0.2 * self.moodImage.frame.height))
            
            }, completion: nil)
        
        
        self.updateMoodView()
        
        self.controlView.userInteractionEnabled = true
        
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
            http.onSearch(emotion.rawValue)
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
        self.label1.text = song["title"] as? String
        
        //update artist  --> label2
        self.label2.text = song["artist"] as? String
        self.label2.font = self.label2.font.fontWithSize(13)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        //歌曲播放时可以出现
         self.circularProgressView.hidden = false
        
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

  // MARK: - moodView Show
    
    /**
        上下滑动处理函数
    
    :param: sender 滑动手势
    */
    func swipeHandler(sender : UISwipeGestureRecognizer){
        
        var frameY = self.view.frame.height
        
        if sender.direction == .Up{
            let h = frameY - self.moodView.center.y
            
            if h < 0 {

                UIView.animateWithDuration(2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 20, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    
                    self.moodView.center.y -= 120
                    
                    }, completion: { (ok) -> Void in
                })
                
            }
        }
        
        if sender.direction == .Down{
            let h = frameY - self.moodView.center.y
    
            if h > 0 {
                
                UIView.animateWithDuration( 0.3 , delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    
                    self.moodView.center.y += 120
                    
                    }, completion: { (ok) -> Void in
                })

            }

        }
    }
    
    /**
        更新 mood view 显示
    */
    func updateMoodView(){
        
        for moodImg in moodImages{
            moodImg.highlighted = false
        }
        
        for label in moodLabels {
            label.textColor = UIColor.grayColor()
        }
        
        switch self.emotion{
        case .happy:
            moodImages[0].highlighted = true
            moodLabels[0].textColor = UIColor.blackColor()
        case .sad :
            moodImages[1].highlighted = true
            moodLabels[1].textColor = UIColor.blackColor()
        case .calm :
            moodImages[2].highlighted = true
            moodLabels[2].textColor = UIColor.blackColor()
        case .angry:
            moodImages[3].highlighted = true
            moodLabels[3].textColor = UIColor.blackColor()
        }
    }
    
    
    /**
        用户主动点击表情，切换频道的处理函数
    
    :param: sender 标识点击的表情
    */
    @IBAction func moodViewTapped(sender : UIButton){
        
        //通过UIImageView的tag进行标示，可以在storyboard对应的utility的attribute inspector中设置
        switch sender.tag{
        case 0:
            emotion = Emotion.happy
        case 1:
            emotion = Emotion.sad
        case 2:
            emotion = Emotion.calm
        default:
            emotion = Emotion.angry
        }
        
        
        
        UIView.animateWithDuration( 0.3 , delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            self.moodView.center.y += 120
            
            }, completion: { (ok) -> Void in
        })

        
        moodChanged()
        
    }
    
 // MARK: - Pan gesture
    
     /**
        control view 拖动手势处理函数
    
    :param: sender
    */
    func drag(sender : UIPanGestureRecognizer){
        
        let xDistance:CGFloat = sender.translationInView(self.view).x
        let yDistance:CGFloat = sender.translationInView(self.view).y
        
        switch sender.state{
        case UIGestureRecognizerState.Began:
            println("begin")
        case UIGestureRecognizerState.Changed:

            self.controlView.center.x = originalPoint.x + xDistance
            var nowX = self.controlView.center.x
            
            //展示下一首 label
            if nowX <= originalPoint.x - 120 {
                self.nextLabel.hidden = false
            }else{
                self.nextLabel.hidden = true
            }
            
            //展示暂停  label
            if nowX >= originalPoint.x + 120{
                self.pauseLabel.hidden = false
            }else{
                self.pauseLabel.hidden = true
            }
            
        case UIGestureRecognizerState.Ended:
            
            var nowX = self.controlView.center.x
            
            self.nextLabel.hidden = true
            
            //需要切换歌曲
            if nowX <= originalPoint.x - 120{
                self.nextLabel.hidden = true
                self.playerDidFinishPlaying()
                UIView.animateWithDuration( 0.3 , delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    
                    self.controlView.center.x = self.originalPoint.x
                    
                    }, completion: nil)
                
            }
            //需要暂停
            else if nowX >= originalPoint.x + 120{
                
                self.circularProgressView.pause()
                
                UIView.animateWithDuration( 0.3 , delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    
                    self.controlView.center.x = self.view.frame.width
                    
                    }, completion: nil)
                
                
            }else{
                
                self.circularProgressView.play()
                
                UIView.animateWithDuration( 0.3 , delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    
                    self.controlView.center.x = self.originalPoint.x
                    
                    }, completion: nil)

            }
            
            
            
        default:
            println("default")
        }
        
    }
    
    
}

