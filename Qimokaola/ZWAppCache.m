//
//  ZWAppCache.m
//  Qimokaola
//
//  Created by Administrator on 16/4/8.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWAppCache.h"
#import "ZWUtilsCenter.h"

@implementation ZWAppCache

+ (ZWFileModel *)loadCachedFileModel {
    id result = [NSKeyedUnarchiver unarchiveObjectWithFile:[[ZWUtilsCenter appCacheDirectory] stringByAppendingPathComponent:@"FileModel.archive"]];
    return (ZWFileModel *)result;
}

+ (BOOL)saveCacheFileModel:(ZWFileModel *)model {
    return [NSKeyedArchiver archiveRootObject:model toFile:[[ZWUtilsCenter appCacheDirectory] stringByAppendingPathComponent:@"FileModel.archive"]];
}

@end
