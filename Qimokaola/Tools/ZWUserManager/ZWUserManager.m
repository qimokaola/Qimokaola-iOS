//
//  ZWUserManager.m
//  Qimokaola
//
//  Created by Administrator on 16/9/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUserManager.h"
#import "ZWPathTool.h"

#import "UMessage.h"
#import <YYKit/YYKit.h>
#import <UMCommunitySDK/UMComDataRequestManager.h>
#import <UMCommunitySDK/UMComSession.h>

#define kUserInfoFileName @"UserInfo.dat"

@interface ZWUserManager ()

@property (nonatomic, strong) YYCache *cache;


@end

NSString *const kLoginedUserKey = @"kLoginedUserKey";

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
        // 首先检查是否有持久化对象
        self.loginUser = (ZWUser *)[NSKeyedUnarchiver unarchiveObjectWithFile:[[ZWPathTool accountDirectory] stringByAppendingPathComponent:kUserInfoFileName]];
        // 为兼容旧版本 读取缓存中的数据
        if (!self.loginUser) {
            NSLog(@"读取旧版本内容");
            self.loginUser = (ZWUser *)[_cache objectForKey:kLoginedUserKey];
            if (self.loginUser) {
                NSLog(@"读取旧版本内容成功");
                // 移除旧版本对登录控制变量的依赖
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoginState"];
                [_cache removeObjectForKey:kLoginedUserKey];
                [self writeLoginUserData];
            }
        }
        if (self.loginUser) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalUserLoginStateGuranteedNotification object:nil];
        }
    }
    return self;
}

- (void)loginStudentCircle {
    if (!self.loginUser || [UMComSession sharedInstance].isLogin) {
        return;
    }
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] userCustomAccountLoginWithName:_loginUser.nickname
                                                                    sourceId:_loginUser.uid
                                                                    icon_url:[[[ZWAPITool base] stringByAppendingString:@"/"] stringByAppendingString:self.loginUser.avatar_url]
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
                                                                                  [weakSelf startFetchCommunityUnreadDataTimer];
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

- (void)startFetchCommunityUnreadDataTimer {
    __weak __typeof(self) weakSelf = self;
    // 进入时先获取一遍未读数据
    [self fetchCommunityUnreadData];
    [NSTimer scheduledTimerWithTimeInterval:kFetchUnreadInfoInterval block:^(NSTimer * _Nonnull timer) {
        [weakSelf fetchCommunityUnreadData];
    } repeats:YES];
}  

- (void)fetchCommunityUnreadData {
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] fetchConfigDataWithCompletion:^(NSDictionary *responseObject, NSError *error) {
        if (responseObject) {
            NSDictionary *msgBox = [responseObject objectForKey:@"msg_box"];
            weakSelf.unreadCommentCount = [[msgBox objectForKey:@"comment"] integerValue];
            weakSelf.unreadLikeCount = [[msgBox objectForKey:@"like"] integerValue];
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
    NSLog(@"set user to %@", loginUser);
    if (_loginUser) {
        NSNumber *currentCollegeId = _loginUser.currentCollegeId;
        NSString *currentCollegeName = _loginUser.currentCollegeName;
        _loginUser = loginUser;
        _loginUser.currentCollegeId = currentCollegeId;
        _loginUser.currentCollegeName = currentCollegeName;
    } else {
        _loginUser = loginUser;
        if (_loginUser) {
            if (!_loginUser.currentCollegeId) {
                _loginUser.currentCollegeId = _loginUser.collegeId;
            }
            if (!_loginUser.currentCollegeName) {
                _loginUser.currentCollegeName = _loginUser.collegeName;
            }
        }
    }
    if (_loginUser) {
        [UMessage addTag:_loginUser.collegeName response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
            
        }];
        [UMessage addTag:_loginUser.gender response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
            
        }];
    }
    _isLogin = loginUser != nil;
    [self writeLoginUserData];
}

- (void)writeLoginUserData {
    [NSKeyedArchiver archiveRootObject:self.loginUser toFile:[[ZWPathTool accountDirectory] stringByAppendingPathComponent:kUserInfoFileName]];
    if (!self.loginUser) {
        [[NSFileManager defaultManager] removeItemAtPath:[[ZWPathTool accountDirectory] stringByAppendingPathComponent:kUserInfoFileName] error:NULL];
    }
}

- (void)modifyUserNickname:(NSString *)nickname result:(APIRequestResult)result {
    [self modifyUserInfo:@{@"nickname" : nickname} result:result];
}

- (void)updateNickname:(NSString *)nickname {
    _loginUser.nickname = nickname;
    [self writeLoginUserData];
}

- (void)modifyUserGender:(NSString *)gender result:(APIRequestResult)result {
    [self modifyUserInfo:@{@"gender" : gender} result:result];
}

- (void)updateGender:(NSString *)gender {
    _loginUser.gender = gender;
    [self writeLoginUserData];
}

- (void)modifyUserAcademyId:(NSNumber *)academyId result:(APIRequestResult)result {
    [self modifyUserInfo:@{@"AcademyId" : academyId} result:result];
}

- (void)updateAcademyId:(NSNumber *)academyId academyName:(NSString *)academyName {
    _loginUser.academyId = academyId;
    _loginUser.academyName = academyName;
    [self writeLoginUserData];
}


- (void)updateCurrentCollegeId:(NSNumber *)collegeId collegeName:(NSString *)collegeName {
    _loginUser.currentCollegeId = collegeId;
    _loginUser.currentCollegeName = collegeName;
    [self writeLoginUserData];
}

- (void)modifyUserEnterYear:(NSString *)enterYear result:(APIRequestResult)result {
    [self modifyUserInfo:@{@"enterYear" : enterYear} result:result];
}

- (void)updateEnterYear:(NSString *)enterYear {
    _loginUser.enterYear = enterYear;
    [self writeLoginUserData];
}

- (void)updateAvatarUrl:(NSString *)avatarUrl {
    _loginUser.avatar_url = avatarUrl;
   [self writeLoginUserData];
}

- (void)modifyUserInfo:(id)params result:(APIRequestResult)result {
    [ZWAPIRequestTool requestModifyUserInfoWithParameters:params result:result];
}

- (void)userLogout:(APIRequestResult)result {
    [ZWAPIRequestTool requestLogout:result];
}

@end
