//
//  ZWCountDownHolderViewController.m
//  Qimokaola
//
//  Created by Administrator on 2017/2/19.
//  Copyright © 2017年 Administrator. All rights reserved.
//

#import "ZWCountDownHolderViewController.h"

#import "ZWCountDownListViewController.h"

@interface ZWCountDownHolderViewController ()

@end

@implementation ZWCountDownHolderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (NSString *)nibName {
    return NSStringFromClass([self class]);
}

- (IBAction)showCountDownList:(id)sender {
    ZWCountDownListViewController *controller = [[ZWCountDownListViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
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
