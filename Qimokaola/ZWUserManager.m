//
//  ZWUserManager.m
//  Qimokaola
//
//  Created by Administrator on 16/9/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUserManager.h"

@interface ZWUserManager ()

@property (nonatomic, strong) YYDiskCache *diskCache;

@end

NSString *const kLoginedUser = @"kLoginedUser";

@implementation ZWUserManager

+ (instancetype)sharedInstance {
    static ZWUserManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZWUserManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _diskCache = [[YYDiskCache alloc] initWithPath:@"User"];
        _loginUser = (ZWUser *)[_diskCache objectForKey:kLoginedUser];
    }
    return self;
}

- (void)setLoginUser:(ZWUser *)loginUser {
    _loginUser = loginUser;
    _isLogin = loginUser != nil;
    
    NSLog(@"set object");
    
    [_diskCache setObject:loginUser forKey:kLoginedUser];
}

@end
