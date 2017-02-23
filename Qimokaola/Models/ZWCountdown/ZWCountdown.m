//
//  ZWCountdown.m
//  Qimokaola
//
//  Created by Administrator on 2017/2/23.
//  Copyright © 2017年 Administrator. All rights reserved.
//

#import "ZWCountdown.h"

@implementation ZWCountdown

- (void)encodeWithCoder:(NSCoder *)aCoder { [self modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self modelCopy]; }
- (NSUInteger)hash { return [self modelHash]; }
- (BOOL)isEqual:(id)object { return [self modelIsEqual:object]; }
- (NSString *)description { return [self modelDescription]; }

@end
