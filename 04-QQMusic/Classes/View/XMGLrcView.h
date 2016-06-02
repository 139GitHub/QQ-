//
//  XMGLrcView.h
//  04-QQMusic
//
//  Created by xiaomage on 15/12/18.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMGLrcLabel;
@interface XMGLrcView : UIScrollView

/** 歌词名 */
@property (nonatomic, copy) NSString *lrcName;

/** 当前播放器播放的时间 */
@property (nonatomic, assign) NSTimeInterval currentTime;

/** 主界面歌词的Lable */
@property (nonatomic, weak) XMGLrcLabel *lrcLabel;

/** 当前播放器总时间时间 */
@property (nonatomic, assign) NSTimeInterval duration;

@end
