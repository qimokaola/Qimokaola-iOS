//
//  ZWPathTool.m
//  Qimokaola
//
//  Created by Administrator on 16/8/23.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWPathTool.h"

@implementation ZWPathTool

+ (NSString *)downloadDirectory {
    NSString *directory = [[self documentDirectory] stringByAppendingPathComponent:@"Download"];
    return [self checkDirExistence:directory];
}

+ (NSString *)avatarDirectory {
    NSString *avatarDir = [[self cacheDirectory] stringByAppendingPathComponent:@"avatar"];
    return [self checkDirExistence:avatarDir];
}

+ (NSString *)resumeDataDirectory {
    NSString *resumeDataDirectory = [[self documentDirectory] stringByAppendingPathComponent:@"ResumeData"];
    return [self checkDirExistence:resumeDataDirectory];
}

+ (NSString *)dbDirectory {
    NSString *dbDirectory = [[self documentDirectory] stringByAppendingPathComponent:@"Database"];
    return [self checkDirExistence:dbDirectory];
}

+ (NSString *)adImageDirectory {
    NSString *adImageDirectory = [[self documentDirectory] stringByAppendingPathComponent:@"AdImage"];
    return [self checkDirExistence:adImageDirectory];
}

+ (NSString *)appCacheDirectory {
    NSString *cachaDirectory = [[self cacheDirectory] stringByAppendingPathComponent:@"AppCache"];
    return [self checkDirExistence:cachaDirectory];
}

+ (NSString *)cacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

+ (NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

+ (NSString *)checkDirExistence:(NSString *)dir {
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return dir;
}

@end
