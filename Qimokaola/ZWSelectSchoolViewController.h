//
//  ZWSelectSchoolViewController.h
//  Qimokaola
//
//  Created by Administrator on 16/7/14.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectSchoolBlock)(NSString *school);

@interface ZWSelectSchoolViewController : UITableViewController

@property (nonatomic, copy) SelectSchoolBlock block;

@end
