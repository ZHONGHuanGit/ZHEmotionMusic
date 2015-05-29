#小贼音乐--Swift开发笔记 Step 2

------------

小贼音乐的最终效果如下：

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/zhEmotionMusicInfo.gif)


-----

在step1中，我们可以识别人脸表情，在这一步中，我们加入音乐的功能。时不我待，开始吧。

首先了解我们希望得到的最终结果，如下图，是一个能够扫描心情，并且播放音乐：

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/image6.PNG)

---------

###导入CircularProgressView

什么是ProgressView，应该了解，那么前面加了个Circular，意思很明确了，就是在圆形的progress view了，不过它的实现并没有继承progress view，而是继承自view再实现。它虽然带着ProgressView的名字，却也扮演着播放器的角色。可以看[这篇blog了解它](https://cocoapods.org/pods/CircularProgressView)。由于原作者的版本，音乐播放并不支持网络上的音乐，所以，我更新了其实现方式，更改了内部的播放器，让它支持网络上的音乐文件。**更新的CircularProgressView开源在[github](https://github.com/ZHONGHuanGit/CircularProgressView)。** ***喜欢点个赞哈*** 

按照github上面的步骤，我们将CircularProgressView.h和CircularProgressView.m导入我们的项目中，并且新建了一个group，起名CircularProgressView。方便代码审阅。并且把CircularProgressViewDemo中的“我的歌声里”这首歌添加进我们的项目。

导入了objective-c代码，由于我们在项目中需要使用它，所以需要在ZHEmotionMusic-Bridging-Header中登记一下，添加代码如下：

		#import "CircularProgressView.h"

然后在Main.storyboard中，添加一个View(注意，放在原先图像后面)，在其对应的Identity Inspector中，更改class为CircularProgressView.h。在size inspector中，更改大小为256*256。
因为我们希望一会儿圆圈的line width是4.然后，往ViewController中，添加如下代码。

		self.circularProgressView.backColor = UIColor(red: 236.0 / 255.0, green: 236.0 / 255.0, blue: 236.0/255.0, alpha: 1.0)
		        self.circularProgressView.progressColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
		        self.circularProgressView.lineWidth = 4
		        self.circularProgressView.audioURL = NSBundle.mainBundle().URLForResource("我的歌声里", withExtension: "mp3")
		         self.circularProgressView.play()
	
然后尝试运行，啊哦，我们希望的圈圈和原来的视图中间的图像不是很搭，这下怎么办？原因是，师徒中间的imageview使用了autolayout进行了适配，所以，为了让它们时间永远保存某种关系，可以对后面添加的view进行autolayout，我选择的方式，就是让view的top，bottom，left，right始终和imageView保持距离3。增加完autolayout后，运行，结果如下：

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/image5.png)

中间的黑色线条，其在园中的百分比，就是歌曲进行的百分比。同时你可以听到音乐的播放。

-------

###水水的添加音乐

