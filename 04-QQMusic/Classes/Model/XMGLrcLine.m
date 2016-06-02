//
//  XMGLrcLine.m
//  04-QQMusic
//
//  Created by xiaomage on 15/12/18.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGLrcLine.h"

@implementation XMGLrcLine

- (instancetype)initWithLrcLineString:(NSString *)lrcLineString
{
    if (self = [super init]) {
        // [01:02.38]想你时你在天边
        NSArray *lrcArray = [lrcLineString componentsSeparatedByString:@"]"];
        self.text = lrcArray[1];
        self.time = [self timeWithString:[lrcArray[0] substringFromIndex:1]];
    }
    return self;

}

+ (instancetype)LrcLineString:(NSString *)lrcLineString
{
    return [[self alloc] initWithLrcLineString:lrcLineString];
}

- (NSTimeInterval)timeWithString:(NSString *)timeString
{
    // 01:02.38
    NSInteger min = [[timeString componentsSeparatedByString:@":"][0] integerValue];
    NSInteger sec = [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue];
    NSInteger hs = [[timeString componentsSeparatedByString:@"."][1] integerValue];
    return min * 60 + sec + hs * 0.01;
}

@end
