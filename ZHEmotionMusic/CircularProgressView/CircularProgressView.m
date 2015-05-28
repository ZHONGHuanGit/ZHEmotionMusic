//
//  CircularProgressView.m
//  CircularProgressView
//
//  Created by 钟桓 on 15/5/23.
//  Copyright (c) 2015年 ZH. All rights reserved.

#import "CircularProgressView.h"
#import <QuartzCore/QuartzCore.h>

@interface CircularProgressView ()

@property (nonatomic) CADisplayLink *displayLink;
@property (nonatomic) MPMoviePlayerController *player;//an AVAudioPlayer instance
@property (nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) float progress;
@property (nonatomic) CGFloat angle;//angle between two lines

@end

@implementation CircularProgressView

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth
           audioURL:(NSURL *)audioURL {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
        _backColor = backColor;
        _progressColor = progressColor;
        self.lineWidth = lineWidth;
        _audioURL = audioURL;
//        _player.delegate = self;
        [_player prepareToPlay];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp{
    
    _player = [[MPMoviePlayerController alloc] init];
    
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
    [self setNotification];
}

- (void)setLineWidth:(CGFloat)lineWidth{
    CAShapeLayer *backgroundLayer = [self createRingLayerWithCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:CGRectGetWidth(self.bounds) / 2 - lineWidth / 2 lineWidth:lineWidth color:self.backColor];
    _lineWidth = lineWidth;
    [self.layer addSublayer:backgroundLayer];
    _progressLayer = [self createRingLayerWithCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:CGRectGetWidth(self.bounds) / 2 - lineWidth / 2 lineWidth:lineWidth color:self.progressColor];
    _progressLayer.strokeEnd = 0;
    [self.layer addSublayer:_progressLayer];
}

- (void)setAudioURL:(NSURL *)audioURL{
    if (audioURL) {
        [self stop];
        _player.contentURL = audioURL;
        self.duration = self.player.duration;
        [self.player prepareToPlay];
    }
    _audioURL = audioURL;
}

- (CAShapeLayer *)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:- M_PI_2 endAngle:(M_PI + M_PI_2) clockwise:YES];
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.contentsScale = [[UIScreen mainScreen] scale];
    slice.frame = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.strokeColor = color.CGColor;
    slice.lineWidth = lineWidth;
    slice.lineCap = kCALineJoinBevel;
    slice.lineJoin = kCALineJoinBevel;
    slice.path = smoothedPath.CGPath;
    return slice;
}

- (void)setProgress:(float)progress{
    if (progress == 0) {
        self.progressLayer.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressLayer.strokeEnd = 0;
        });
    }else {
        self.progressLayer.hidden = NO;
        self.progressLayer.strokeEnd = progress;
    }
}

- (void)updateProgressCircle{
    //update progress value
    self.progress = (float) (self.player.currentPlaybackTime / self.player.duration);
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(CircularProgressViewDelegate)]) {
        [self.delegate updateProgressViewWithPlayer:self.player];
    }
}


- (void)play{
    
    if ( self.player.playbackState != MPMoviePlaybackStatePlaying) {
        if (self.displayLink == nil) {
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgressCircle)];
            self.displayLink.frameInterval = 6;
            [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        } else {
            self.displayLink.paused = NO;
        }
        [self.player play];
//        printf("play!");
    }
}

- (void)pause{
    if (self.player.playbackState == MPMoviePlaybackStatePlaying) {
        self.displayLink.paused = YES;
        [self.player pause];
    }
}

- (void)stop{
    [self.player stop];
    self.progress = 0;
    self.player.currentPlaybackTime = 0;
    
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void) setNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidFinishPlaying)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
}

#pragma mark MPMoviePlayer notification handler method
- (void)audioPlayerDidFinishPlaying{
        [self.displayLink invalidate];
        self.displayLink = nil;
        //restore progress value
        self.progress = 0;
//    printf("结束！");
        [self.delegate playerDidFinishPlaying];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationInView:self];
    self.angle = [self angleFromStartToPoint:point];
    self.player.currentPlaybackTime = self.player.duration * (self.angle / (2 * M_PI));
    self.progress = self.angle/(M_PI * 2);
    if (self.player.playbackState != MPMoviePlaybackStatePlaying) {
        [self play];
    }
    [self.delegate updatePlayOrPauseButton];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.displayLink.paused = YES;
        CGPoint point = [recognizer locationInView:self];
        self.angle = [self angleFromStartToPoint:point];
        self.progress = self.angle/(M_PI * 2);
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(CircularProgressViewDelegate)]) {
            [self.delegate updateProgressViewWithPlayer:self.player];
        }
    }

    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.player.currentPlaybackTime = self.player.duration * (self.angle / (2 * M_PI));
        if (self.player.playbackState != MPMoviePlaybackStatePlaying)
            [self play];
        else
            self.displayLink.paused = NO;
       [self.delegate updatePlayOrPauseButton];
    }
}

//calculate angle between start to point
- (CGFloat)angleFromStartToPoint:(CGPoint)point{
    CGFloat angle = [self angleBetweenLinesWithLine1Start:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2)
                                                 Line1End:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2 - 1)
                                               Line2Start:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2)
                                                 Line2End:point];
    if (CGRectContainsPoint(CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame)), point)) {
        angle = 2 * M_PI - angle;
    }
    return angle;
}

//calculate angle between 2 lines
- (CGFloat)angleBetweenLinesWithLine1Start:(CGPoint)line1Start
                                  Line1End:(CGPoint)line1End
                                Line2Start:(CGPoint)line2Start
                                  Line2End:(CGPoint)line2End{
    CGFloat a = line1End.x - line1Start.x;
    CGFloat b = line1End.y - line1Start.y;
    CGFloat c = line2End.x - line2Start.x;
    CGFloat d = line2End.y - line2Start.y;
    return acos(((a * c) + (b * d)) / ((sqrt(a * a + b * b)) * (sqrt(c * c + d * d))));
}

@end