//
//  ZWUser.m
//  Qimokaola
//
//  Created by Administrator on 16/9/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUser.h"

/*
 
 // 用户唯一标识
 @property (nonatomic, strong) NSString *uid;
 // 用户用户名 手机号 或者 管理员身份
 @property (nonatomic, strong) NSString *username;
 // 用户昵称
 @property (nonatomic, strong) NSString *nickname;
 // 用户性别
 @property (nonatomic, strong) NSString *gender;
 // 学校ID
 @property (nonatomic, strong) NSString *collegeId;
 // 学院ID
 @property (nonatomic, strong) NSString *acadenyId;
 // 头像url
 @property (nonatomic, strong) NSString *avatar_url;
 // 是否是管理员身份
 @property (nonatomic, assign) BOOL isAdmin;
 
 */

NSString *const ZWUserUid = @"uid";
NSString *const ZWUserName = @"username";
NSString *const ZWUserNickname = @"nickname";
NSString *const ZWUserGender = @"gender";
NSString *const ZWUserCollegeId = @"collegeId";
NSString *const ZWUserAcademyId = @"academyId";
NSString *const ZWUserAvatarUrl = @"avatar_url";
NSString *const ZWUserIsAdmin = @"isAdmin";

@implementation ZWUser

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.uid = [coder decodeObjectForKey:ZWUserUid];
        self.username = [coder decodeObjectForKey:ZWUserName];
        self.nickname = [coder decodeObjectForKey:ZWUserNickname];
        self.gender = [coder decodeObjectForKey:ZWUserGender];
        self.collegeId = [coder decodeObjectForKey:ZWUserCollegeId];
        self.acadenyId = [coder decodeObjectForKey:ZWUserAcademyId];
        self.avatar_url = [coder decodeObjectForKey:ZWUserAvatarUrl];
        self.isAdmin = [coder decodeBoolForKey:ZWUserIsAdmin];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_uid forKey:ZWUserUid];
    [aCoder encodeObject:_username forKey:ZWUserName];
    [aCoder encodeObject:_nickname forKey:ZWUserNickname];
    [aCoder encodeObject:_gender forKey:ZWUserGender];
    [aCoder encodeObject:_collegeId forKey:ZWUserCollegeId];
    [aCoder encodeObject:_acadenyId forKey:ZWUserAcademyId];
    [aCoder encodeObject:_avatar_url forKey:ZWUserAvatarUrl];
    [aCoder encodeBool:_isAdmin forKey:ZWUserIsAdmin];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"uid" : @"id",
             @"academyId" : @"AcademyId",
             @"collegeId" : @"CollegeId",
             @"avatar_url" : @"avatar"};
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@-%@-%@-%@", _uid, _username, _nickname, _gender];
}


@end
