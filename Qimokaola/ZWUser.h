//
//  ZWUser.h
//  Qimokaola
//
//  Created by Administrator on 16/9/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWUser : NSObject

// 用户唯一标识
@property (nonatomic, strong) NSString *uid;
// 用户手机号
@property (nonatomic, strong) NSString *phone;
// 用户昵称
@property (nonatomic, strong) NSString *name;
// 用户性别
@property (nonatomic, strong) NSString *gender;
// 学校ID
@property (nonatomic, strong) NSString *schollID;
// 学院ID
@property (nonatomic, strong) NSString *acadenyID;
// 教务处用户名
@property (nonatomic, strong) NSString *schoolUn;
// 教务处密码
@property (nonatomic, strong) NSString *schoolPw;
// 头像url
@property (nonatomic, strong) NSString *icon_url;
// 入学年份
@property (nonatomic, strong) NSString *enterYear;

@end
