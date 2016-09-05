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
// 注册
+ (void)requestRegisterWithParameter:(id)params result:(APIRequestResult)result;
// 登录
+ (void)requestLoginWithParameters:(id)params result:(APIRequestResult)result;
// 上传头像
+ (void)requestUploadAvatarWithParamsters:(id)params constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block result:(APIRequestResult)result;

@end
