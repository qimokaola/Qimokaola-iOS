//
//  ZWResetPwdViewModel.h
//  Qimokaola
//
//  Created by Administrator on 2016/11/30.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ZWResetPwdViewModel : NSObject

@property (nonatomic, strong) NSString *phoneNumer;
@property (nonatomic, strong) NSString *verifyCode;
@property (nonatomic, strong) NSString *password;


/**
 额外控制按钮的变量
 */
@property (nonatomic, assign) BOOL verifyButtonEnable;

///**
// 额外控制按钮的信号
// */
//@property (nonatomic, strong) RACSignal *extraEnableSignal;

@property (nonatomic, strong) RACCommand *verifyCommand;
@property (nonatomic, strong) RACCommand *resetCommand;

@end
