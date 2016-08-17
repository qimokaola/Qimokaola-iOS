//
//  ZWDownloadInfo.m
//  Paper
//
//  Created by Administrator on 15/10/12.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "ZWDownloadInfoModel.h"

static NSString *NAME = @"name";
static NSString *COURSE = @"course";
static NSString *LINK = @"link";
static NSString *TYPE = @"type";
static NSString *SIZE = @"size";
static NSString *TIME = @"time";

@implementation ZWDownloadInfoModel

- (instancetype)initWithFMReusultSet:(FMResultSet *)rs  {
    
    
    if (self = [super init]) {
        self.name = [rs stringForColumn:NAME];
        self.course = [rs stringForColumn:COURSE];
        self.link = [rs stringForColumn:LINK];
        self.type = [rs stringForColumn:TYPE];
        self.size = [rs stringForColumn:SIZE];
        self.time = [rs stringForColumn:TIME];
    }
    return self;
}

- (NSString *)filePath  {
    return [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Download"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", self.name, self.type]];
}

- (NSString *)file  {
    return [NSString stringWithFormat:@"%@.%@", self.name, self.type];
}

+ (instancetype)downloadInfoWithFMResultSet:(FMResultSet *)rs  {
    return [[self alloc] initWithFMReusultSet:rs];
}

@end
