//
//  ZWAPITool.m
//  Qimokaola
//
//  Created by Administrator on 16/8/23.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWAPITool.h"

@interface NSString (URLExtension)

// 几个接口路径
- (NSString *)api;
- (NSString *)user;
- (NSString *)school;
- (NSString *)sb;
- (NSString *)dbfs;

// 详细接口
- (NSString *)sendCode;
- (NSString *)verifyCode;
- (NSString *)listSchool;
- (NSString *)listAcademy;
- (NSString *)register;
- (NSString *)uploadAvatar;
- (NSString *)login;
- (NSString *)userInfo;
- (NSString *)modifyUserInfo;
- (NSString *)logout;
- (NSString *)infobyname;

@end

@implementation NSString (URLExtension)

- (NSString *)api {
    return [self stringByAppendingString:@"/api"];
}

- (NSString *)user {
    return [self stringByAppendingString:@"/user"];
}

- (NSString *)school {
    return [self stringByAppendingString:@"/school"];
}

- (NSString *)sb {
    return [self stringByAppendingString:@"/sb"];
}

- (NSString *)sendCode {
    return [self stringByAppendingString:@"/sendCode"];
}

- (NSString *)verifyCode {
    return [self stringByAppendingString:@"/verifyCode"];
}

- (NSString *)listSchool {
    return [self stringByAppendingString:@"/list"];
}

- (NSString *)listAcademy {
    return [self stringByAppendingString:@"/listAcademy"];
}

- (NSString *)register {
    return [self stringByAppendingString:@"/register"];
}

- (NSString *)uploadAvatar {
    return [self stringByAppendingString:@"/upload"];
}

- (NSString *)login {
    return [self stringByAppendingString:@"/login"];
}

- (NSString *)userInfo {
    return [self stringByAppendingString:@"/info"];
}

- (NSString *)dbfs {
    return [self stringByAppendingString:@"/dbfs"];
}

- (NSString *)modifyUserInfo {
    return [self stringByAppendingString:@"/modify"];
}

- (NSString *)logout {
    return [self stringByAppendingString:@"/logout"];
}

- (NSString *)infobyname {
    return [self stringByAppendingString:@"/infobyname"];
}

@end

@implementation ZWAPITool

+ (NSString *)base {
    return @"https://finalexam.cn";
}

+ (NSString *)sendCodeAPI {
    return [[ZWAPITool user] sendCode];
}

+ (NSString *)verifyCodeAPI {
    return [[ZWAPITool user] verifyCode];
}

+ (NSString *)listSchoolAPI {
    return [[ZWAPITool school] listSchool];
}

+ (NSString *)listAcademyAPI {
    return [[ZWAPITool school] listAcademy];
}

+ (NSString *)registerAPI {
    return [[ZWAPITool user] register];
}

+ (NSString *)loginAPI {
    return [[ZWAPITool user] login];
}

+ (NSString *)uploadAvatarAPI {
    return [[ZWAPITool user] uploadAvatar];
}

+ (NSString *)userInfoAPI {
    return [[ZWAPITool user] userInfo];
}

+ (NSString *)listFileAndFolderAPI {
    return [[ZWAPITool dbfsInUnknowSchool] stringByAppendingString:@"/list"];
}

+ (NSString *)modifyUserInfoAPI {
    return [[ZWAPITool user] modifyUserInfo];
}

+ (NSString *)logoutAPI {
    return [[ZWAPITool user] logout];
}

+ (NSString *)downloadUrlAPI {
    return [[ZWAPITool dbfsInUnknowSchool] stringByAppendingString:@"/downloadurl"];;
}

+ (NSString *)infoByNameAPI {
    return [[ZWAPITool user] infobyname];
}

+ (NSString *)shareFileAPI {
    return [[ZWAPITool dbfs] stringByAppendingString:@"/md5/%@/%@"];
}

+ (NSString *)api {
    return [[ZWAPITool base] api];
}

+ (NSString *)user {
    return [[ZWAPITool api] user];
}

+ (NSString *)school {
    return [[ZWAPITool api] school];
}

+ (NSString *)dbfs {
    return [[ZWAPITool api] dbfs];
}

+ (NSString *)dbfsInUnknowSchool {
    return [[ZWAPITool dbfs] stringByAppendingString:@"/%d"];
}

@end
