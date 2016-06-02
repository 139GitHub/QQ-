//
//  XMGPlayingViewController.m
//  04-QQMusic
//
//  Created by xiaomage on 15/12/18.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGPlayingViewController.h"
#import "Masonry.h"
#import "XMGMusicTool.h"
#import "XMGMusic.h"
#import "XMGAudioTool.h"
#import "NSString+XMGTimeExtension.h"
#import "CALayer+PauseAimate.h"
#import "XMGLrcView.h"
#import "XMGLrcLabel.h"
#import <MediaPlayer/MediaPlayer.h>

#define XMGColor(r,g,b,a)[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface XMGPlayingViewController () <UITableViewDelegate>
/** 歌手背景图片 */
@property (weak, nonatomic) IBOutlet UIImageView *albumView;
/** 进度条 */
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
/** 歌手图片 */
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
/** 歌曲名 */
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
/** 歌手名 */
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
/** 当前播放时间 */
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
/** 歌曲的总时间 */
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
/** 歌词的总时间 */
@property (weak, nonatomic) IBOutlet XMGLrcView *lrcView;

/** 播放暂停按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;

@property (weak, nonatomic) IBOutlet XMGLrcLabel *lrcLabel;

/** 进度条时间 */
@property (nonatomic, strong) NSTimer *progressTimer;

/** 歌词的定时器 */
@property (nonatomic, strong) CADisplayLink *lrcTimer;

/** 播放器 */
@property (nonatomic, strong) AVAudioPlayer *currentPlayer;

#pragma mark - 进度条事件处理
- (IBAction)start;
- (IBAction)end;
- (IBAction)progressValueChange;
- (IBAction)sliderClick:(UITapGestureRecognizer *)sender;

#pragma mark - 按钮点击事件
- (IBAction)playOrPause;
- (IBAction)next;
- (IBAction)previous;


@end

@implementation XMGPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.添加毛玻璃效果
    [self setupBlur];
    
    // 2.改变滑块的图片
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    
    // 3.将lrcView中的lrcLable设置为主控制器的LrcLabel
    self.lrcView.lrcLabel = self.lrcLabel;
    
    // 4.开始播放音乐
    [self startPlayingMusick];
    
    // 5.设置歌词view contentsize
    self.lrcView.contentSize = CGSizeMake(self.view.bounds.size.width * 2, 0);
    
    // 6.接受通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addIconViewAnimate) name:@"XMGIconViewNotification" object:nil];
    
}

#pragma mark - 开始播放音乐
- (void)startPlayingMusick
{
    // 0.清除之前的歌词
    self.lrcLabel.text = nil;
    
    // 1.获取当前正在播放的音乐
    XMGMusic *playingMusic = [XMGMusicTool playingMusic];
    
    // 2.设置界面信息
    self.albumView.image = [UIImage imageNamed:playingMusic.icon];
    self.iconView.image = [UIImage imageNamed:playingMusic.icon];
    self.songLabel.text = playingMusic.name;
    self.singerLabel.text = playingMusic.singer;
    
    // 3.播放音乐
    AVAudioPlayer *currentPlayer = [XMGAudioTool playMusicWithFileName:playingMusic.filename];
    self.currentTimeLabel.text = [NSString stringWithTime:currentPlayer.currentTime];
    self.totalTimeLabel.text = [NSString stringWithTime:currentPlayer.duration];
    self.currentPlayer = currentPlayer;
    
    // 3.1设置播放按钮
    self.playOrPauseBtn.selected = self.currentPlayer.isPlaying;
    // 3.2设置歌词
    self.lrcView.lrcName = playingMusic.lrcname;
    self.lrcView.duration = currentPlayer.duration;

        // 4.开启定时器,现将之前的定时器移除
    [self removeProgressTimer];
    [self addProgressTimer];
    [self removeLrcTimer];
    [self addLrcTimer];
    
    // 5.添加iconView的动画
    [self addIconViewAnimate];
}

#pragma mark - 添加iconView的动画
- (void)addIconViewAnimate
{
    CABasicAnimation *rotateAnimate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimate.fromValue = @(0);
    rotateAnimate.toValue = @(M_PI * 2);
    rotateAnimate.repeatCount = NSIntegerMax;
    rotateAnimate.duration = 35;
    [self.iconView.layer addAnimation:rotateAnimate forKey:nil];
    
    // 更新动画是否进入后台
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"iconViewAnimate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 添加毛玻璃效果
- (void)setupBlur
{
    // 1.初始化toolBar
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [self.albumView addSubview:toolBar];
    toolBar.barStyle = UIBarStyleBlack;
    
    // 2.添加约束
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.albumView);
    }];
}

#pragma mark - 布局子控件
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // 添加圆角
    self.iconView.layer.cornerRadius = self.iconView.bounds.size.width * 0.5;
    self.iconView.layer.masksToBounds = YES;
    self.iconView.layer.borderColor = XMGColor(36, 36, 36, 1.0).CGColor;
    self.iconView.layer.borderWidth = 8;
}

#pragma mark - 对歌词定时器的处理
- (void)addLrcTimer
{
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrcInfo)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLrcTimer
{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}

#pragma mark 更新歌词进度
- (void)updateLrcInfo
{
    self.lrcView.currentTime = self.currentPlayer.currentTime;
}

#pragma mark - 对进度条时间的处理
- (void)addProgressTimer
{
    // 1.提前更新数据
    [self updateProgressInfo];
    
    // 2.添加定时器
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer  forMode:NSRunLoopCommonModes];
}

