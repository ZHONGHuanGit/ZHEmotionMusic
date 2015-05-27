//
//  CircularProgressView.h
//  CircularProgressView
//
//
//  Created by 钟桓 on 15/5/23.
//  Copyright (c) 2015年 ZH. All rights reserved.
//


#import <UIKit/UIKit.h>
//#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol CircularProgressViewDelegate <NSObject>

@optional

- (void)updateProgressViewWithPlayer:(MPMoviePlayerController *)player;
- (void)updatePlayOrPauseButton;
- (void)playerDidFinishPlaying;

@end

@interface CircularProgressView : UIView

@property (nonatomic) UIColor *backColor;
@property (nonatomic) UIColor *progressColor;
@property (nonatomic) NSURL *audioURL;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) BOOL playOrPauseButtonIsPlaying;
@property (nonatomic) id <CircularProgressViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth
           audioURL:(NSURL *)audioURL;

- (void)play;
- (void)pause;
- (void)stop;

@end