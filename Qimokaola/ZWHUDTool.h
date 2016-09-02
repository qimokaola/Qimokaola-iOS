//
//  ZWHUDTool.h
//  Qimokaola
//
//  Created by Administrator on 16/8/23.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ZWHUDTool : NSObject

+ (void)showHUDWithTitle:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration;

+ (void)showHUDInView:(UIView *)view withTitle:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration;

+ (MBProgressHUD *)successHUDInView:(UIView *)view withMessage:(NSString *)message;

+ (void)showSuccessHUDInView:(UIView *)view withMessage:(NSString *)message duration:(NSTimeInterval)duration;

+ (MBProgressHUD *)excutingHudInView:(UIView *)view title:(NSString *)title;

@end
