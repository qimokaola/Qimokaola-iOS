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

+ (void)requestSendCodeWithParameter:(id)param result:(APIRequestResult)result;

+ (void)requestVerifyCodeWithParameter:(id)param result:(APIRequestResult)result;

+ (void)requestListSchool:(APIRequestResult)result;

+ (void)requestListAcademyWithParameter:(id)param result:(APIRequestResult)result;

+ (void)requestRegisterWithParameter:(id)params result:(APIRequestResult)result;

+ (void)requestUploadAvatarWithParamsters:(id)params constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block result:(APIRequestResult)result;

@end
