# 小贼音乐--Swift开发笔记 Step 1 

-----------

小贼音乐的最终效果如下：

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/zhEmotionMusicInfo.gif)

-----

本篇博文希望达到的效果如下：

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/ZHEmotionMusic_Step1.gif)


--------


###开头先说说别的

先说说，为什么要开发这个吧。因为在前段时间，看到了一个很有趣的APP---emo。是emotion的简写。没有下载的朋友，可以尝试下载一下。emo的特点就是，使用表情识别，推断当前用户的心情，进而给用户推送音乐。用了几次，觉得推送的音乐挺不错的。

---------

###创建swift项目
创建一个swift项目，这个就不详述了，项目名称可以自定义，不过下面的过程，假定项目名称为ZHEmotionMusic。在开始项目前，可以给Xcode添加一个插件，[VVDocumenter-Xcode](https://github.com/onevcat/VVDocumenter-Xcode)，功能为给方法添加注释，从现在起多写写注释，不仅仅是方便他人的阅读，也是方便自己以后的回顾。

------------

###接入一登SDK

首先了解一登，开发的APP有一个过程，是人脸识别。而[一登](http://superid.me),看官网主要上的描述，主要侧重点在刷脸登陆，但其SDK依旧提供人脸表情识别的功能。（但有一个坑，大家后面也会发现，一登如果要识别人脸表情，需要高级功能，要申请高级功能还得和一登工作人员商量。没办法，一开始没仔细看，不过其实大致的接口是类似。再说一下，国内的face++的识别效果，应该会比一登好，但是一登会比较适合这个音乐app，毕竟emo也是用一登）

因为不能直接获得人脸的表情状态，但毕竟是为了学习，可以变通一下，一登的基本权限，可以获得人脸的微笑程度，现在我们把众多的表情，分成两个。1）开心  2）不开心。（就当随意练手吧，不要在意这些）

现在我们集成SDK，分为几个步骤。

1. 在[官网首页](http://superid.me)点击【注册】完成一登开发者注册。

2. 在一登开发者中心，创建一个新应用。应用名称可以直接填项目名称，应用类型为影音图像；下载地址和Apple ID可以忽略。注意bundle得和XCode中项目的Bundle Identifier一致。如下图：

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/image1.png)

创建好应用后，注意应用中基本信息中含有APP ID 和 APP Secret，在开发过程中会使用。

3. 到一登SDK的[Github](https://github.com/SuperID/SuperID_iOSSDK)上，下载SDK，可以clone，也可以直接下载zip文件。

4. 在一登 GitHub 下载一登 iOS SDK。将 SDK 包中的文件添加至本地工程，其中包括：SuperIDSDKSettings.bundle、 libSuperIDSDK.a、SIDFaceFeatureViewController.h、SuperID.h,SuperIDDelegate.h 共5个文件。为了更好的管理文档，注意记得把这五个文档归为一个Group中。

![](http://superid.me/document/iOS_images/iOSDemo_file.png)

5. 在工程引入静态库之后"需要在编译时添加 -ObjC 和 -lstdc++ 编译选项。方法：xcodeproj->Build Settings->Linking->Other Linker Flags,在 Other Linker Flags 选项中，双击该选项，点击弹出框左下角的 + 按钮，分别添加 “-ObjC” 字符和 “-lstdc++” 字符（如下图）。

![](http://superid.me/document/iOS_images/iOSDemo_flag.png)

6. 添加依赖库,

如果你的应用无法正常通过编译，请添加SDK所需的依赖库。主要为：

* CoreTelephony.framework

* CoreMedia.framework

* AVFoundation.framework

* libc++.dylib

添加路径为：工程->Build Phases->Link Binary With Libraries->Add->选择上述的依赖库。

------------

###SDK初始化

注意，我们的项目使用的是Swift语言，但是一登SDK是用objective-c编写的。你可能会焦急，这个怎么办？ 不用担心，Apple公司允许开发人员，在Swift中调用objective-c，需要进行桥接。怎么做呢？看下面的步骤。

按command+n 创建一个新文件，选择IOS-->Source-->Cocoa Touch Class,随意输入类名，例如OC
Object,注意选择语言为objective-c。当你在Swift项目中创建一个object-c文件时候，XCode会自动提示你，创建  项目名称-Bridging-Header.h 文件（这里是 ZHEmotionMusic-Bridging-Header.h），这个文件起桥接作用，你可以在上面引入你需要调用的objective-c头文件，方式和普通的objective-c引入头文件类似，例如，在项目中会使用到 SuperID.h 。所以在里面添加：

		#import "SuperID.h"


声明完后，就可以在项目中使用一登SDK了，不过注意的是，在项目中，我们是使用Swift代码进行编写，即使调用objective-c的类，也是使用Swift方式调用，XCode会帮你转换，这个不用我们担心。


####填写一登APPID和APPSecret

在SDK文档中有介绍，调用的借口为

	- (void)registerAppWithAppID:(NSString *)appID withAppSecret:(NSString *)appSecret;

具体的代码为：

		- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
		
		    [[SuperID sharedInstance]registerAppWithAppID:@"应用的AppID" withAppSecret:@"应用的AppSecret"];
		
		    return YES;
		}


在我们的项目中，使用Swift编写代码如下：

		func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		        // Override point for customization after application launch.
		        
		        
		        //在代码中向一登 SDK 注册你的 AppID 和 AppSecret
		        SuperID.sharedInstance().registerAppWithAppID("LDYEYQoR6lnpA2mehpZVzvzK", withAppSecret: "sETEcYSE1g5OYnmLwSybGheY")
		        
		        //设置SDK语言模式为简体中文
		        SuperID.setLanguageMode(SIDLanguageMode.SimplifiedChineseMode)
		        
		        //设置SDK调试模式，应用发布时，注意需要关闭
		        SuperID.setDebugMode(true);
		        
		        return true
		    }


至此，一登SDK接入完毕，下面看如何调用其人脸识别的功能。

--------
			
				
###调用一登SDK获得人脸属性。

在您调用 SIDEmotionViewController(具有人脸识别的View Controller) 的当前 View Controller 中，您需要设置当前 View Controller 作为 SDK 的协议委托对象，并在当前 VC 中声明继承一登 SDK 的Protocol（SuperIDDelegate）并声明 SDK 单例对象，具体代码如下所示。

		//先让当前ViewController 实现 SuperIDDelegate 协议
		class ViewController: UIViewController , SuperIDDelegate 

然后重载viewWillAppear方法。

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


然后，在storyboard中，首先选中当前的ViewController，然后在Utilities中的Attributes Inspector中，调整size为iphone4-inch(个人喜好，不喜欢方形的)，然后，添加一个button，放在当前View Controller 中间，然后选中button，按control键，连接button至ViewController中，选择Connection为Action，命名为getFaceFeature。现在的目的是，测试一登的SDK,我们希望，点击button，能够调用用于完成人脸属性检测的ViewController，代码如下：

		@IBAction fun getFaceFeature(sender: AnyObject) {
		        //getAuthorityOfCamera()
		        
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

按Command+B，若无错误，则说明上面的步骤正确。可能会有一些警告信息，可以忽略。

可以进行测试，注意，因为表情识别会用到，摄像头，可是IOS simulator不支持，所以，需要使用真机进行测试，这需要苹果开发者账号，如果没有，可以选在在淘宝上搜 “Xcode 真机测试”，可以允许你在mac上对一台iphone进行真机测试，具体怎么做，可以淘宝搜，店主会详细告诉你。

如果，你一切顺利，当点击按钮，会提示你，没有权限，下面我们需要写一段代码，让用户每次点击按钮，如果用户没有获得摄像头的权限，可以选择赋予摄像头权限，代码的逻辑很简单，就是先检查当前的权限的状态，然后根据状态进行判断。代码如下：

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
	
然后，注意将getFaceFeature中的一个注释去掉。

	 getAuthorityOfCamera()  // 去掉注释。
	 
然后编译运行试试，会出现一个新的界面，界面使用了前置摄像头，你只需将脸对着前置摄像头，从而进行识别。

你会奇怪，识别完后，似乎什么事情都没有发生，这是因为，你并没有设定，识别完后做什么。其实。当一登用户在一登 SDK 完成人脸属性检测事件后，SDK 将执行协议中的相应方法，开发者可在对应的方法中进行根据需要相应事件处理。方法是superID，我们需要实现它。代码如下：

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
		           		            
		        }
		        else{
		            println("操作失败!")
		            
		            println("\(error.code)   \(error.description)")
		        }
		    }

当你再次运行，你会在All out中，发现，输出了一些内容。例如：

		操作成功!
		[eyeglasses: {
		    result = 1;
		    score = "0.992422";
		}, male: {
		    result = 1;
		    score = "0.999256";
		}, sunglasses: {
		    result = 0;
		    score = "0.393262";
		}, smiling: {
		    result = 0;
		    score = "0.001676";
		}, age: 25.96, resource_id: 55620c94de77d8ae668e1fc4, mustache: {
		    result = 1;
		    score = "0.518885";
		}]

好了，一登SDK暂且OK。下面让我们美化一下。


------------------

###简单美化下

	
		顺便提一句，app_icon ，是用Sketch来设计制作的，请大家体谅一下，不是Sketch不好用，而是本人捉急的艺术功底。

先看 app_icon.png,这个拖至Images.xcassets的AppIcon中。

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/app_icon.png)

再添加几个图片，

basic.png

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/basic.png)

