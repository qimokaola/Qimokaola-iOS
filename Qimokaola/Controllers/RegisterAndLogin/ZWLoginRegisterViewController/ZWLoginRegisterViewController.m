//
//  ZWLoginRegisterViewController.m
//  Qimokaola
//
//  Created by Administrator on 2017/3/7.
//  Copyright © 2017年 Administrator. All rights reserved.
//

#import "ZWLoginRegisterViewController.h"

@interface ZWLoginRegisterViewController ()


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewLeading;

@end

@implementation ZWLoginRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginRegisterBtnClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    self.loginViewLeading.constant = self.loginViewLeading.constant == 0 ? - kScreenW : 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
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
