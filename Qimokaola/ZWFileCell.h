//
//  ZWFileCell.h
//  Qimokaola
//
//  Created by Administrator on 16/4/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModels.h"

@interface ZWFileCell : UITableViewCell

@property (nonatomic, strong) ZWFile *file;
@property (nonatomic, assign) double progress;

+ (instancetype) fileCellWithTableView:(UITableView *)tableView;

@end
