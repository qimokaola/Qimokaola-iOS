//
//  ZWRegisterViewModel.m
//  Qimokaola
//
//  Created by Administrator on 2016/11/26.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWRegisterViewModel.h"
#import "ZWAPIRequestTool.h"

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
    RACSignal *phoneNumberValidSignal = [RACObserve(self, phoneNumer) map:^id(NSString *value) {
        return @([self isPhoneNumberValid:value]);
    }];
    RACSignal *verifyCodeValidSignal = [RACObserve(self, verifyCode) map:^id(NSString *value) {
        return @([self isVeifyCodeValid:value]);
    }];
    RACSignal *passwordValidSignal = [RACObserve(self, password) map:^id(NSString *value) {
        return @([self isPasswordValid:value]);
    }];
    
    RACSignal *nextButtonEnableSignal = [RACSignal combineLatest:@[phoneNumberValidSignal, verifyCodeValidSignal, passwordValidSignal] reduce:^(NSNumber *phoneNumberValid, NSNumber *verifyCodeValid, NSNumber *passwordValid){
        return @(phoneNumberValid.boolValue && verifyCodeValid.boolValue && passwordValid.boolValue);
    }];
    
    self.verifyCommand = [[RACCommand alloc] initWithEnabled:RACObserve(self, verifyButtonEnable) signalBlock:^RACSignal *(id input) {
        return [self getVerifyCodeSignal];
    }];
    
    self.registerCommand = [[RACCommand alloc] initWithEnabled:nextButtonEnableSignal signalBlock:^RACSignal *(id input) {
        return [self verifyCodeSignal];
    }];
}

- (RACSignal *)verifyCodeSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [ZWAPIRequestTool requestVerifyCodeWithParameter:@{@"code": self.verifyCode} result:^(id response, BOOL success) {
            if (success) {
                [subscriber sendNext:response];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:response];
            }
        }];
        return nil;
    }] ;
    
}

- (RACSignal *)getVerifyCodeSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [ZWAPIRequestTool requestSendCodeWithParameter:@{@"phone": self.phoneNumer} result:^(id response, BOOL success) {
            if (success) {
                [subscriber sendNext:response];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:response];
            }
        }];
        return nil;
    }];
}

- (BOOL)isPhoneNumberValid:(NSString *)phoneNumber {
    return phoneNumber.length == kPhoneNumberLength;
}

- (BOOL)isPasswordValid:(NSString *)password {
    return password.length >= 6;
}

- (BOOL)isVeifyCodeValid:(NSString *)verifyCode {
    return verifyCode.length >= 4;
//    if (verifyCode.length < 4) {
//        return NO;
//    }
//    NSScanner *scanner = [NSScanner scannerWithString:verifyCode];
//    int var;
//    return [scanner scanInt:&var] && [scanner isAtEnd];
}

@end
