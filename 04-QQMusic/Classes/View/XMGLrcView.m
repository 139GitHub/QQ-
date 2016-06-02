//
//  XMGLrcView.m
//  04-QQMusic
//
//  Created by xiaomage on 15/12/18.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGLrcView.h"
#import "Masonry.h"
#import "XMGLrcCell.h"
#import "XMGLrcTool.h"
#import "XMGLrcLine.h"
#import "XMGLrcLabel.h"
#import "XMGMusic.h"
#import "XMGMusicTool.h"
#import <MediaPlayer/MediaPlayer.h>

@interface XMGLrcView ()<UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

/** 歌词数组 */
@property (nonatomic, strong) NSArray *lrcList;

/** 记录当前刷新的某行 */
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation XMGLrcView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        // 初始化TableView
        [self setupTableView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 初始化TableView
        [self setupTableView];
    }
    return self;
}

#pragma mark - 初始化TableView
- (void)setupTableView
{
    // 1.初始化
    UITableView *tableView = [[UITableView alloc] init];
    [self addSubview:tableView];
    self.tableView = tableView;
    
    // 2.设置数据源
    tableView.dataSource = self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 1.添加约束
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(self.mas_height);
        make.right.equalTo(self.mas_right);
        make.left.equalTo(self.mas_left).offset(self.bounds.size.width);
        make.width.equalTo(self.mas_width);
    }];
    
    // 2.改变tableView属性
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 40;
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.bounds.size.height * 0.5, 0, self.tableView.bounds.size.height * 0.5, 0);
}

#pragma mark - UITableView数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lrcList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMGLrcCell *cell = [XMGLrcCell lrcCellWithTableView:tableView];

    if (self.currentIndex == indexPath.row) {
        cell.lrcLabel.font = [UIFont systemFontOfSize:20];
    } else {
        cell.lrcLabel.font = [UIFont systemFontOfSize:14];
        cell.lrcLabel.progress = 0;
    }
    
    // 1.取出数据模型
    XMGLrcLine *lrcLine = self.lrcList[indexPath.row];
    
    // 2.设置数据
    cell.lrcLabel.text = lrcLine.text;
    
    return cell;
}

#pragma mark - 重写lrcName
- (void)setLrcName:(NSString *)lrcName
{
    
    // -1让tableView滚到中间
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.bounds.size.height * 0.5) animated:NO];
    
    // 0.将currentIndex设置为0
    self.currentIndex = 0;
    
    // 1.记录歌词名
    _lrcName = [lrcName copy];
    
    // 2.解析歌词
    self.lrcList = [XMGLrcTool lrcToolWithLrcName:lrcName];
    // 2.1设置第一句歌词
    XMGLrcLine *firstLrcLine = self.lrcList[0];
    self.lrcLabel.text = firstLrcLine.text;
    
    // 3.刷新表格
    [self.tableView reloadData];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
//        
//    });
}