由于暂时没有找到合适的根据心情，提供音乐的API，所以，就先水水的拿一个冒牌的东东来暂时替代一下吧。一些内容来自[【老镇出品】实战-豆瓣电台](http://www.swiftv.cn/course/hwxktqix),如果从没使用swift进行网络编程的话，可以去看一下这个视频教程，里面的内容相对来说更基础，在我们的实现中，对视频中讲解的代码做了一些改进，如果你看了视频的话，可以稍微注意下，希望有所帮助。

在step1中，我们暂且定义了两个表情，开心，不开心。所以需要两个源，一个是获取开心的音乐，一个获取不开心的音乐，之所以说水水的，看下面的代码：

    /// 快乐就听摇滚
    let happySongsURL = "http://douban.fm/j/mine/playlist?channel=7"
    
    /// 悲伤就听R&B
    let sadSongsURL = "http://douban.fm/j/mine/playlist?channel=14"

从代码中，可以体会出，我将豆瓣的摇滚当做快乐的音乐源，将R&B当做悲伤的音乐源。不好意思，暂时没有合适的，就先这样了，大家见谅一下吧。

下一步，新建一个HttpController.swift文件，然后添加如下代码：

	import UIKit
	
	/**
	*  协议负责处理网络连接后的数据处理
	*/
	protocol HttpProtocol{
	    /**
	    负责处理网络连接后的数据处理
	    
	    :param: results 需要处理的数据
	    */
	    func didReceiveResults(results : NSDictionary)
	    
	}
	
	/**
	*  负责网络连接
	*/
	class HttpController: NSObject {
	    
	    var delegate : HttpProtocol?
	    
	    /**
	        给定url，访问网络资源
	    
	    :param: url 资源URL地址
	    */
	    func onSearch(url : String) {
	        
	        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
	        
	        let nsUrl = NSURL(string: url)
	        let request:NSURLRequest = NSURLRequest(URL : nsUrl!)
	        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
	        let session = NSURLSession(configuration: config)
	        let task = session.dataTaskWithRequest(request){
	            (data,response,error) -> Void in
	            if error == nil {
	                
	                var jsonResult : NSDictionary  = NSJSONSerialization.JSONObjectWithData(data,options:NSJSONReadingOptions.MutableContainers, error : nil) as! NSDictionary
	                
	                
	                self.delegate?.didReceiveResults(jsonResult)
	                
	            }else{
	                println(error)
	            }
	            
	            
	        }
	        
	        task.resume()
	        
	    }
	    
	    
	}


HttpController的作用是负责Http的连接，通过IOS的NSURLSession，获取我们需要的内容。

何时调用HttpController呢？ 答案就是，扫描表情之后，所以需要修改ViewController。首先，在ViewController中，添加一个属性， 

	/// 用来获取网络数据
	var http : HttpController = HttpController()

http是HttpController的一个实例，用来获取网络的数据。修改SuperID方法，如下：

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
	                    //获取happy歌曲的数据
	                    http.onSearch(happySongsURL)
	                    
	                }else{
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

从前面可以看到，HttpController有一个delegate，属于HttpProtocol类型，专门负责处理从网络上获取的得来的数据。所以，我们让ViewController视线HttpProtocol协议，然后在其内部实现didReceiveResults方法，如下：

	 	/**
	        负责处理从网络上获取的数据
	    
	    :param: results 获取得到的数据
	    */
	    func didReceiveResults(results : NSDictionary){
	        println("数据成功接收")
	        println(results)
	    }
	
不要忘了在viewDidLoad中，设置http的delegate，添加如下代码：

	//http的处理交给当前实现HttpProtocol的ViewController来处理
	        http.delegate = self

运行，控制台会输出，一些从网络上获取得到的歌曲信息。现在来看看怎么处理这些信息。前提是，了解这些信息的格式，这些信息都是json数据格式，在浏览器中，访问 http://douban.fm/j/mine/playlist?channel=7 。 显示一大堆数据，它们都是json格式，复制这些数据，然后访问 http://jsoneditoronline.org 。json editor online 能够将乱乱的json格式数据，排列成有序的，易于阅读的格式。看一下获取的json数据参考格式：

		{
		    "r": 0,
		    "is_show_quick_start": 0,
		    "song": [
		        {
		            "album": "/subject/7153475/",
		            "picture": "http://img3.douban.com/lpic/s7022222.jpg",
		            "ssid": "cd19",
		            "artist": "Herman's Hermits",
		            "url": "http://mr3.douban.com/201406201304/a687b5d793bb3233e243f05a3e502b20/view/song/small/p2087018.mp3",
		            "company": "Warner",
		            "title": "Smile Please",
		            "rating_avg": 0,
		            "length": 165,
		            "subtype": "",
		            "public_time": "2004",
		            "songlists_count": 0,
		            "sid": "2087018",
		            "aid": "7153475",
		            "sha256": "5f6ba79e1463c1b54d0be17d090d4ee09d55121a91905ddd2217b0ba458ca7a2",
		            "kbps": "64",
		            "albumtitle": "The Best of",
		            "like": "0"
		        },
		        {
		            "album": "/subject/1947603/",
		            "picture": "http://img3.douban.com/lpic/s4458282.jpg",
		            "ssid": "b80e",
		            "artist": "Pompeii",
		            "url": "http://mr3.douban.com/201406201304/f8ea9c7ba0793030c8c486152d51527e/view/song/small/p2087210.mp3",
		            "company": "Warner",
		            "title": "Ten Hundred Lights",
		            "rating_avg": 3.81894,
		            "length": 255,
		            "subtype": "",
		            "public_time": "2006",
		            "songlists_count": 0,
		            "sid": "2087210",
		            "aid": "1947603",
		            "sha256": "761fb793fd0571663c469a10bf9fc3bf0e2e3b329ecc5dddad8a2d28fd7ac0c7",
		            "kbps": "64",
		            "albumtitle": "Assembly",
		            "like": "0"
		        }
		    ]
		} 

了解了格式，就能够依据格式，提取出我们需要的信息。在ViewController中，添加：

	/// 歌曲列表
	    var songs = NSArray()

songs用来，保存歌曲。

更新didReceiveResults方法，


	// MARK: - HttpProtocol Method
	    /**
	        负责处理从网络上获取的数据
	    
	    :param: results 获取得到的数据
	    */
	    func didReceiveResults(results : NSDictionary){
	        println("数据成功接收")
	//        println(results)
	        self.songs = results["song"] as! NSArray
	        
	        let song0 = self.songs[0] as! NSDictionary
	        
	        let songURL = song0["url"] as! String
	        println("song URL: \(songURL)")
	        
	        //更新界面UI的操作，放在主线程，提高反应速度
	        dispatch_async(dispatch_get_main_queue(), {
	            () ->Void in
	            self.circularProgressView.stop()
	            self.circularProgressView.audioURL = NSURL(string: songURL)
	            self.circularProgressView.play()
	            
	            let imageUrl = song0["picture"] as! String
	            self.onSetImage(imageUrl)
	            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
	            
	        })
	        
	    }

onSetImage方法的代码如下：

	/**
	        处理图片，调用ImageLoader单例进行图片缓存。
	    
	    :param: url
	    */
	    func onSetImage(url : String){
	        
	        ImageLoader.sharedLoader.imageForUrl(url, completionHandler:{(image: UIImage?, url: String) in
	            self.imageView.image = image
	        })
	        
	    }


ImageLoader实现图片缓存，采用单例模式，下面看其实现代码：

	//
	//  ImageLoader.swift
	//  ZHEmotionMusic
	//
	//  Created by 钟桓 on 15/5/26.
	//  Copyright (c) 2015年 ZH. All rights reserved.
	//
	
	
	import UIKit
	
	class ImageLoader {
	    
	    var cache = NSCache()
	    
	    class var sharedLoader : ImageLoader {
	        struct Static {
	            static let instance : ImageLoader = ImageLoader()
	        }
	        return Static.instance
	    }
	    
	    func imageForUrl(urlString: String, completionHandler:(image: UIImage?, url: String) -> ()) {
	        
	        
	        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {()in
	            var data: NSData? = self.cache.objectForKey(urlString) as? NSData
	            
	            if let goodData = data {
	                let image = UIImage(data: goodData)
	                dispatch_async(dispatch_get_main_queue(), {() in
	                    completionHandler(image: image, url: urlString)
	                })
	                return
	            }
	            
	            var downloadTask: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
	                if (error != nil) {
	                    completionHandler(image: nil, url: urlString)
	                    return
	                }
	                
	                if data != nil {
	                    let image = UIImage(data: data)
	                    self.cache.setObject(data, forKey: urlString)
	                    dispatch_async(dispatch_get_main_queue(), {() in
	                        completionHandler(image: image, url: urlString)
	                    })
	                    return
	                }
	                
	            })
	            downloadTask.resume()
	        })
	        
	    }
	}


