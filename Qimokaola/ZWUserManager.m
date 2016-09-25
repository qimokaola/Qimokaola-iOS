//
//  ZWUserManager.m
//  Qimokaola
//
//  Created by Administrator on 16/9/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUserManager.h"
#import "ZWAPITool.h"

@interface ZWUserManager ()

@property (nonatomic, strong) YYCache *cache;

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
        self.cache = [[YYCache alloc] initWithName:@"UserInfo"];
        self.loginUser = (ZWUser *)[_cache objectForKey:kLoginedUser];
        if (self.loginUser) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalUserLoginStateGuranteedNotification object:nil];
        }
    }
    return self;
}

- (void)setLoginUser:(ZWUser *)loginUser {
    _loginUser = loginUser;
    _isLogin = loginUser != nil;
    [[NSUserDefaults standardUserDefaults] setBool:_isLogin forKey:@"LoginState"];
    [_cache setObject:loginUser forKey:kLoginedUser];
}

- (void)modifyUserNickname:(NSString *)nickname result:(APIRequestResult)result {
    [self modifyUserInfo:@{@"nickname" : nickname} result:result];
}

- (void)updateNickname:(NSString *)nickname {
    if (nickname) {
        ZWUser *user = self.loginUser;
        user.nickname = nickname;
        self.loginUser = user;
    }
}

- (void)modifyUserGender:(NSString *)gender result:(APIRequestResult)result {
    [self modifyUserInfo:@{@"gender" : gender} result:result];
}

- (void)updateGender:(NSString *)gender {
    if (gender) {
        ZWUser *user = self.loginUser;
        user.gender = gender;
        self.loginUser = user;
    }
}

- (void)modifyUserAcademyId:(NSNumber *)academyId result:(APIRequestResult)result {
    [self modifyUserInfo:@{@"AcademyId" : academyId} result:result];
}

- (void)updateAcademyId:(NSNumber *)academyId academyName:(NSString *)academyName {
    if (academyId && academyName) {
        ZWUser *user = self.loginUser;
        user.academyId = academyId;
        user.academyName = academyName;
        self.loginUser = user;
    }
}

- (void)updateAvatarUrl:(NSString *)avatarUrl {
    if (avatarUrl) {
        ZWUser *user = self.loginUser;
        user.avatar_url = avatarUrl;
        self.loginUser = user;
    }
}

- (void)modifyUserInfo:(id)params result:(APIRequestResult)result {
    [ZWAPIRequestTool requestModifyUserInfoWithParameters:params result:result];
}

- (void)userLogout:(APIRequestResult)result {
    [ZWAPIRequestTool requestLogout:result];
}

@end
