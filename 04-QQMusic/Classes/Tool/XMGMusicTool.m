//
//  XMGMusicTool.m
//  04-QQMusic
//
//  Created by xiaomage on 15/12/18.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGMusicTool.h"
#import "XMGMusic.h"
#import "MJExtension.h"

@implementation XMGMusicTool

static NSArray *_musics;
static XMGMusic *_playingMusic;

+ (void)initialize
{
    if (_musics == nil) {
        _musics = [XMGMusic objectArrayWithFilename:@"Musics.plist"];
    }
    
    if (_playingMusic == nil) {
        _playingMusic = _musics[1];
    }
}

+ (NSArray *)musics
{
    return _musics;
}

+ (XMGMusic *)playingMusic
{
    return _playingMusic;
}

+ (void)setupPlayingMusic:(XMGMusic *)playingMusic
{
    _playingMusic = playingMusic;
}

+ (XMGMusic *)previousMusic
{
    // 1.获取当前音乐的下标值
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    
    // 2.获取上一首音乐的下标值
    NSInteger previousIndex = --currentIndex;
    XMGMusic *previousMusic = nil;
    if (previousIndex < 0) {
        previousIndex = _musics.count - 1;
    }
    previousMusic = _musics[previousIndex];
    
    return previousMusic;
}


+ (XMGMusic *)nextMusic
{
    // 1.获取当前音乐的下标值
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    
    // 2.获取下一首音乐的下标值
    NSInteger nextIndex = ++currentIndex;
    XMGMusic *nextMusic = nil;
    if (nextIndex >= _musics.count) {
        nextIndex = 0;
    }
    nextMusic = _musics[nextIndex];
    
    return nextMusic;
}




@end
