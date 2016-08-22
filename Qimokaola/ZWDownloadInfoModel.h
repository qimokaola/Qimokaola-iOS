//
//  ZWDownloadInfo.h
//  Qimokaola
//
//  Created by Administrator on 15/10/12.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"

@interface ZWDownloadInfoModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *course;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *time;

- (instancetype) initWithFMReusultSet:(FMResultSet *)rs;
- (NSString *)filePath;
- (NSString *)file;
+ (instancetype) downloadInfoWithFMResultSet:(FMResultSet *)rs;

@end
