//
//  ZWAPIRequestTool.h
//  Qimokaola
//
//  Created by Administrator on 16/8/28.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWAPITool.h"
#import "ZWNetworkingManager.h"

typedef void(^APIRequestResult)(id response, BOOL success);

@interface ZWAPIRequestTool : NSObject

// 请求验证码
+ (void)requestSendCodeWithParameter:(id)param result:(APIRequestResult)result;
// 验证验证码
+ (void)requestVerifyCodeWithParameter:(id)param result:(APIRequestResult)result;
// 获得学校列表
+ (void)requestListSchool:(APIRequestResult)result;
// 获得学院列表
+ (void)requestListAcademyWithParameter:(id)param result:(APIRequestResult)result;
// 放到具体控制器实现
//// 注册
//+ (void)requestRegisterWithParameter:(id)params result:(APIRequestResult)result;
// 登录
+ (void)requestLoginWithParameters:(id)params result:(APIRequestResult)result;
// 上传头像
+ (void)requestUploadAvatarWithParamsters:(id)params constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block result:(APIRequestResult)result;
// 用户信息
+ (void)requestUserInfo:(APIRequestResult)result;
// 请求文件夹与文件
+ (void)requstFileAndFolderListInSchool:(NSNumber *)collegeId path:(NSString *)path needDetail:(BOOL)needDetail result:(APIRequestResult)result;
// 修改用户信息
+ (void)requestModifyUserInfoWithParameters:(id)params result:(APIRequestResult)result;

+ (void)requestLogout:(APIRequestResult)result;

+ (void)requestDownloadUrlInSchool:(NSNumber *)collegeId path:(NSString *)path result:(APIRequestResult)result;

+ (void)reuqestInfoByName:(NSString *)username result:(APIRequestResult)result;

+ (void)requestSBInfo:(APIRequestResult)result;

+ (void)requestAppInfo:(APIRequestResult)result;

@end
