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

@property (nonatomic, strong) NSMutableDictionary *downloads;

@end

@implementation ZWDataBaseTool

// 数据库操作语句

NSString *const sql_create_table = @"CREATE TABLE IF NOT EXISTS downloads (id INTEGER PRIMARY KEY AUTOINCREMENT, storage_name TEXT, name TEXT, ctime TEXT, creator TEXT, uid TEXT, size TEXT, identifier TEXT, school TEXT, course TEXT, lastAccessTime TEXT, extra TEXT)";
NSString *const sql_query_downloads = @"SELECT storage_name, identifier FROM downloads";
NSString *const sql_add_download_info = @"INSERT INTO downloads (storage_name, name, ctime, creator, uid, size, identifier, school, course, lastAccessTime) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')";

- (instancetype)init
{
    self = [super init];
    if (self) {
        //创建数据库
        _db = [FMDatabase databaseWithPath:[[ZWPathTool dbDirectory] stringByAppendingPathComponent:@"downloads.db"]];
        _downloads = [NSMutableDictionary dictionary];
        if ([_db open]) {
            BOOL res = [_db executeUpdate:sql_create_table];
            if (res) {
                FMResultSet *results = [_db executeQuery:sql_query_downloads];
                while ([results next]) {
                    NSString *name = [results stringForColumnIndex:0];
                    NSString *identifier = [results stringForColumnIndex:1];
                    [_downloads setObject:name forKey:identifier];
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

- (BOOL)isFileDownloaded:(NSString *)fileIdentifier {
    return [[self.downloads allKeys] containsObject:fileIdentifier];
}

- (BOOL)addFileDownloadInfo:(ZWFile *)file filenameInStorage:(NSString *)filenameInStorage inSchool:(NSString *)school inCourse:(NSString *)course {
    NSString *now = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    BOOL res = [_db executeUpdate:[NSString stringWithFormat:sql_add_download_info, filenameInStorage, file.name, file.ctime, file.creator, file.uid, file.size, file.md5, school, course, now]];
    if (res) {
        [self.downloads setObject:filenameInStorage forKey:file.md5];
    }
    return res;
}

- (NSString *)fileNameInStorageWithIdentifier:(NSString *)fileIdentifier {
    return [self.downloads objectForKey:fileIdentifier]; 
}

- (void)dealloc
{
    if ([_db open]) {
        [_db close];
    }
}

@end
