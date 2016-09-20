//
//  ZWDownloadManager.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/20.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWDownloadManager.h"

#import <AFNetworking/AFNetworking.h>

@interface ZWDownloadManager ()

@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation ZWDownloadManager

+ (instancetype)sharedManager {
    static ZWDownloadManager *downloadManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [[ZWDownloadManager alloc] init];
    });
    return downloadManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return self;
}

@end
