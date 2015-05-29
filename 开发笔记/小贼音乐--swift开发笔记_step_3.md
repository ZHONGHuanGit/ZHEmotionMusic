#小贼音乐--Swift开发笔记 Step 3

-------

小贼音乐的最终效果如下：

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/zhEmotionMusicInfo.gif)

-------


在step2中，我们完成了一个简易版本的，能够通过扫描人脸进行播放歌曲的音乐播放器。在前面我们也提到了，一登默认的权限，并没有获取表情的功能，幸运的是，本人申请得到了这个高级权限(一登的负责的哥们儿还是挺好说话的，哈哈，可以尝试申请弄个权限来玩玩，题外话，高级功能中，本人的颜值只有0.3，满分是1，o(╯□╰)o)。

所以，现在有表情识别的权限了，当然想把它做得更好一些了。不过暂时我只选取了四个表情进行识别，分别是：

1. Happy 
2. Sad
3. Calm
4. Angry

其余表情，个人感觉放在音乐中，不是特别合适.然后，我们在storyboard中，添加一个view，放到当前viewController底部。是一个固定高度120的view，再添加几个表情，最终效果图如下:

![](https://raw.githubusercontent.com/ZHONGHuanGit/ZHEmotionMusic/master/开发笔记/images/image7.PNG)


注意，底部的表情，使用的是autolayout的等距离约束，如果不了解的话，可以看这篇[blog](http://devtian.me/2015/03/25/如何在Autolayout中设置等距约束/),到我的github山，可以下载这些表情图片，顺便说一下，表情都是使用sketch简单的制作，颜值不是很高。

然后新建一个MoodUIView类，继承UIView，将最底下view对应的类改为MoodUIView，绑定MoodUIView到viewController中，并且增添一个swipeHandler方法，来处理上下滑动手势。

 
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


然后，在viewDidLoad中添加：

	 		//添加Swipgesture
	        var up = UISwipeGestureRecognizer(target: self, action: "swipeHandler:")
	        var down = UISwipeGestureRecognizer(target: self, action: "swipeHandler:")
	        
	        up.direction = .Up
	        down.direction = .Down
	        
	        self.view.addGestureRecognizer(up)
	        self.view.addGestureRecognizer(down)
	

运行后，可以看到上下滑动的手势操作效果。

在main.storyboard中，给每个表情图标和对应的label，添加一个不带透明的button，用来响应点击事件。这里的点击事件，就是用户，手动选择更换频道。添加方法：


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
	        
	        updateMoodView()
	        
	          UIView.animateWithDuration( 0.3 , delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            self.moodView.center.y += 120
            
            }, completion: { (ok) -> Void in
        })

	        
	        http.onSearch(emotion.rawValue)
	        
	    }
	
接下来，需要增加一个pan gesture，初定的功能是，向左pan切换歌曲，向右暂停。

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

还有部分操作，不过可以查看源码，获取详情。


