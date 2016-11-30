//
//  ZWResetPasswordViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/11/25.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWResetPasswordViewController.h"
#import "ZWResetPwdViewModel.h"
#import "ZWHUDTool.h"
#import "UIColor+Extension.h"
#import "ZWAccount.h"
#import "ZWUserManager.h"

@interface ZWResetPasswordViewController () {
    int timeLeft;
}


@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *verifyField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@property (nonatomic, strong) ZWResetPwdViewModel *viewModel;

@property (nonatomic, assign) BOOL verifyButtonDisable;

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation ZWResetPasswordViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (NSTimer *)timer {
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (NSString *)nibName {
    return  @"ZWResetPasswordViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.enterPhoneNumber) {
        self.phoneNumberField.text = self.enterPhoneNumber;
        if ([ZWUserManager sharedInstance].isLogin) {
            self.phoneNumberField.enabled = NO;
        }
    }
   
    [self.sendCodeButton setBackgroundImage:[defaultBlueColor parseToImage] forState:UIControlStateNormal];
    [self.sendCodeButton setBackgroundImage:[[UIColor lightGrayColor] parseToImage] forState:UIControlStateDisabled];
    [self.resetButton setBackgroundImage:[defaultBlueColor parseToImage] forState:UIControlStateNormal];
    [self.resetButton setBackgroundImage:[[UIColor lightGrayColor] parseToImage] forState:UIControlStateDisabled];
    self.resetButton.layer.masksToBounds = YES;
    [self bindViewModel];
}

- (void)bindViewModel {
    _viewModel = [[ZWResetPwdViewModel alloc] init];
    
    RAC(_viewModel, phoneNumer) = self.phoneNumberField.rac_textSignal;
    RAC(_viewModel, verifyCode) = self.verifyField.rac_textSignal;
    RAC(_viewModel, password) = self.passwordField.rac_textSignal;
    
    RAC(_viewModel, verifyButtonEnable) = [RACObserve(self, verifyButtonDisable) not];
    
    _sendCodeButton.rac_command = _viewModel.verifyCommand;
    _resetButton.rac_command = _viewModel.resetCommand;
    
    @weakify(self)
    
    [[[self.sendCodeButton.rac_command.executionSignals doNext:^(id x) {
        @strongify(self)
        [self.view endEditing:YES];
    }] switchToLatest] subscribeNext:^(NSDictionary *response) {
        @strongify(self)
        int responseCode = [[response objectForKey:kHTTPResponseCodeKey] intValue];
        if (responseCode == 0) {
            self.verifyButtonDisable = YES;
            [self tappedSendCodeButton];
        }
        NSString *msg = [response objectForKey:kHTTPResponseInfoKey];
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:msg message:nil duration:1.0];
    }];
    
    [self.sendCodeButton.rac_command.errors subscribeNext:^(id x) {
        @strongify(self)
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"获取验证码失败" message:nil duration:kShowHUDShort];
    }];

    [[[self.resetButton.rac_command.executionSignals doNext:^(id x) {
        @strongify(self)
        [ZWHUDTool excutingHudInView:self.navigationController.view title:nil];
        [self.view endEditing:YES];
    }] switchToLatest] subscribeNext:^(NSDictionary *result) {
        @strongify(self)
        [[MBProgressHUD HUDForView:self.navigationController.view] hideAnimated:NO];
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:[result objectForKey:kHTTPResponseInfoKey] message:nil duration:kShowHUDMid];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDMid * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([[result objectForKey:kHTTPResponseCodeKey] intValue] == 0) {
                
                // 修改密码成功之后将账户写入文件
                ZWAccount *account = [[ZWAccount alloc] init];
                account.account = self.phoneNumberField.text;
                account.pwd = self.passwordField.text;
                [account writeData];
                
                if (self.completion) {
                    self.completion();
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
    }];
    
    [self.resetButton.rac_command.errors subscribeNext:^(NSError *error) {
        @strongify(self)
        [[MBProgressHUD HUDForView:self.navigationController.view] hideAnimated:NO];
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"请求错误" message:@"请检查网络连接" duration:kShowHUDMid];
    }];
}


- (void)tappedSendCodeButton {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        timeLeft = kSendCodeTimeInterval;
    }
    [self.phoneNumberField resignFirstResponder];
    timeLeft = kSendCodeTimeInterval;
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)countDown {
    if (-- timeLeft > 0) {
        [self.sendCodeButton setTitle:[NSString stringWithFormat:@"%d秒后重发", timeLeft] forState:UIControlStateDisabled];
    } else {
        self.verifyButtonDisable = NO;
        [self.sendCodeButton setTitle:[NSString stringWithFormat:@"%d秒后重发", kSendCodeTimeInterval] forState:UIControlStateDisabled];
        [self.timer invalidate];
        self.timer = nil;
        timeLeft = kSendCodeTimeInterval;
    }
}


@end
