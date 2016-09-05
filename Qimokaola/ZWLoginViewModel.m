//
//  ZWLoginViewModel.m
//  Qimokaola
//
//  Created by Administrator on 16/9/3.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWLoginViewModel.h"
#import "ZWAPIRequestTool.h"

@implementation ZWLoginViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    RACSignal *accountValidSignal = [RACObserve(self, account) map:^id(NSString *value) {
        return @([self isAccountValid:value]);
    }];
    
    RACSignal *passwordValidSignal = [RACObserve(self, password) map:^id(NSString *value) {
        return @([self isPasswordValid:value]);
    }];
    
    RACSignal *commandEnableSignal = [RACSignal combineLatest:@[accountValidSignal, passwordValidSignal] reduce:^id(NSNumber *accountValid, NSNumber *passwordValid){
        return @([accountValid boolValue] && [passwordValid boolValue]);
    }];
    
    @weakify(self)
    self.loginCommand = [[RACCommand alloc] initWithEnabled:commandEnableSignal signalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [self loginSignal];
    }];
    
}

- (RACSignal *)loginSignal {
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [ZWAPIRequestTool requestLoginWithParameters:@{@"un": self.account, @"pw": self.password} result:^(id response, BOOL success) {
            if (success) {
                
                [subscriber sendNext:response];
                [subscriber sendCompleted];
                
            } else {
                
                [subscriber sendError:response];
            }
        }];
        
        return nil;
    }] delay:kRequestWaitingTime];
}

- (BOOL)isAccountValid:(NSString *)value {
    return value.length == 11;
}

- (BOOL)isPasswordValid:(NSString *)value {
    return value.length >= 6;
}

@end
