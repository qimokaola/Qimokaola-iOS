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

+ (void)saveDownloadFileInfo:(ZWFile *)file;

+ (BOOL)isFileDownloaded:(ZWFile *)file;

@end
