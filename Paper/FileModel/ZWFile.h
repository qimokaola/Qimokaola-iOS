//
//  ZWFiles.h
//
//  Created by Administrator  on 16/4/4
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWDownloadInfoModel.h"


@interface ZWFile : NSObject <NSCoding, NSCopying>

//文件名
@property (nonatomic, copy) NSString *name;

//文件大小
@property (nonatomic, copy) NSString *size;

@property (nonatomic, copy) NSString *path;

//文件类型
@property (nonatomic, copy) NSString *type;

//文件下载链接（作为判断文件唯一性的标识符）
@property (nonatomic, copy) NSString *url;

//文件是否已下载的标识
@property (nonatomic, assign) BOOL download;

+ (instancetype)fileWithDownloadInfo:(ZWDownloadInfoModel *)model;

//用字典与路径初始化（name， size） 类方法
+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict URLString:(NSString *)URLString filePath:(NSString *)filePath;

//同上， 实例方法
- (instancetype)initWithDictionary:(NSDictionary *)dict URLString:(NSString *)URLString filePath:(NSString *)filePath;

//提取字典
- (NSDictionary *)dictionaryRepresentation;

@end
