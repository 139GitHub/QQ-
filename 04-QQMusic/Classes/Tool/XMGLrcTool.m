//
//  XMGLrcTool.m
//  04-QQMusic
//
//  Created by xiaomage on 15/12/18.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGLrcTool.h"
#import "XMGLrcLine.h"

@implementation XMGLrcTool

+ (NSArray *)lrcToolWithLrcName:(NSString *)lrcName
{
    // 1.获取路径
    NSString *path = [[NSBundle mainBundle] pathForResource:lrcName ofType:nil];
    
    // 2.获取歌词
    NSString *lrcString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    // 3.转化成歌词数组
    NSArray *lrcArray = [lrcString componentsSeparatedByString:@"\n"];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *lrcLineString in lrcArray) {
     
        /*
         [ti:简单爱]
         [ar:周杰伦]
         [al:范特西]

         */
        // 4.过滤不需要的字符串
        if ([lrcLineString hasPrefix:@"[ti:"] ||
            [lrcLineString hasPrefix:@"[ar:"] ||
            [lrcLineString hasPrefix:@"[al:"] ||
            ![lrcLineString hasPrefix:@"["]) {
            continue;
        }
        
        // 5.将歌词转化成模型
        XMGLrcLine *lrcLine = [XMGLrcLine LrcLineString:lrcLineString];
        [tempArray addObject:lrcLine];
    }
    
    return tempArray;
}

@end
