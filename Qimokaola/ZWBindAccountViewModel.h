//
//  ZWBindAccountViewModel.h
//  Qimokaola
//
//  Created by Administrator on 16/8/31.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import "ZWAPIRequestTool.h"

@interface ZWBindAccountViewModel : NSObject

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) RACCommand *nextCommand;

@end
