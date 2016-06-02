//
//  XMGLrcCell.h
//  04-QQMusic
//
//  Created by xiaomage on 15/12/18.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMGLrcLabel;
@interface XMGLrcCell : UITableViewCell

+ (instancetype)lrcCellWithTableView:(UITableView *)tableView;

/** lrcLabel */
@property (nonatomic, weak) XMGLrcLabel *lrcLabel;

@end
