//
//  NSDate+CommomDate.m
//  Paper
//
//  Created by Administrator on 15/10/12.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "NSDate+CommomDate.h"

@implementation NSDate (CommomDate)

+ (NSString *)current  {
    NSString *formatterString = @"yyyy-MM-dd";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatterString];
    return [formatter stringFromDate:[NSDate date]];
}

@end
