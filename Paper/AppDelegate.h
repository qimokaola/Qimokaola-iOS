//
//  AppDelegate.h
//  Paper
//
//  Created by Administrator on 15/10/8.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "FMDB.h"
#import "ZWNetworkingManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//下载文档数据库处理队列
@property (nonatomic, strong) FMDatabaseQueue *DBQueue;

@end