happy.png

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/happy.png)

sad.png

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/sad.png)


这些是后面步骤会使用到的图片。现在AppIcon已经有图片了，所以当你再次运行时，iphone手机上的图标就有了。现在我们改改图标下面显示的App名字。也很简单，就是打开Supporting Files-->Info.plist文件，找到，Bundle name，修改为-->小贼音乐。如图所示：

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/image2.png)

打开Main.storyboard，删除原来的button，现在选择一个image View放到上面，设置大小为250*250，设置图片为basic， 再添加两个label，最后，如图所示：

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/image3.png)

上面的image view 和两个label都使用了auto layout布局，这个大家可以去了解一下，然后选择合适的方式将它们展示出来就可以了。

注意需要设定中间ImageView的layer.cornerRadius，不少人喜欢在代码中实现，但本人懒，不太喜欢用代码。但是，有无法直接在ImageView的属性中进行设定，推荐大家一种方式，使用User Defined Runtime Attributes，详情可看[这里](http://spin.atomicobject.com/2014/05/30/xcode-runtime-attributes/)。最终，如下图：

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/image4.png)


按control，将image view和两个label都绑定到View Controller中。

	  ///ImageView实例
	    @IBOutlet weak var imageView: UIImageView!
	    
	    ///第一个Label标签
	    @IBOutlet weak var label1: UILabel!
	    
	    /// 第二个Label标签
	    @IBOutlet weak var label2: UILabel!
	
在Main.storyboard中，给当前的view Controller 添加一个Long Press Gesture Recognizer，因为设定是长按屏幕，进行扫描人脸。如果不了解 Gesture recognizer，可以去了解一下，简单的说，就是手势识别，这个Long Press Gesture Recognizer是专门用来识别长按屏幕这个手势操作的，是苹果官方提供的手势识别，当然你也可以自己写自己的手势，不过我们暂时使用这个手势就足够了。

按control将手势连接至ViewController，选择Action，命名位longPressAction，大致内容和上面的getFaceFeature一样。


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


但我们更新一下，实现的协议方法superID，


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

最后一个步骤，让我们修改一下Launch image，查看  项目--> General --> App Icons and Launch Images --> Launch screen file。 默认的Launch image是LaunchScreen.xib，这个在项目创建时自动生成的，在这里，我们选择Main.storyboard作为Launch image。 

可以尝试运行，测试一下结果如何。第一步，暂时到此结束。


-------


笔者注：欢迎非商业转载，但请一定注明出处


如果你认为这篇不错，也有闲钱，那你可以用支付宝随便捐助一快两块的，以慰劳笔者的辛苦：


![](http://zhonghuan.qiniudn.com/ZH_zhifubao.png)

