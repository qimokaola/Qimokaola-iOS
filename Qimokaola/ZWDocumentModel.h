//
//  ZWCourseDoc.h
//  Qimokaola
//
//  Created by Administrator on 15/10/15.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"


@interface ZWDocumentModel : NSObject

//文件名
@property (nonatomic, copy) NSString *papername;
//文件类型
@property (nonatomic, copy) NSString *type;
//文件大小
@property (nonatomic, copy) NSString *size;
//下载链接
@property (nonatomic, copy) NSString *url;
//是否已经下载
@property (nonatomic, assign) BOOL download;

- (instancetype)initWithDict:(NSDictionary *)dict andDatabase:(FMDatabase *)db;
+ (instancetype)documentModelWithDict:(NSDictionary *)dict andDatabase:(FMDatabase *)db;

@end
