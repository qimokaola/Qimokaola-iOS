//
//  ZWCountdownDatabaseManager.m
//  Qimokaola
//
//  Created by Administrator on 2017/2/23.
//  Copyright © 2017年 Administrator. All rights reserved.
//

#import "ZWCountdownDatabaseManager.h"

#import <FMDB/FMDB.h>

@interface ZWCountdownDatabaseManager ()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation ZWCountdownDatabaseManager

// 创建数据库
NSString *const sql_create_countdown_table = @"CREATE TABLE IF NOT EXISTS countdowns (id TEXT PRIMARY KEY, examName TEXT, examDate REAL, examLocation TEXT, alarmDate REAL, timeOfAhead TEXT)";

// 查询下载数据
NSString *const sql_query_all_countdown = @"SELECT * FROM countdowns ORDER BY alarmDate ASC";

// 添加下载数据
NSString *const sql_add_count = @"INSERT INTO countdowns (id, examName, examDate, examLocation, alarmDate, timeOfAhead) VALUES (?, ?, ?, ?, ?, ?)";

// 删除下载数据
NSString *const sql_delete_countdown = @"DELETE FROM countdowns WHERE id= '%@'";

//// 更新某个文件的最新打开时间
//NSString *const sql_update_last_access_time = @"UPDATE countdowns SET lastAccessTime = '%@' WHERE identifier = '%@'";


+ (instancetype)defaultManager {
    static ZWCountdownDatabaseManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZWCountdownDatabaseManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    if ([_db open]) {
        [_db close];
    }
}

@end
