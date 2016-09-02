//
//  ZWAPIRequestTool.m
//  Qimokaola
//
//  Created by Administrator on 16/8/28.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWAPIRequestTool.h"


@implementation ZWAPIRequestTool

+ (void)requestSendCodeWithParameter:(id)param result:(APIRequestResult)result {
    
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool sendCodeAPI]
                          parameters:param
                              result:result];
    
}

+ (void)requestVerifyCodeWithParameter:(id)param result:(APIRequestResult)result {
    
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool verifyCodeAPI]
                          parameters:param
                              result:result];
    
}

+ (void)requestListSchool:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool listSchoolAPI]
                          parameters:nil
                              result:result];
}

+ (void)requestListAcademyWithParameter:(id)param result:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool listAcademyAPI]
                          parameters:param
                              result:result];
}

+ (void)requestRegisterWithParameter:(id)params result:(APIRequestResult)result {
//    [ZWAPIRequestTool requestWithAPI:[ZWAPITool registerAPI]
//                          parameters:params
//                              result:result];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:[ZWAPITool registerAPI]
       parameters:[self buildParameters:params]
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              
              if (result) {
                  result(responseObject, YES);
              }
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              
              if (result) {
                  result(error, NO);
              }
              
          }];
}

+ (void)requestUploadAvatarWithParamsters:(id)params
                constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
                                   result:(APIRequestResult)result {
    
    
    [ZWNetworkingManager postWithURLString:[ZWAPITool uploadAvatarAPI]
                                    params:[ZWAPIRequestTool buildParameters:params ? params : @{}]
                 constructingBodyWithBlock:block
                                  progress:nil
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                      
                                       if (result) {
                                           result(responseObject, YES);
                                       }
                                       
                                   }
                                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       
                                       if (result) {
                                           result(error, NO);
                                       }
                                   }];
}

// 通用请求接口，针对接收字典参数的接口
+ (void)requestWithAPI:(NSString *)API parameters:(id)params result:(APIRequestResult)result {
    
    id parameters = [ZWAPIRequestTool buildParameters:params ? params : @{}];
    
    [ZWNetworkingManager postWithURLString:API
                                    params:parameters
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       
                                       
                                       if (result) {
                                           result(responseObject, YES);
                                       }
                                       
                                   }
                                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       
                                       if (result) {
                                           result(error, NO);
                                       }
                                       
                                   }];
    
}

// 特殊请求接口，针对接收JSON字符串的接口 部分接口需要 "application/json" 的 Content-Type 
+ (void)requestWithJSONContentType:(id)params result:(APIRequestResult)result {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:[ZWAPITool registerAPI]
       parameters:[self buildParameters:params]
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              
              if (result) {
                  result(responseObject, YES);
              }
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              
              if (result) {
                  result(error, NO);
              }
              
          }];
}

+ (id)buildParameters:(id)param {
    
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:@"version" forKey:@1];
        [dict addEntriesFromDictionary:param];
        return dict;
    } else if ([param isKindOfClass:[NSString class]]) {
        NSMutableString *validParams = [param mutableCopy];
        [validParams insertString:@"\n  \"version\":1" atIndex:1];
        return validParams;
    }
    return nil;
}



@end
