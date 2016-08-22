//
//  ZWCourseDocCell.h
//  Qimokaola
//
//  Created by Administrator on 15/10/9.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWDocumentModel.h"

@interface ZWDocumentCell : UITableViewCell

@property (nonatomic, strong) ZWDocumentModel *model;

+ (instancetype) documentCellWithTableView:(UITableView *)tableView;

@end
