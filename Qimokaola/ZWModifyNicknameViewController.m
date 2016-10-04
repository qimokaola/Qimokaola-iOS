//
//  ZWModifyNicknameViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/17.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWModifyNicknameViewController.h"
#import "ZWHUDTool.h"
#import "ZWUserManager.h"

#import <UMCommunitySDK/UMComDataRequestManager.h>

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface ZWModifyNicknameViewController ()

@property (nonatomic, strong) UITextField *nicknameField;

@end

@implementation ZWModifyNicknameViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"昵称";
    self.view.backgroundColor = defaultBackgroundColor;
    [self zw_addSubViews];
    
    UIBarButtonItem *leftCancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancleModification)];
    self.navigationItem.leftBarButtonItem = leftCancelItem;
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    saveButton.frame = CGRectMake(0, 0, 40, 40);
    saveButton.titleLabel.font =ZWFont(17);
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    @weakify(self)
    RAC(saveButton, enabled) = [_nicknameField.rac_textSignal map:^id(NSString *value) {
        return @(value.length > 0 && ![value isEqualToString:[ZWUserManager sharedInstance].loginUser.nickname]);
    }];
    [[saveButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       @strongify(self)
        [self saveModification];
    }];
    UIBarButtonItem *rightSavaItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = rightSavaItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    [_nicknameField endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Commom Methods

- (void)zw_addSubViews {
    CGFloat nicknameFieldHeight = 40.f;
    _nicknameField = [[UITextField alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight + 15, kScreenWidth, nicknameFieldHeight)];
    _nicknameField.borderStyle = UITextBorderStyleNone;
    _nicknameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nicknameField.text = [ZWUserManager sharedInstance].loginUser.nickname;
    _nicknameField.backgroundColor = [UIColor whiteColor];
    _nicknameField.font = ZWFont(16);
    _nicknameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, nicknameFieldHeight)];
    _nicknameField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_nicknameField];
    
    [_nicknameField becomeFirstResponder];
}

- (void)cancleModification {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveModification {
    [_nicknameField endEditing:YES];
    __weak __typeof(self) weakSelf = self;
    MBProgressHUD *hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:@"正在修改"];
    [[ZWUserManager sharedInstance] modifyUserNickname:_nicknameField.text result:^(id response, BOOL success) {
        NSLog(@"%@", response);
        if (success) {
            if ([[response objectForKey:kHTTPResponseCodeKey] intValue] == 0) {
                [hud hideAnimated:YES];
                // 重新设置用户昵称
                [[ZWUserManager sharedInstance] updateNickname:weakSelf.nicknameField.text];
                ZWUser *user = [ZWUserManager sharedInstance].loginUser;
                [[UMComDataRequestManager defaultManager] updateProfileWithName:user.nickname
                                                                            age:0
                                                                         gender:[user.gender isEqualToString:@"男"] ? @1 : @0
                                                                         custom:user.collegeName
                                                                   userNameType:userNameNoRestrict
                                                                 userNameLength:userNameLengthNoRestrict
                                                                     completion:^(NSDictionary *responseObject, NSError *error) {
                                                                         
                                                                     }];
                if (_completion) {
                    _completion();
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                hud.mode = MBProgressHUDModeText;
                hud.label.text  = @"修改用户信息失败";
                [hud hideAnimated:YES afterDelay:kShowHUDMid];
            }
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"修改失败";
            hud.detailsLabel.text = @"请稍后再试";
            [hud hideAnimated:YES afterDelay:kShowHUDMid];
        }
    }];
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
