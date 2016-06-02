//
//  XMGLrcLine.h
//  04-QQMusic
//
//  Created by xiaomage on 15/12/18.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMGLrcLine : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSTimeInterval time;

- (instancetype)initWithLrcLineString:(NSString *)lrcLineString;
+ (instancetype)LrcLineString:(NSString *)lrcLineString;
@end
