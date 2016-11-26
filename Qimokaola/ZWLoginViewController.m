//
//  ZWLoginViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/7/14.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWLoginViewController.h"
#import "UIColor+Extension.h"
#import "ZWLoginViewModel.h"
#import "ZWHUDTool.h"
#import "ZWTabBarController.h"
#import "ZWAPITool.h"
#import "ZWAPIRequestTool.h"
#import "ZWUserManager.h"
#import "ZWResetPasswordViewController.h"

#import "Masonry.h"
#import "ReactiveCocoa.h"
#import <YYKit/YYKit.h>

@interface ZWLoginViewController ()

@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UIView *accountLine;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIView *passwordLine;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *forgetPwdButton;

@property (nonatomic, strong) ZWLoginViewModel *viewModel;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ZWLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *exitItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(exit)];
    self.navigationItem.leftBarButtonItem = exitItem;
    
    self.title = @"登录";
    
    [self createSubViews];
    
    [self bindViewModel];
}

- (void)forgetPwdButtonClicked {
    ZWResetPasswordViewController *resetPwdViewController = [[ZWResetPasswordViewController alloc] init];
    [self.navigationController pushViewController:resetPwdViewController animated:YES];
}

- (void)bindViewModel {
    self.viewModel = [[ZWLoginViewModel alloc] init];
    
    RAC(self.viewModel, account) = self.accountField.rac_textSignal;
    RAC(self.viewModel, password) = self.passwordField.rac_textSignal;
    
    self.nextBtn.rac_command = self.viewModel.loginCommand;
    
    @weakify(self)
    [[self.nextBtn.rac_command.executionSignals switchToLatest] subscribeNext:^(NSDictionary *result) {
        @strongify(self)
        int resultCode = [[result objectForKey:kHTTPResponseCodeKey] intValue];
        if (resultCode == 0) {
            // 保存用户登录信息
            ZWUser *user = [ZWUser modelWithDictionary:[result objectForKey:kHTTPResponseResKey]];
            [ZWUserManager sharedInstance].loginUser = user;
            
            // 发送用户登录成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginSuccessNotification object:nil];

            MBProgressHUD *hud = [ZWHUDTool successHUDInView:self.navigationController.view withMessage:@"登录成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDMid * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                
                // 根据根视图类型决定跳转类型
                if (![[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[ZWTabBarController class]]) {
                    // 若根视图的类型不为 ZWTabBarController ，表明当前位于登录注册视图，则需切换根视图
                    ZWTabBarController *tabrBarController = [[ZWTabBarController alloc] init];
                    [UIApplication sharedApplication].keyWindow.rootViewController = tabrBarController;
                } else {
                    // 根视图的类型为 ZWTabBarController, 则只需 dismiss 此 Controller
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            });
        } else {
            [ZWHUDTool showHUDWithTitle:[result objectForKey:kHTTPResponseInfoKey] message:nil duration:kShowHUDMid];
        }
        
    }];
    
    [self.nextBtn.rac_command.errors subscribeNext:^(id x) {
        NSLog(@"%@", x);
        [ZWHUDTool showHUDWithTitle:@"请求错误" message:@"请检查网络连接" duration:kShowHUDMid];
    }];
    
    [self.nextBtn.rac_command.executing subscribeNext:^(id x) {
        @strongify(self)
        if ([x boolValue]) {
            if (self.hud == nil) {
                self.hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:@"正在登陆..."];
            }
        } else {
            [self.hud hideAnimated:YES];
            self.hud = nil;
        }
    }];
}

- (void)createSubViews {
    
    __weak __typeof(self) weakSelf = self;
    
    CGFloat margin = 10.f;
    CGFloat midMargin = 20.f;
    CGFloat largeMargin = 30.f;
    
    CGFloat cornerRadius = 5.f;
    
    CGFloat textFieldHeight = 30.f;
    CGFloat lineHeight = .5f;
    
    self.accountField = ({
        UITextField *field = [self commonTextField];
        field.placeholder = @"输入手机号";
        
        [self.view addSubview:field];
        
        field;
    });
    
    self.accountLine = [self commonLine];
    [self.view addSubview:self.accountLine];
    
    self.passwordField = ({
        UITextField *field = [self commonTextField];
        field.secureTextEntry = YES;
        field.placeholder = @"输入密码";
        
        [self.view addSubview:field];
        
        field;
    });
    
    self.passwordLine = [self commonLine];
    [self.view addSubview:self.passwordLine];

    self.nextBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[RGB(80., 140., 238.) parseToImage] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIColor lightGrayColor] parseToImage] forState:UIControlStateDisabled];
        [btn setTitle:@"登录" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = cornerRadius;
        btn.layer.masksToBounds = YES;
        
        [self.view addSubview:btn];
        
        btn;
    });
    
    self.forgetPwdButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        NSString *titleString = @"忘记密码?";
        NSRange range = NSMakeRange(0, titleString.length);
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:titleString];
        [attString addAttribute:NSForegroundColorAttributeName value:RGB(80., 140., 238.) range:range];
        [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
        [attString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
        
        [btn setAttributedTitle:attString forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(forgetPwdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [btn sizeToFit];
        [self.view addSubview:btn];
        
        btn;
    });
    
    [@[self.accountField, self.accountLine, self.passwordField, self.passwordLine, self.nextBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).with.offset(margin);
        make.right.equalTo(weakSelf.view).with.offset( -margin);
    }];
    
    [@[self.passwordField, self.accountField] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textFieldHeight);
    }];
    
    [@[self.accountLine, self.passwordLine] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lineHeight);
    }];
    
    //以accountLine位置为中心
    [self.accountLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.view).multipliedBy(0.8);
    }];
    
    [self.accountField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.accountLine.mas_top);
    }];
    
    [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.accountLine.mas_bottom).with.offset(midMargin);
    }];
    
    [self.passwordLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passwordField.mas_bottom);
    }];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passwordLine.mas_bottom).with.offset(largeMargin);
        make.height.mas_equalTo(45.f);
    }];
    
    [self.forgetPwdButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.nextBtn.mas_bottom).with.offset(10);
    }];
}

- (void)exit {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)commonLine {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RGB(240., 240., 240.);
    return view;
}

- (UITextField *)commonTextField {
    UITextField *textField = [[UITextField alloc] init];
    textField.borderStyle = UITextBorderStyleNone;
    textField.font = ZWFont(17);
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    return textField;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
