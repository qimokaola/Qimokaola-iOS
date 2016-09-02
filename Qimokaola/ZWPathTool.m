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
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return directory;
}

+ (NSString *)resumeDataDirectory {
    NSString *resumeDataDirectory = [[self documentDirectory] stringByAppendingPathComponent:@"ResumeData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:resumeDataDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resumeDataDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return resumeDataDirectory;
}

+ (NSString *)adImageDirectory {
    NSString *adImageDirectory = [[self documentDirectory] stringByAppendingPathComponent:@"AdImage"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:adImageDirectory])  {
        [[NSFileManager defaultManager] createDirectoryAtPath:adImageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return adImageDirectory;
}

+ (NSString *)appCacheDirectory {
    NSString *cachaDirectory = [[self cacheDirectory] stringByAppendingPathComponent:@"AppCache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachaDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachaDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return cachaDirectory;
}

+ (NSString *)cacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

+ (NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

@end
