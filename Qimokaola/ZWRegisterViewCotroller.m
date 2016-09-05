//
//  ZWRegisterViewCotroller.m
//  Qimokaola
//
//  Created by Administrator on 16/7/14.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWRegisterViewCotroller.h"
#import "UIColor+Extension.h"
#import "IQKeyboardManager.h"
#import "Masonry.h"
#import "ReactiveCocoa.h"
#import "ZWFilloutInformationViewController.h"
#import "ZWAPIRequestTool.h"
#import "ZWHUDTool.h"

@interface ZWRegisterViewCotroller () {
    int timeLeft;
}

// 退出按钮
@property (nonatomic, strong) UIBarButtonItem *exitItem;

// “输入手机号” 标签
@property (nonatomic, strong) UILabel *titleLabel;

// 手机号用途标签
@property (nonatomic, strong) UILabel *usageLabel;

// 手机号输入框
@property (nonatomic, strong) UITextField *phoneNumberField;

// 手机号输入框下的线
@property (nonatomic, strong) UIView *phoneNumberLine;

// 验证码输入框
@property (nonatomic, strong) UITextField *verifyField;

// 获取验证码按钮
@property (nonatomic, strong) UIButton *sendCodeButton;

// 验证码输入框下划线
@property (nonatomic, strong) UIView *verifyLine;

// 密码输入框
@property (nonatomic, strong) UITextField *passwordField;

// 密码输入框下的线
@property (nonatomic, strong) UIView *passwordLine;

// 下一步按钮
@property (nonatomic, strong) UIButton *nextBtn;

// 下一步按钮上的运行提示 - UIActivityIndicatorView
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

// 底部几个有关于协议的控件的容器
@property (nonatomic, strong) UIView *protocolView;

// 底部协议标签
@property (nonatomic, strong) UILabel *protocolLabel;

// 底部协议按钮
@property (nonatomic, strong) UIButton *protocolBtn;

// 计数器
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation ZWRegisterViewCotroller

- (NSTimer *)timer {
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //退出按钮
    self.exitItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(exit)];
    self.navigationItem.leftBarButtonItem = self.exitItem;
    
    //创建并布局子视图
    [self createSubViews];
    
    //事件处理
    RACSignal *phoneNumberValidSignal = [self.phoneNumberField.rac_textSignal map:^id(NSString *value) {
        return @([self isPhoneNumberValid:value]);
    }];
    
    RACSignal *verficationValidSignal = [self.verifyField.rac_textSignal map:^id(NSString *value) {
        return @([self isVeifyCodeValid:value]);
    }];
    
    RACSignal *passwordValidSignal = [self.passwordField.rac_textSignal map:^id(NSString *value) {
        return @([self isPasswordValid:value]);
    }];
    
    RACSignal *nextButtonEnableSignal = [RACSignal combineLatest:@[phoneNumberValidSignal, verficationValidSignal, passwordValidSignal] reduce:^id(NSNumber *phoneNumberValid, NSNumber *verficationValid, NSNumber *passwordValid){
        return @([phoneNumberValid boolValue] && [passwordValid boolValue] && [verficationValid boolValue]);
    }];
    
    @weakify(self)
    self.nextBtn.rac_command = [[RACCommand alloc] initWithEnabled:nextButtonEnableSignal signalBlock:^RACSignal *(id input) {
        
        return [self verifyCodeSignal];
        
    }];
    
    [[[self.nextBtn.rac_command.executionSignals doNext:^(id x) {
        
        @strongify(self)
        [self.indicator startAnimating];
        [self.nextBtn setTitle:@"正在验证" forState:UIControlStateNormal];
        
    }] switchToLatest] subscribeNext:^(NSDictionary *result) {
        
        @strongify(self)
        
        [self.indicator stopAnimating];
        [self.nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        
        if ([[[result objectForKey:@"res"] objectForKey:@"ok"] intValue] == 1) {
            MBProgressHUD *hud = [ZWHUDTool successHUDInView:self.navigationController.view withMessage:@"验证成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDShort * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                
                ZWFilloutInformationViewController *fillout = [[ZWFilloutInformationViewController alloc] init];
                fillout.registerParam = @{@"phone": self.phoneNumberField.text, @"password": self.passwordField.text};
                [self.navigationController pushViewController:fillout animated:YES];
                
            });
        } else {
            [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"验证错误" message:@"无效的验证码" duration:kShowHUDMid];
        }
        
    }];
    
    [self.nextBtn.rac_command.errors subscribeNext:^(NSError *error) {
        
        @strongify(self)
        [self.indicator stopAnimating];
        [self.nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"请求错误" message:@"请检查网络连接" duration:kShowHUDLong];
        
    }];
    
    [[self.protocolBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
    }];
    
    [[[self.sendCodeButton rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        
        @strongify(self)
        self.sendCodeButton.enabled = NO;
        
    }] subscribeNext:^(id x) {
        
        @strongify(self)
        [self tappedSendCodeButton];
        
    }];
}