#pragma mark - 重写currentTime set方法
- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    // 1.记录当前的播放时间
    _currentTime = currentTime;
    
    // 2.判断显示哪句歌词
    NSInteger count = self.lrcList.count;
    for (NSInteger i = 0; i<count; i++) {
        // 2.1取出当前的歌词
        XMGLrcLine *currentLrcLine = self.lrcList[i];
        
        // 2.2取出下一句歌词
        NSInteger nextIndex = i + 1;
        XMGLrcLine *nextLrcLine = nil;
        if (nextIndex < self.lrcList.count) {
            nextLrcLine = self.lrcList[nextIndex];
        }
        
        // 2.3用当前播放器的时间,跟当前这句歌词的时间和下一句歌词的时间进行比对,如果大于等于当前歌词的时间,并且小于下一句歌词的时间,就显示当前的歌词
        if (self.currentIndex != i && currentTime >= currentLrcLine.time && currentTime < nextLrcLine.time) {
            
            // 1.获取当前这句歌词和上一句歌词的IndexPath
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            
            // 2.记录当前刷新的某行
            self.currentIndex = i;
            
            // 3.刷新当前这句歌词,并且刷新上一句歌词
            [self.tableView reloadRowsAtIndexPaths:@[indexPath,previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            // 4.将当前的这句歌词滚动到中间
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            // 5.设置主界面歌词的文字
            self.lrcLabel.text = currentLrcLine.text;
            
            // 6.生成锁屏图片
            [self genaratorLockImage];
        }
        
        if (self.currentIndex == i) { // 当前这句歌词

            // 1.用当前播放器的时间减去当前歌词的时间除以(下一句歌词的时间-当前歌词的时间)
            CGFloat value = (currentTime - currentLrcLine.time) / (nextLrcLine.time - currentLrcLine.time);
            
            // 2.设置当前歌词播放的进度
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            XMGLrcCell *lrcCell = [self.tableView cellForRowAtIndexPath:indexPath];
            lrcCell.lrcLabel.progress = value;
            self.lrcLabel.progress = value;
        }
    }
}

#pragma mark - 生成锁屏图片
- (void)genaratorLockImage
{
    // 1.获取当前音乐的图片
    XMGMusic *playingMusic = [XMGMusicTool playingMusic];
    UIImage *currentImage = [UIImage imageNamed:playingMusic.icon];
    
    // 2.取出歌词
    // 2.1取出当前的歌词
    XMGLrcLine *currentLrcLine = self.lrcList[self.currentIndex];
    
    // 2.2取出上一句歌词
    NSInteger previousIndex = self.currentIndex - 1;
    XMGLrcLine *previousLrcLine = nil;
    if (previousIndex >= 0) {
        previousLrcLine = self.lrcList[previousIndex];
    }
    
    // 2.3取出下一句歌词
    NSInteger nextIndex = self.currentIndex + 1;
    XMGLrcLine *nextLrcLine = nil;
    if (nextIndex < self.lrcList.count) {
        nextLrcLine = self.lrcList[nextIndex];
    }
    
    // 3.生成水印图片
    // 3.1获取上下文
    UIGraphicsBeginImageContext(currentImage.size);
    
    // 3.2将图片画上去
    [currentImage drawInRect:CGRectMake(0, 0, currentImage.size.width, currentImage.size.height)];
    
    // 3.3将文字画上去
    CGFloat titleH = 25;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment =  NSTextAlignmentCenter;
    NSDictionary *attributes1 = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                  NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                  NSParagraphStyleAttributeName : paragraphStyle};
    [previousLrcLine.text drawInRect:CGRectMake(0, currentImage.size.height - titleH * 3, currentImage.size.width, titleH) withAttributes:attributes1];
    [nextLrcLine.text drawInRect:CGRectMake(0, currentImage.size.height - titleH, currentImage.size.width, titleH) withAttributes:attributes1];
    
    NSDictionary *attributes2 =  @{NSFontAttributeName : [UIFont systemFontOfSize:20],
                                   NSForegroundColorAttributeName : [UIColor whiteColor],
                                   NSParagraphStyleAttributeName : paragraphStyle};
    [currentLrcLine.text drawInRect:CGRectMake(0, currentImage.size.height - titleH *2, currentImage.size.width, titleH) withAttributes:attributes2];
    
    // 3.4获取画好的图片
    UIImage *lockImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 3.5关闭上下文
    UIGraphicsEndImageContext();
    
    // 3.6设置锁屏界面的图片
    [self setupLockScreenInfoWithLockImage:lockImage];
    
}

#pragma mark - 设置锁屏信息
- (void)setupLockScreenInfoWithLockImage:(UIImage *)lockImage
{
    /*
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
     */
    
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
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:lockImage];
    [playingInfoDict setObject:artwork forKey:MPMediaItemPropertyArtwork];
    // 2.4设置歌曲的总时长
    [playingInfoDict setObject:@(self.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    
    // 2.4设置歌曲当前的播放时间
    [playingInfoDict setObject:@(self.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    playingInfoCenter.nowPlayingInfo = playingInfoDict;
    
    // 3.开启远程交互
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

@end
