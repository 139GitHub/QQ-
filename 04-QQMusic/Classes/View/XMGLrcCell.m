//
//  XMGLrcCell.m
//  04-QQMusic
//
//  Created by xiaomage on 15/12/18.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "XMGLrcCell.h"
#import "XMGLrcLabel.h"
#import "Masonry.h"

@implementation XMGLrcCell


+ (instancetype)lrcCellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    XMGLrcCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[XMGLrcCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // 1.初始化XMGLrcLabel
        XMGLrcLabel *lrcLabel = [[XMGLrcLabel alloc] init];
        [self.contentView addSubview:lrcLabel];
        self.lrcLabel = lrcLabel;
        
        // 2.添加约束
        [lrcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
        }];
        
        // 3.设置基本数据
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        lrcLabel.textColor = [UIColor whiteColor];
        lrcLabel.textAlignment = NSTextAlignmentCenter;
        lrcLabel.font = [UIFont systemFontOfSize:14];
        
    }
    return self;
}

@end
