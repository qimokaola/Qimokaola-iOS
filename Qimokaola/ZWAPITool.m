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

@end

@implementation NSString (URLExtension)

- (NSString *)api {
    return [self stringByAppendingPathComponent:@"api"];
}

- (NSString *)user {
    return [self stringByAppendingPathComponent:@"user"];
}

- (NSString *)school {
    return [self stringByAppendingPathComponent:@"school"];
}

- (NSString *)sb {
    return [self stringByAppendingPathComponent:@"sb"];
}

- (NSString *)sendCode {
    return [self stringByAppendingPathComponent:@"sendCode"];
}

- (NSString *)verifyCode {
    return [self stringByAppendingPathComponent:@"verifyCode"];
}

- (NSString *)listSchool {
    return [self stringByAppendingPathComponent:@"list"];
}

- (NSString *)listAcademy {
    return [self stringByAppendingPathComponent:@"listAcademy"];
}

- (NSString *)register {
    return [self stringByAppendingPathComponent:@"register"];
}

- (NSString *)uploadAvatar {
    return [self stringByAppendingPathComponent:@"upload"];
}

- (NSString *)login {
    return [self stringByAppendingPathComponent:@"login"];
}

- (NSString *)userInfo {
    return [self stringByAppendingPathComponent:@"info"];
}

- (NSString *)dbfs {
    return [self stringByAppendingPathComponent:@"dbfs"];
}

- (NSString *)modifyUserInfo {
    return [self stringByAppendingPathComponent:@"modify"];
}

@end

@implementation ZWAPITool

+ (NSString *)base {
    return @"http://115.28.164.84";
}

+ (NSString *)sendCodeAPI {
    //return [[self base] stringByAppendingString:@"/api/user/sendcode"];
    return [[ZWAPITool user] sendCode];
}

+ (NSString *)verifyCodeAPI {
    //return [[self base] stringByAppendingString:@"/api/user/verifycode"];
    return [[ZWAPITool user] verifyCode];
}

+ (NSString *)listSchoolAPI {
    //return [[self base] stringByAppendingString:@"/api/school/list"];
    return [[ZWAPITool school] listSchool];
}

+ (NSString *)listAcademyAPI {
    //return [[self base] stringByAppendingString:@"/api/school/listAcademy"];
    return [[ZWAPITool school] listAcademy];
}

+ (NSString *)registerAPI {
    //return [[self base] stringByAppendingString:@"/api/user/register"];
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
    return [[[ZWAPITool dbfs] stringByAppendingPathComponent:@"%d"] stringByAppendingPathComponent:@"list"];
}

+ (NSString *)modifyUserInfoAPI {
    return [[ZWAPITool user] modifyUserInfo];
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

@end
