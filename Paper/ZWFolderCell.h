//
//  ZWFolderCell.h
//  Paper
//
//  Created by Administrator on 16/4/6.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZWFolderCell : UITableViewCell

+ (instancetype)folderCellWithTableView:(UITableView *)tableView;

@property (nonatomic, copy) NSString *name;

@end
