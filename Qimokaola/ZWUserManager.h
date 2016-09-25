//
//  ZWUserManager.h
//  Qimokaola
//
//  Created by Administrator on 16/9/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWUser.h"
#import "ZWAPIRequestTool.h"

#import <YYKit/YYKit.h>

@interface ZWUserManager : NSObject

// 当前登录的用户
@property (nonatomic, strong) ZWUser *loginUser;
// 登录状态
@property (nonatomic, assign) BOOL isLogin;

+ (instancetype)sharedInstance;

// 修改昵称
- (void)modifyUserNickname:(NSString *)nickname result:(APIRequestResult)result;
- (void)updateNickname:(NSString *)nickname;

// 修改性别
- (void)modifyUserGender:(NSString *)gender result:(APIRequestResult)result;
- (void)updateGender:(NSString *)gender;

- (void)modifyUserAcademyId:(NSNumber *)academyId result:(APIRequestResult)result;
- (void)updateAcademyId:(NSNumber *)academyId academyName:(NSString *)academyName;

- (void)updateAvatarUrl:(NSString *)avatarUrl;

- (void)userLogout:(APIRequestResult)result;

@end
