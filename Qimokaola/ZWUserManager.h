//
//  ZWUserManager.h
//  Qimokaola
//
//  Created by Administrator on 16/9/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWUser.h"
#import "YYDiskCache.h"

@interface ZWUserManager : NSObject

// 当前登录的用户
@property (nonatomic, strong) ZWUser *loginUser;
// 登录状态
@property (nonatomic, assign) BOOL isLogin;

+ (instancetype)sharedInstance;

@end
