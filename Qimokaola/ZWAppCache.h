//
//  ZWAppCache.h
//  Qimokaola
//
//  Created by Administrator on 16/4/8.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWFileModel.h"

@interface ZWAppCache : NSObject

+ (ZWFileModel *)loadCachedFileModel;
+ (BOOL)saveCacheFileModel:(ZWFileModel *)model;

@end
