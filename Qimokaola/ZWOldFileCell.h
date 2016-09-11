//
//  ZWOldFileCell.h
//  Qimokaola
//
//  Created by Administrator on 16/4/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModels.h"

@interface ZWOldFileCell : UITableViewCell

@property (nonatomic, strong) ZWOldFile *file;
@property (nonatomic, assign) double progress;

+ (instancetype) fileCellWithTableView:(UITableView *)tableView;

@end