现在运行程序，每次扫描人脸后，都会有新的歌曲进行播放。但你会发现，每当一首歌曲播放完毕，程序停滞，没有行动。因为我们没有对歌曲播放完后改采取的行动进行编写。在ViewController中添加下面三个方法：

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
	    
	    }


聪明的你，注意到了MARK标志，它等价于objective-c的 #pragma。

对第三个方法，也就是playerDidFinishPlaying()进行编程实现。首先，在viewController中添加变量。

	 /// 记录当前播放歌曲在songs内的位置。
	    var id = 0;

在didReceiveResults中，添加一行。


			 self.id = 0;

给playerDidFinishPlaying添加处理逻辑。

	 	/**
	        每当播放结束时调用
	    */
	    func playerDidFinishPlaying() {
	        
	        self.id+=1;
	        println(self.id)
	        
	        //放在主线程，提高反应速度
	        dispatch_async(dispatch_get_main_queue(), {
	            () ->Void in
	            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
	            let song = self.songs[self.id] as! NSDictionary
	            let songURL = song["url"] as! String
	            self.circularProgressView.stop()
	            self.circularProgressView.audioURL = NSURL(string: songURL)
	            self.circularProgressView.play()
	            let imageUrl = song["picture"] as! String
	            self.onSetImage(imageUrl)
	            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
	            
	        })
	        
	    }


到这里，扫描面部后，能够放歌，并且当歌曲结束后，会自动切换歌曲。

但现在我们不知道，播放的歌曲是歌名和演唱者，所以，现在来添加这部分的操作代码。在viewController中添加：

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


将更新歌曲的操作封装在这个函数中，所以，修改didReceiveResults方法。


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


同时不要忘记修改其它地方，将切换歌曲或者播放歌曲，都放在updateSong中，修改playerDidFinishPlaying。

	 	/**
	        每当播放结束时调用
	    */
	    func playerDidFinishPlaying() {
	        
	        self.id+=1;
	        println(self.id)
	        
	        //放在主线程，提高反应速度
	        dispatch_async(dispatch_get_main_queue(), {
	            () ->Void in
	            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
	            let song = self.songs[self.id] as! NSDictionary
	            //update song
	            self.updateSong(song)
	        })
	        
	    }


到现在，似乎完成的很不错了,但是有一个bug，可能你早有迷惑，我们扫描心情只是一次，提取的歌曲数量也是有限，如果歌曲列表songs中的歌曲都播放完毕了，怎么办? 如果不做处理，程序会crash。所以，需要在每次歌曲播放结束后，进行判断。

在ViewController中，添加一个枚举类型。


	/**
	    枚举类型，记录心情
	
	- happy: 快乐的心情
	- sad:   悲伤的心情
	*/
	enum Emotion{
	    case happy
	    case sad
	}


在Viewcontroller类中，添加属性：

	 /// 当前的心情
	 var emotion : Emotion = Emotion.happy

更新歌曲播放结束后的处理方法playerDidFinishPlaying。

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


-------

笔者注：欢迎非商业转载，但请一定注明出处


如果你认为这篇不错，也有闲钱，那你可以用支付宝随便捐助一快两块的，以慰劳笔者的辛苦：


![](http://zhonghuan.qiniudn.com/ZH_zhifubao.png)


































