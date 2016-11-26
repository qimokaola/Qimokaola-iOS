//
//  ZWRegisterViewModel.m
//  Qimokaola
//
//  Created by Administrator on 2016/11/26.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWRegisterViewModel.h"

@implementation ZWRegisterViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
}

- (BOOL)isPhoneNumberValid:(NSString *)phoneNumber {
    return phoneNumber.length == 11;
}

- (BOOL)isPasswordValid:(NSString *)password {
    return password.length >= 6;
}

- (BOOL)isVeifyCodeValid:(NSString *)vrification {
    if (vrification.length < 4) {
        return NO;
    }
    NSScanner *scanner = [NSScanner scannerWithString:vrification];
    int var;
    return [scanner scanInt:&var] && [scanner isAtEnd];
}

@end
