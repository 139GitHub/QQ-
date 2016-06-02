//
//  XMGLrcLabel.m
//  04-QQMusic
//
//  Created by xiaomage on 15/12/19.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGLrcLabel.h"

@implementation XMGLrcLabel

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGRect fillRect = CGRectMake(0, 0, self.bounds.size.width * self.progress, self.bounds.size.height);
    [[UIColor greenColor] set];
//    UIRectFill(fillRect);
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
}

@end
