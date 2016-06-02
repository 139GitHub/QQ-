//
//  XMGMusicTool.h
//  04-QQMusic
//
//  Created by xiaomage on 15/12/18.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XMGMusic;
@interface XMGMusicTool : NSObject

// 所有音乐
+ (NSArray *)musics;

// 当前正在播放的音乐
+ (XMGMusic *)playingMusic;

// 设置默认的音乐
+ (void)setupPlayingMusic:(XMGMusic *)playingMusic;

// 返回上一首音乐
+ (XMGMusic *)previousMusic;

// 返回下一首音乐
+ (XMGMusic *)nextMusic;

@end
