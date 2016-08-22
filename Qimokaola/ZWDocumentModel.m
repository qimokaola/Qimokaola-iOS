//
//  ZWCourseDoc.m
//  Qimokaola
//
//  Created by Administrator on 15/10/15.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "ZWDocumentModel.h"

@implementation ZWDocumentModel

- (instancetype)initWithDict:(NSDictionary *)dict andDatabase:(FMDatabase *)db  {
    if(self = [super init])  {
        [self setValuesForKeysWithDictionary:dict];
        if([db open])  {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM download_info WHERE name = '%@'", self.papername];
            FMResultSet *rs = [db executeQuery:sql];
            self.download = [rs next];
            [rs close];
        }  else  {
            self.download = NO;
        }
    }
    return self;
}

+ (instancetype)documentModelWithDict:(NSDictionary *)dict andDatabase:(FMDatabase *)db  {
    return [[self alloc] initWithDict:dict andDatabase:db];
}

@end
