//
//  ZWUserManager.m
//  Qimokaola
//
//  Created by Administrator on 16/9/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUserManager.h"

@implementation ZWUserManager

+ (instancetype)sharedInstance {
    static ZWUserManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZWUserManager alloc] init];
    });
    return manager;
}

- (void)setLoginUser:(ZWUser *)loginUser {
    _loginUser = loginUser;
    _uid = loginUser.uid;
}

@end
