//
//  ZWUserManager.m
//  Qimokaola
//
//  Created by Administrator on 16/9/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUserManager.h"
#import "ZWAPITool.h"

#import <UMCommunitySDK/UMComDataRequestManager.h>
#import <UMCommunitySDK/UMComSession.h>

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

- (void)loginStudentCircle {
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] userCustomAccountLoginWithName:_loginUser.nickname
                                                                    sourceId:_loginUser.uid
                                                                    icon_url:[[ZWAPITool base] stringByAppendingPathComponent:_loginUser.avatar_url]
                                                                      gender:[_loginUser.gender isEqualToString:@"男"] ? 1 : 0
                                                                         age:0
                                                                      custom:_loginUser.collegeName
                                                                       score:0
                                                                  levelTitle:nil
                                                                       level:0
                                                           contextDictionary:nil
                                                                userNameType:userNameNoRestrict
                                                              userNameLength:userNameLengthNoRestrict
                                                                  completion:^(NSDictionary *responseObject, NSError *error) {
                                                                      if (error) {
                                                                          NSLog(@"登录发生错误 ;%@", error);
                                                                      } else {
                                                                          if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                                              UMComUser *user = responseObject[UMComModelDataKey];
                                                                              if (user) {
                                                                                  NSLog(@"登录学生圈成功，登录用户: %@, 自定义字段: %@", user.name, user.custom);
                                                                                  [UMComSession sharedInstance].loginUser = user;
                                                                                  [[UMComDataBaseManager shareManager] saveRelatedIDTableWithType:UMComRelatedRegisterUserID withUsers:@[user]];
                                                                                  // 若自定义字段为null，则更新用户信息确保自定义字段存在
                                                                                  if (!user.custom) {
                                                                                      [[UMComDataRequestManager defaultManager]
                                                                                       updateProfileWithName:user.name
                                                                                       age:user.age
                                                                                       gender:user.gender
                                                                                       custom:weakSelf.loginUser.collegeName
                                                                                       userNameType:userNameNoRestrict
                                                                                       userNameLength:userNameLengthNoRestrict
                                                                                       completion:^(NSDictionary *responseObject, NSError *error) {
                                                                                           // 由于友盟SDK bug原因 此处修改信息必定错误 但修改生效 故不考虑结果
                                                                                       }];
                                                                                  }
                                                                                  //[UMComSession sharedInstance].token = responseObject[UMComTokenKey];
                                                                                  
                                                                                  //                                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginSucceedNotification object:nil];
                                                                              }
                                                                          }
                                                                      }
                                                                  }];

}

- (void)logoutStudentCircle {
    // 如果学生圈已经登录 则登出
    if ([UMComSession sharedInstance].isLogin) {
        [[UMComSession sharedInstance] userLogout];
    }
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