- (RACSignal *)verifyCodeSignal {
    
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    
        @strongify(self)

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [ZWAPIRequestTool requestVerifyCodeWithParameter:@{@"code": self.verifyField.text} result:^(id response, BOOL success) {
                
                if (success) {
                    
                    [subscriber sendNext:response];
                    [subscriber sendCompleted];
                    
                } else {
                    
                    [subscriber sendError:response];
                }
                
            }];
            
        });
        
        return nil;
        
    }];
    
}

- (void)createSubViews {
    __weak __typeof(self) weakSelf = self;
    
    CGFloat margin = 10.f;
    CGFloat midMargin = 20.f;
    CGFloat largeMargin = 30.f;
    CGFloat textFieldHeight = 30.f;
    CGFloat lineHeight = .5f;
    
    UIFont *fieldFont = ZWFont(17);
    
    UIColor *lineColor = RGB(240., 240., 240.);
    
    //初始化并添加视图
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.font = ZWFont(22);
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"输入您的手机号";
    [self.titleLabel sizeToFit];
    [self.view addSubview:self.titleLabel];
    
    self.usageLabel = [[UILabel alloc] init];
    self.usageLabel.numberOfLines = 1;
    self.usageLabel.font = ZWFont(17);
    self.usageLabel.textColor = [UIColor lightGrayColor];
    self.usageLabel.textAlignment = NSTextAlignmentCenter;
    self.usageLabel.text = @"手机号仅用于登录和保护账号安全";
    [self.usageLabel sizeToFit];
    [self.view addSubview:self.usageLabel];
    
    self.phoneNumberField = [[UITextField alloc] init];
    self.phoneNumberField.font = fieldFont;
    self.phoneNumberField.placeholder = @"输入11位手机号码";
    self.phoneNumberField.borderStyle = UITextBorderStyleNone;
    self.phoneNumberField.keyboardType = UIKeyboardTypePhonePad;
    self.phoneNumberField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.phoneNumberField];
    
    self.phoneNumberField.text = @"13067340323";
    
    self.phoneNumberLine = [[UIView alloc] init];
    self.phoneNumberLine.backgroundColor = lineColor;
    [self.view addSubview:self.phoneNumberLine];
    
    self.verifyField = [[UITextField alloc] init];
    self.verifyField.font = fieldFont;
    self.verifyField.placeholder = @"验证码";
    self.verifyField.borderStyle = UITextBorderStyleNone;
    self.verifyField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.verifyField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.verifyField];
    
    self.sendCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
     [self.sendCodeButton setTitle:[NSString stringWithFormat:@"%d秒后重发", TimeInterval] forState:UIControlStateDisabled];
    [self.sendCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendCodeButton setBackgroundImage:[RGB(80., 140., 238.) parseToImage] forState:UIControlStateNormal];
    [self.sendCodeButton setBackgroundImage:[[UIColor lightGrayColor] parseToImage] forState:UIControlStateDisabled];
    self.sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.sendCodeButton];
    
    self.verifyLine = [[UIView alloc] init];
    self.verifyLine.backgroundColor = lineColor;
    [self.view addSubview:self.verifyLine];
    
    self.passwordField = [[UITextField alloc] init];
    self.passwordField.font = fieldFont;
    self.passwordField.placeholder = @"输入密码，长度不小于6位";  
    self.phoneNumberField.borderStyle = UITextBorderStyleNone;
    self.passwordField.secureTextEntry = YES;
    self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.passwordField];
    
    self.passwordField.text = @"1234567";
    
    self.passwordLine = [[UIView alloc] init];
    self.passwordLine.backgroundColor = lineColor;
    [self.view addSubview:self.passwordLine];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextBtn setBackgroundImage:[RGB(80., 140., 238.) parseToImage] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[[UIColor lightGrayColor] parseToImage] forState:UIControlStateDisabled];
    [self.nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextBtn.layer.cornerRadius = 5;
    self.nextBtn.layer.masksToBounds = YES;
    [self.view addSubview:self.nextBtn];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_nextBtn addSubview:_indicator];
    
    self.protocolView = [[UIView alloc] init];
    [self.view addSubview:self.protocolView];
    
    self.protocolLabel = [[UILabel alloc] init];
    self.protocolLabel.numberOfLines = 1;
    self.protocolLabel.font = ZWFont(14);
    self.protocolLabel.textColor = [UIColor lightGrayColor];
    self.protocolLabel.text = @"注册即同意";
    [self.protocolLabel sizeToFit];
    [self.protocolView addSubview:self.protocolLabel];
    
    self.protocolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"<期末考啦使用协议>"];
    NSRange titleRange = {0,[title length]};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRange];
    [title addAttribute:NSFontAttributeName value:ZWFont(14) range:titleRange];
    [title addAttribute:NSForegroundColorAttributeName value:RGB(80., 140., 238.) range:titleRange];
    [self.protocolBtn setAttributedTitle:title
                      forState:UIControlStateNormal];
    NSMutableAttributedString *highlightedTitle = [title mutableCopy];
    [highlightedTitle removeAttribute:NSForegroundColorAttributeName range:titleRange];
    [highlightedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:titleRange];
    [self.protocolBtn setAttributedTitle:highlightedTitle forState:UIControlStateHighlighted];
    [self.protocolBtn sizeToFit];
    [self.protocolView addSubview:self.protocolBtn];
    
    //设置视图约束
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.view).multipliedBy(0.4);
        make.left.and.right.equalTo(weakSelf.view);
    }];
    
    [self.usageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(weakSelf.titleLabel);
        make.top.equalTo(weakSelf.titleLabel.mas_bottom).with.offset(15);
    }];
    
    //几个控件距父视图左右距离均为margin
    [@[self.phoneNumberField, self.phoneNumberLine, self.passwordField, self.passwordLine, self.nextBtn, self.verifyLine] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).with.offset(margin);
        make.right.equalTo(weakSelf.view).with.offset(- margin);
    }];
    
    [@[self.phoneNumberLine, self.verifyLine, self.passwordLine] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lineHeight);
    }];
    
    [@[self.phoneNumberField, self.passwordField, self.verifyField] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textFieldHeight);
    }];
    
    //以phoneNumberLine位置为中心位置,即此控件处于Y轴中心
    [self.phoneNumberLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.view);
    }];
    
    [self.phoneNumberField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.phoneNumberLine.mas_top);
    }];
    
    [self.verifyField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).with.offset(margin);
        make.top.equalTo(weakSelf.phoneNumberLine.mas_bottom).with.offset(midMargin);
        make.width.equalTo(weakSelf.view).multipliedBy(0.7);
        make.height.mas_equalTo(textFieldHeight);
    }];
    
    [self.sendCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.verifyField);
        make.left.equalTo(weakSelf.verifyField.mas_right);
        make.right.equalTo(weakSelf.view).with.offset(- margin);
        make.height.mas_equalTo(textFieldHeight + midMargin);
    }];
    
    [self.verifyLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.verifyField.mas_bottom);
    }];
    
    [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.verifyLine.mas_bottom).with.offset(midMargin);
    }];
    
    [self.passwordLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passwordField.mas_bottom);
    }];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(45.f);
        make.top.equalTo(weakSelf.passwordLine.mas_bottom).with.offset(largeMargin);
    }];
    
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(weakSelf.nextBtn.titleLabel.mas_left).with.offset(- margin);
        make.centerY.equalTo(weakSelf.nextBtn);
        
    }];
    
    [self.protocolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30.f);
        make.centerX.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view).with.offset(- margin / 2);
        make.left.equalTo(weakSelf.protocolLabel);
        make.right.equalTo(weakSelf.protocolBtn);
    }];
    
    [self.protocolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.height.equalTo(weakSelf.protocolView);
        make.right.equalTo(weakSelf.protocolBtn.mas_left);
    }];
    
    [self.protocolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.and.height.equalTo(weakSelf.protocolView);
        make.left.equalTo(weakSelf.protocolLabel.mas_right);
    }];
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

- (void)exit {
    [self dismissViewControllerAnimated:YES completion:nil];
}

int TimeInterval = 60;

- (void)tappedSendCodeButton {
    timeLeft = TimeInterval;
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [ZWAPIRequestTool requestSendCodeWithParameter:@{@"phone": self.phoneNumberField.text} result:^(id response, BOOL success) {
       
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle: success ? [response objectForKey:@"info"] : @"获取验证码失败" message:nil duration:1.0];
        
    }];
}

- (void)countDown {
    if (-- timeLeft > 0) {
        
        [self.sendCodeButton setTitle:[NSString stringWithFormat:@"%d秒后重发", timeLeft] forState:UIControlStateDisabled];
        
    } else {
        self.sendCodeButton.enabled = YES;
    
         [self.sendCodeButton setTitle:[NSString stringWithFormat:@"%d秒后重发", TimeInterval] forState:UIControlStateDisabled];
        
        [self.timer invalidate];
        self.timer = nil;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
