//
//  ZWRegisterViewModel.h
//  Qimokaola
//
//  Created by Administrator on 2016/11/26.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ZWRegisterViewModel : NSObject

@property (nonatomic, strong) NSString *phoneNumer;
@property (nonatomic, strong) NSString *verifyCode;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *confirmPwd;

@property (nonatomic, strong) RACSignal *distinctLabelHiddenSignal;

@property (nonatomic, strong) RACCommand *verifyCommand;
@property (nonatomic, strong) RACCommand *registerCommand;

@end
