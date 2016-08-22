//
//  ZWPopViewController.h
//  Paper
//
//  Created by Administrator on 16/7/19.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SwitchCompleteBlock)(NSString *school);

@interface ZWPopViewController : UITableViewController

@property (nonatomic, copy) SwitchCompleteBlock block;

@end
