//
//  ZWPopViewController.h
//  Qimokaola
//
//  Created by Administrator on 16/7/19.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZWPopViewController : UITableViewController

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *imageNameArray;
@property (nonatomic, copy) void(^popViewSelectedBlock)(NSInteger index);

@end
