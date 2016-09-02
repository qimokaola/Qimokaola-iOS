//
//  ZWHUDTool.m
//  Qimokaola
//
//  Created by Administrator on 16/8/23.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWHUDTool.h"

@implementation ZWHUDTool

+ (void)showHUDWithTitle:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration {
    [self showHUDInView:[[UIApplication sharedApplication].windows lastObject] withTitle:title message:message duration:duration];
}

+ (MBProgressHUD *)successHUDInView:(UIView *)view withMessage:(NSString *)message {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
    hud.label.text = message;
    hud.square = YES;
    return hud;
}

+ (void)showSuccessHUDInView:(UIView *)view withMessage:(NSString *)message duration:(NSTimeInterval)duration {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
    hud.label.text = message;
    hud.square = YES;
    [hud hideAnimated:YES afterDelay:duration];
}

+ (void)showHUDInView:(UIView *)view withTitle:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = title;
    hud.detailsLabel.text = message;
    hud.userInteractionEnabled = NO;
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:duration];
}

+ (MBProgressHUD *)excutingHudInView:(UIView *)view title:(NSString *)title {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = title;
    return hud;
}

@end
