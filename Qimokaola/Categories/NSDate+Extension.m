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

+ (NSString *)secondsSince1970 {
    return [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
}

+ (NSString *)timeIntervalDescriptionWithPast:(NSString *)past {
    NSString *result = nil;
    int interval = (int)[[self date] timeIntervalSince1970] - past.intValue;
    if (interval <= 60) {
        result = @"1分钟前";
    } else if (interval <= 60 * 60) {
        result = [NSString stringWithFormat:@"%d分钟前", interval / 60];
    } else if (interval <= 60 * 60 * 24) {
        result = [NSString stringWithFormat:@"%d小时前", interval / (60 * 60)];
    } else if (interval <= 60 * 60 * 24 * 30) {
        result = [NSString stringWithFormat:@"%d天前", interval / (60 * 60 * 24)];;
    } else if (interval <= 60 * 60 * 24 * 30 * 12) {
        result = [NSString stringWithFormat:@"%d个月前", interval / (60 * 60 * 24 * 30)];
    } else {
        result = [NSString stringWithFormat:@"%d年前", interval / (60 * 60 * 24 * 30 * 12)];
    }
    return result;
}

@end
