//
//  ZWUser.h
//  Qimokaola
//
//  Created by Administrator on 16/9/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWUser : NSObject <NSCoding, NSCopying>

// 用户唯一标识
@property (nonatomic, strong) NSString *uid;
// 用户用户名 手机号 或者 管理员身份
@property (nonatomic, strong) NSString *username;
// 用户昵称
@property (nonatomic, strong) NSString *nickname;
// 用户性别
@property (nonatomic, strong) NSString *gender;
// 学校ID
@property (nonatomic, strong) NSNumber *collegeId;
// 学校名
@property (nonatomic, strong) NSString *collegeName;
// 学院ID
@property (nonatomic, strong) NSNumber *academyId;
// 学院名
@property (nonatomic, strong) NSString *academyName;
// 头像url
@property (nonatomic, strong) NSString *avatar_url;
// 是否是管理员身份
@property (nonatomic, assign) BOOL isAdmin;
// 入学年份
@property (nonatomic, strong) NSString *enterYear;

@end
