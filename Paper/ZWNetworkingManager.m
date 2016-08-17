//
//  ZWNetworkingManager.m
//  Paper
//
//  Created by Administrator on 16/7/26.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWNetworkingManager.h"

@interface ZWNetworkingManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

static ZWNetworkingManager *_manager = nil;

@implementation ZWNetworkingManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sessionManager = [AFHTTPSessionManager manager];
    }
    return self;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[ZWNetworkingManager alloc] init];
    });
    return _manager;
}

+ (NSURLSessionDataTask *)getWithURLString:(NSString *)url
                                    params:(NSDictionary *)params
                                  progress:(ProgressBlock)progress
                                   success:(SuccessBlock)success
                                   failure:(FailureBlock)failure {
    
    return [[ZWNetworkingManager sharedManager].sessionManager GET:url
                                                        parameters:params
                                                          progress:progress
                                                           success:success
                                                           failure:failure];
}

+ (NSURLSessionDataTask *)getWithURLString:(NSString *)url
                                   success:(SuccessBlock)success
                                   failure:(FailureBlock)failure {
    
    return [ZWNetworkingManager getWithURLString:url
                                          params:nil
                                        progress:nil success:success
                                         failure:failure];
    
}

+ (NSURLSessionDataTask *)getWithURLString:(NSString *)url
                                    params:(NSDictionary *)params
                                   success:(SuccessBlock)success
                                   failure:(FailureBlock)failure {
    
    return [ZWNetworkingManager getWithURLString:url
                                          params:params
                                        progress:nil
                                         success:success
                                         failure:failure];
}

+ (NSURLSessionDataTask *)postWithURLString:(NSString *)url
                                     params:(NSDictionary *)params
                                   progress:(ProgressBlock)preogress
                                    success:(SuccessBlock)success
                                    failure:(FailureBlock)failure {
    
    return [[ZWNetworkingManager sharedManager].sessionManager POST:url
                                                         parameters:params
                                                           progress:preogress
                                                            success:success
                                                            failure:failure];
}

+ (NSURLSessionDataTask *)postWithURLString:(NSString *)url
                                     params:(NSDictionary *)params
                                    success:(SuccessBlock)success
                                    failure:(FailureBlock)failure {
    
    return [ZWNetworkingManager postWithURLString:url
                                           params:params
                                         progress:nil
                                          success:success
                                          failure:failure];
}

@end
