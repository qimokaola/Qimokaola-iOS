//
//  ZWFileModel.h
//
//  Created by Administrator  on 16/4/4
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ZWFileModel : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, copy) NSString *base;
@property (nonatomic, strong) NSArray *folders;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
