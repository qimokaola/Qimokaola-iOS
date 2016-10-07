//
//  ZWDataBaseTool.h
//  Qimokaola
//
//  Created by Administrator on 2016/9/20.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWFile.h"

@interface ZWDataBaseTool : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isFileDownloaded:(NSString *)fileIdentifier;

- (NSString *)fileNameInStorageWithIdentifier:(NSString *)fileIdentifier;

- (BOOL)addFileDownloadInfo:(ZWFile *)file
                    filenameInStorage:(NSString *)fileNameInStorage
                    inSchool:(NSString *)school
                    inCourse:(NSString *)course;
- (BOOL)deleteFileDownloadInfo:(NSString *)identifier;

@end