#pragma mark 移除定时器
- (void)removeProgressTimer
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

#pragma mark - 更新进度条
- (void)updateProgressInfo
{
    // 1.更新播放的时间
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    
    // 2.更新滑动条
    self.progressSlider.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
}

#pragma mark - slider 事件处理
- (IBAction)start {
    // 移除定时器
    [self removeProgressTimer];
}

- (IBAction)end {
    
    // 1.更新播放的时间
    self.currentPlayer.currentTime = self.progressSlider.value * self.currentPlayer.duration;
    
    // 2.添加定时器
    [self addProgressTimer];
}

- (IBAction)progressValueChange {
    self.currentTimeLabel.text = [NSString stringWithTime:self.progressSlider.value * self.currentPlayer.duration];
}

- (IBAction)sliderClick:(UITapGestureRecognizer *)sender {

    // 1.获取点击到的点
    CGPoint point = [sender locationInView:sender.view];
    
    // 2.获取点击的比例
    CGFloat ratio = point.x / self.progressSlider.bounds.size.width;
    
    // 3.更新播放的时间
    self.currentPlayer.currentTime = self.currentPlayer.duration * ratio;
    
    // 4.更新时间和滑块的位置
    [self updateProgressInfo];
}

#pragma mark - 播放按钮的处理
- (IBAction)playOrPause {
    self.playOrPauseBtn.selected = !self.playOrPauseBtn.selected;
    if (self.currentPlayer.playing) {
        // 1.暂停播放器
        [self.currentPlayer pause];
        
        // 2.移除定时器
        [self removeProgressTimer];
        
        // 3.暂停旋转动画
        [self.iconView.layer pauseAnimate];
        
    } else {
        // 1.开始播放
        [self.currentPlayer play];
        
        // 2.添加定时器
        [self addProgressTimer];
        
        // 3.恢复动画
        [self.iconView.layer resumeAnimate];
    }
}

- (IBAction)next {
    
    // 1.获取下一首歌
    XMGMusic *nextMusic = [XMGMusicTool nextMusic];
    
    // 2.播放下一首音乐
    [self playMusicWithMusic:nextMusic];
}

- (IBAction)previous {
    
    // 1.取出上一首音乐
    XMGMusic *previousMusic = [XMGMusicTool previousMusic];
    
    // 2.播放上一首音乐
    [self playMusicWithMusic:previousMusic];
}

- (void)playMusicWithMusic:(XMGMusic *)muisc
{
    // 1.获取当前播放的歌曲并停止
    XMGMusic *currentMusic = [XMGMusicTool playingMusic];
    [XMGAudioTool stopMusicWithFileName:currentMusic.filename];
    
    // 2.设置上一首歌为默认播放的歌曲
    [XMGMusicTool setupPlayingMusic:muisc];
    
    // 3.播放音乐,并更新界面信息
    [self startPlayingMusick];
}

#pragma mark UIScrollView 代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 1.获取滑动的偏移量
    CGPoint point =  scrollView.contentOffset;
    
    // 2.获取滑动比例
    CGFloat alpha = 1 - point.x / scrollView.bounds.size.width;
    
    // 3.设置alpha
    self.iconView.alpha = alpha;
    self.lrcLabel.alpha = alpha;
}

/*
#pragma mark - 设置锁屏信息
- (void)setupLockScreenInfo
{
 
     // MPMediaItemPropertyAlbumTitle
     // MPMediaItemPropertyAlbumTrackCount
     // MPMediaItemPropertyAlbumTrackNumber
     // MPMediaItemPropertyArtist
     // MPMediaItemPropertyArtwork
     // MPMediaItemPropertyComposer
     // MPMediaItemPropertyDiscCount
     // MPMediaItemPropertyDiscNumber
     // MPMediaItemPropertyGenre
     // MPMediaItemPropertyPersistentID
     // MPMediaItemPropertyPlaybackDuration
     // MPMediaItemPropertyTitle
 
    
    // 0.获取当前播放的歌曲
    XMGMusic *playingMusic = [XMGMusicTool playingMusic];
    
    // 1.获取锁屏中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // 2.设置锁屏参数
    NSMutableDictionary *playingInfoDict = [NSMutableDictionary dictionary];
    // 2.1设置歌曲名
    [playingInfoDict setObject:playingMusic.name forKey:MPMediaItemPropertyAlbumTitle];
    // 2.2设置歌手名
    [playingInfoDict setObject:playingMusic.singer forKey:MPMediaItemPropertyArtist];
    // 2.3设置封面的图片
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:playingMusic.icon]];
    [playingInfoDict setObject:artwork forKey:MPMediaItemPropertyArtwork];
    // 2.4设置歌曲的总时长
    [playingInfoDict setObject:@(self.currentPlayer.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    playingInfoCenter.nowPlayingInfo = playingInfoDict;
    
    // 3.开启远程交互
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}
*/

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    /*
     UIEventSubtypeRemoteControlPlay                 = 100,
     UIEventSubtypeRemoteControlPause                = 101,
     UIEventSubtypeRemoteControlStop                 = 102,
     UIEventSubtypeRemoteControlTogglePlayPause      = 103,
     UIEventSubtypeRemoteControlNextTrack            = 104,
     UIEventSubtypeRemoteControlPreviousTrack        = 105,
     UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
     UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
     UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
     UIEventSubtypeRemoteControlEndSeekingForward    = 109,
     */
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playOrPause];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous];
            break;
            
        default:
            break;
    }
}

#pragma mark - 改变状态栏的文字颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 移除通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
