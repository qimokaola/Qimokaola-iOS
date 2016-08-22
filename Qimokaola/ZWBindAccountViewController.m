//
//  ZWBindAccountViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/8/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWBindAccountViewController.h"
#import "UIColor+CommonColor.h"
#import "Masonry.h"

@interface ZWBindAccountViewController ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *accountField;

@property (nonatomic, strong) UIView *accountLine;

@property (nonatomic, strong) UITextField *passwordField;

@property (nonatomic, strong) UIView *passwordLine;

@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation ZWBindAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createSubViews];
}

- (void)createSubViews {
    
    //创建并添加至父视图
    self.titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = ZWFont(22);
        label.textColor = [UIColor blackColor];
        label.text = @"绑定您的教务处账号";
        [label sizeToFit];
        [self.view addSubview:label];
        
        label;
    });
    
    self.accountField = ({
        UITextField *textField = [self commonTextField];
        textField.placeholder = @"教务处账号";
        [self.view addSubview:textField];
        
        textField;
    });
    
    self.accountLine = [self commonLine];
    [self.view addSubview:self.accountLine];
    
    self.passwordField = ({
        UITextField *textField = [self commonTextField];
        textField.placeholder = @"教务处密码";
        [self.view addSubview:textField];
        
        textField;
    });
    
    self.passwordLine = [self commonLine];
    [self.view addSubview:self.passwordLine];
    
    
    self.nextBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[RGB(80., 140., 238.) parseToImage] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIColor lightGrayColor] parseToImage] forState:UIControlStateDisabled];
        [btn setTitle:@"下一步" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        
        [self.view addSubview:btn];
        
        btn;
    });
    
    //设置视图约束
    
    __weak __typeof(self) weakSelf = self;
    
    CGFloat margin = 10.f;
    CGFloat midMargin = 20.f;
    CGFloat largeMargin = 30.f;
    
    CGFloat textFieldHeight = 30.f;
    CGFloat lineHiehgt = .5f;
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.centerY.equalTo(weakSelf.view).multipliedBy(.5f);
    }];
    
    [@[self.accountField, self.accountLine, self.passwordField, self.passwordLine, self.nextBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).with.offset(margin);
        make.right.equalTo(weakSelf.view).with.offset(- margin);
    }];
    
    [@[self.accountLine, self.passwordLine] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lineHiehgt);
    }];
    
    [@[self.accountField, self.passwordField] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textFieldHeight);
    }];
    
    //以accountLine位置为中心位置
    [self.accountLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.view);
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
