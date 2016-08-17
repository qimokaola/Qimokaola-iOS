//
//  ZWRegisterViewCotroller.m
//  Paper
//
//  Created by Administrator on 16/7/14.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWRegisterViewCotroller.h"
#import "UIColor+CommonColor.h"
#import "IQKeyboardManager.h"
#import "Masonry.h"
#import "ReactiveCocoa.h"
#import "ZWFilloutInformationViewController.h"

@interface ZWRegisterViewCotroller ()

//退出按钮
@property (nonatomic, strong) UIBarButtonItem *exitItem;

//“输入手机号” 标签
@property (nonatomic, strong) UILabel *titleLabel;

//手机号用途标签
@property (nonatomic, strong) UILabel *usageLabel;

//手机号输入框
@property (nonatomic, strong) UITextField *phoneNumberField;

//手机号输入框下的线
@property (nonatomic, strong) UIView *phoneNumberLine;

//密码输入框
@property (nonatomic, strong) UITextField *passwordField;

//密码输入框下的线
@property (nonatomic, strong) UIView *passwordLine;

//下一步按钮
@property (nonatomic, strong) UIButton *nextBtn;

//底部几个有关于协议的控件的容器
@property (nonatomic, strong) UIView *protocolView;

//底部协议标签
@property (nonatomic, strong) UILabel *protocolLabel;

//底部协议按钮
@property (nonatomic, strong) UIButton *protocolBtn;

@end

@implementation ZWRegisterViewCotroller

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
    
    RACSignal *passwordValidSignal = [self.passwordField.rac_textSignal map:^id(NSString *value) {
        return @([self isPasswordValid:value]);
    }];
    
    RAC(self.nextBtn, enabled) = [RACSignal combineLatest:@[phoneNumberValidSignal, passwordValidSignal] reduce:^id(NSNumber *phoneNumberValid, NSNumber *passwordValid){
        return @([phoneNumberValid boolValue] && [passwordValid boolValue]);
    }];
    
    @weakify(self)
    [[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        ZWFilloutInformationViewController *fillout = [[ZWFilloutInformationViewController alloc] init];
        [self.navigationController pushViewController:fillout animated:YES];
    }];
    
    [[self.protocolBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
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
    [@[self.phoneNumberField, self.phoneNumberLine, self.passwordField, self.passwordLine, self.nextBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).with.offset(margin);
        make.right.equalTo(weakSelf.view).with.offset(- margin);
    }];
    
    //以phoneNumberLine位置为中心位置,即此控件处于Y轴中心
    [self.phoneNumberLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lineHeight);
        make.centerY.equalTo(weakSelf.view);
    }];
    
    [self.phoneNumberField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textFieldHeight);
        make.bottom.equalTo(weakSelf.phoneNumberLine.mas_top);
    }];
    
    [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textFieldHeight);
        make.top.equalTo(weakSelf.phoneNumberLine.mas_bottom).with.offset(midMargin);
    }];
    
    [self.passwordLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lineHeight);
        make.top.equalTo(weakSelf.passwordField.mas_bottom);
    }];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(45.f);
        make.top.equalTo(weakSelf.passwordLine.mas_bottom).with.offset(largeMargin);
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

- (void)exit {
    [self dismissViewControllerAnimated:YES completion:nil];
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
