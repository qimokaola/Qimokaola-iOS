//
//  ZWDataBaseTool.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/20.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWDataBaseTool.h"
#import "ZWPathTool.h"
#import <FMDB/FMDB.h>

@interface ZWDataBaseTool ()

@property (nonatomic, strong) FMDatabase *db;

@property (nonatomic, strong) NSMutableArray *downloads;

@end

@implementation ZWDataBaseTool

// 数据库操作语句

NSString *const sql_create_table = @"CREATE TABLE IF NOT EXISTS downloads (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, school TEXT, course TEXT, size TEXT, lastAccessTime TEXT)";
NSString *const sql_query_downloads = @"SELECT name FROM downloads";

- (instancetype)init
{
    self = [super init];
    if (self) {
        //创建数据库
        _db = [FMDatabase databaseWithPath:[[ZWPathTool dbDirectory] stringByAppendingPathComponent:@"downloads.db"]];
        _downloads = [NSMutableArray array];
        if ([_db open]) {
            BOOL res = [_db executeUpdate:sql_create_table];
            if (res) {
                FMResultSet *results = [_db executeQuery:sql_query_downloads];
                while ([results next]) {
                    [_downloads addObject:[results stringForColumnIndex:0]];
                }
            }
        }
    }
    return self;
}

+ (instancetype)sharedInstance {
    static ZWDataBaseTool *databaseTool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseTool = [[ZWDataBaseTool alloc] init];
    });
    return databaseTool;
}

+ (void)saveDownloadFileInfo:(ZWFile *)file {
    
}

+ (BOOL)isFileDownloaded:(ZWFile *)file {
    return [[ZWDataBaseTool sharedInstance].downloads containsObject:file.name];
}

- (void)dealloc
{
    if ([_db open]) {
        [_db close];
    }
}

@end
