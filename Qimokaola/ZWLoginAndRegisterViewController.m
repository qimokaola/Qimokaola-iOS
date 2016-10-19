//
//  ZWLoginAndRegisterViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/8/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWLoginAndRegisterViewController.h"
#import "ZWRegisterViewCotroller.h"
#import "ZWLoginViewController.h"
#import "ZWTabBarController.h"
#import "ZWHUDTool.h"

#import "Masonry.h"
#import "ReactiveCocoa.h"

@interface ZWLoginAndRegisterViewController ()

//展示大图的UIImageView
@property (nonatomic, strong) UIImageView *appImageView;

//放置按钮的容器
@property (nonatomic, strong) UIView *btnContainer;

//登录按钮
@property (nonatomic, strong) UIButton *loginBtn;

//注册按钮
@property (nonatomic, strong) UIButton *registerBtn;

@end

@implementation ZWLoginAndRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createSubViews];
    
    //监听按钮按下动作
    @weakify(self)
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        ZWLoginViewController *loginViewController = [[ZWLoginViewController alloc] init];
        [self presentViewController:[self nextViewController:loginViewController] animated:YES completion:nil];
    }];
    
    [[self.registerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        ZWRegisterViewCotroller *registerViewController = [[ZWRegisterViewCotroller alloc] init];
        [self presentViewController:[self nextViewController:registerViewController] animated:YES completion:nil];
    }];
}

- (void)createSubViews {
    __weak __typeof(self) weakSelf = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat heightRate = 0.832f;
    CGFloat btnCornerRadius = 5.f;
    CGFloat margin = 10.f;
    
    //初始化并添加视图
    self.appImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_login_register_display"]];
    [self.view addSubview:self.appImageView];
    
    self.btnContainer = [[UIView alloc] init];
    self.btnContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.btnContainer];
    
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginBtn setBackgroundColor:defaultBlueColor];
    [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginBtn.layer.cornerRadius = btnCornerRadius;
    self.loginBtn.layer.masksToBounds = YES;
    [self.btnContainer addSubview:self.loginBtn];
    
    self.registerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.registerBtn setBackgroundColor:[UIColor whiteColor]];
    [self.registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [self.registerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.registerBtn.layer.borderWidth = .5f;
    self.registerBtn.layer.borderColor = RGB(170., 170., 170.).CGColor;
    self.registerBtn.layer.cornerRadius = btnCornerRadius;
    self.registerBtn.layer.masksToBounds = YES;
    [self.btnContainer addSubview:self.registerBtn];
    
    //设置视图约束
    [self.appImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(weakSelf.view);
        make.height.equalTo(weakSelf.view).multipliedBy(heightRate);
    }];
    
    [self.btnContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.appImageView.mas_bottom);
    }];
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf.registerBtn);
        make.left.equalTo(weakSelf.registerBtn.mas_right).with.offset(margin);
        make.right.equalTo(weakSelf.btnContainer).with.offset(- margin);
    }];
    
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf.loginBtn);
        make.left.equalTo(weakSelf.btnContainer).with.offset(margin);
        make.right.equalTo(weakSelf.loginBtn.mas_left).with.offset(- margin);
    }];
    
    [@[self.loginBtn, self.registerBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.btnContainer);
        make.height.equalTo(weakSelf.btnContainer).multipliedBy(0.5);
    }];
}

- (UINavigationController *)nextViewController:(UIViewController *)viewController {
    return [[UINavigationController alloc] initWithRootViewController:viewController];
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
