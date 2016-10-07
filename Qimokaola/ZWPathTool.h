//
//  ZWPathTool.h
//  Qimokaola
//
//  Created by Administrator on 16/8/23.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWPathTool : NSObject

//下载路径
+ (NSString *)downloadDirectory;

//保存下载的resumeData
+ (NSString *)resumeDataDirectory;

// 头像路径
+ (NSString *)avatarDirectory;

// 数据库路径
+ (NSString *)dbDirectory;

//广告路径
+ (NSString *)adImageDirectory;

//缓存文件路径
+ (NSString *)appCacheDirectory;

//应用沙盒路径
+ (NSString *)cacheDirectory;
+ (NSString *)documentDirectory;


@end
