//
//  ZWUtilsCenter.h
//  Qimokaola
//
//  Created by Administrator on 16/4/6.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface ZWUtilsCenter : NSObject

+ (NSString *)typeWithName:(NSString *)name;
+ (NSString *)sizeWithDouble:(double)size;

+ (NSString *)parseTypeWithString:(NSString *)type;

//下载路径
+ (NSString *)downloadDirectory;

//保存下载的resumeData
+ (NSString *)resumeDataDirectory;

//广告路径
+ (NSString *)adImageDirectory;

//缓存文件路径
+ (NSString *)appCacheDirectory;

//应用沙盒路径
+ (NSString *)cacheDirectory;
+ (NSString *)documentDirectory;

+ (BOOL)checkNetWorkStateAvailable;

+ (void)showHUDWithTitle:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration;

+ (void)showHUDInView:(UIView *)view withTitle:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration;


@end
