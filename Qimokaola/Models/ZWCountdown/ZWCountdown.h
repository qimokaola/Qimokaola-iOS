//
//  ZWCountdown.h
//  Qimokaola
//
//  Created by Administrator on 2017/2/23.
//  Copyright © 2017年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYKit/YYKit.h>

@interface ZWCountdown : NSObject

// 以时间戳作为ID
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *examName;
@property (nonatomic, strong) NSDate *examDate;
@property (nonatomic, strong) NSString *examLocation;
@property (nonatomic, strong) NSDate *alarmDate;
@property (nonatomic, strong) NSString *timeOfAhead;

@end
