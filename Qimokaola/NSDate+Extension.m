//
//  NSDate+CommomDate.m
//  Qimokaola
//
//  Created by Administrator on 15/10/12.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

+ (NSString *)current  {
    NSString *formatterString = @"yyyy-MM-dd";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatterString];
    return [formatter stringFromDate:[NSDate date]];
}

@end
