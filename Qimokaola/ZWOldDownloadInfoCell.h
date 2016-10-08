//
//  ZWDownloadInfoCell.h
//  Qimokaola
//
//  Created by Administrator on 15/10/12.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWDownloadInfoModel.h"

@interface ZWOldDownloadInfoCell : UITableViewCell

@property (nonatomic, strong) ZWDownloadInfoModel *downloadInfo;

+ (instancetype)downloadInfoCellWithTablelView:(UITableView *)tableView;

@end
