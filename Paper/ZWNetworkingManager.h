//
//  ZWNetworkingManager.h
//  Paper
//
//  Created by Administrator on 16/7/26.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^ProgressBlock)(NSProgress *progress);
typedef void(^SuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void(^FailureBlock)(NSURLSessionDataTask *task, NSError *error);

@interface ZWNetworkingManager : NSObject

+ (NSURLSessionDataTask *)getWithURLString:(NSString *)url
                                   success:(SuccessBlock)success
                                   failure:(FailureBlock)failure;

+ (NSURLSessionDataTask *)getWithURLString:(NSString *)url
                                    params:(NSDictionary *)params
                                   success:(SuccessBlock)success
                                   failure:(FailureBlock)failure;

+ (NSURLSessionDataTask *)getWithURLString:(NSString *)url
                                    params:(NSDictionary *)params
                                  progress:(ProgressBlock)progress
                                   success:(SuccessBlock)success
                                   failure:(FailureBlock)failure;

+ (NSURLSessionDataTask *)postWithURLString:(NSString *)url
                                     params:(NSDictionary *)params
                                    success:(SuccessBlock)success
                                    failure:(FailureBlock)failure;

+ (NSURLSessionDataTask *)postWithURLString:(NSString *)url
                                     params:(NSDictionary *)params
                                   progress:(ProgressBlock)preogress
                                    success:(SuccessBlock)success
                                    failure:(FailureBlock)failure;


@end
