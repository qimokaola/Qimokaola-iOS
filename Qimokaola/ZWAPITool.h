//
//  ZWAPITool.h
//  Qimokaola
//
//  Created by Administrator on 16/8/23.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWAPITool : NSObject

+ (NSString *)base;

+ (NSString *)sendCodeAPI;

+ (NSString *)verifyCodeAPI;

+ (NSString *)listSchoolAPI;

+ (NSString *)listAcademyAPI;

+ (NSString *)registerAPI;

+ (NSString *)loginAPI;

+ (NSString *)uploadAvatarAPI;

+ (NSString *)userInfoAPI;

+ (NSString *)listFileAndFolderAPI;

+ (NSString *)modifyUserInfoAPI;

+ (NSString *)logoutAPI;

+ (NSString *)downloadUrlAPI;

+ (NSString *)infoByNameAPI;

@end
