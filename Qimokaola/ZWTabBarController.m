//
//  ZWMainViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/8/11.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWTabBarController.h"
#import "ZWNavigationController.h"
#import "ZWRootPathViewController.h"
#import "ZWDownloadedViewController.h"
#import "ZWStudentCircleViewController.h"
#import "ZWDiscoveryViewController.h"
#import "ZWAPIRequestTool.h"
#import "ZWHUDTool.h"
#import "ZWLoginViewController.h"
#import "ZWUserManager.h"
#import "ZWCourseViewController.h"
#import "ZWFeedComposeViewController.h"

#import "ReactiveCocoa.h"


@interface ZWTabBarController ()

@property (strong, nonatomic) NSArray *viewControllersInfo;

@end

@implementation ZWTabBarController

- (NSArray *)viewControllersInfo {
    if (_viewControllersInfo == nil) {
        _viewControllersInfo = @[
                                 @{@"class" : [ZWCourseViewController class], @"title" : @"资源", @"image" : @"resource"},
                                 @{@"class" : [ZWRootPathViewController class], @"title" : @"资源", @"image" : @"resource"},
                                 @{@"class" : [ZWDownloadedViewController class], @"title" : @"已下载", @"image" : @"user"},
                                 @{@"class" : [ZWStudentCircleViewController class], @"title" : @"学生圈", @"image" : @"extra"},
                                 @{@"class" : [ZWDiscoveryViewController class], @"title" : @"发现", @"image" : @"user"},
                                 ];
    }
    return _viewControllersInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.barTintColor = [UIColor whiteColor];
    
    NSMutableArray<UIViewController *> *viewControllers = [NSMutableArray array];
    for (NSDictionary *dict in self.viewControllersInfo) {
        Class clazz = dict[@"class"];
        ZWNavigationController *nav = [[ZWNavigationController alloc] initWithRootViewController:[[clazz alloc] init] tabBarItemComponents:@[dict[@"title"], dict[@"image"]]];
        [viewControllers addObject:nav];
    }
    
    self.viewControllers = viewControllers;
    
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kUserNeedLoginNotification object:nil] deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self)
        [self presentLoginViewController];
        
    }];
}

- (void)presentLoginViewController {
    [ZWHUDTool showHUDWithTitle:@"登录状态失效 请重新登录" message:nil duration:kShowHUDMid];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDMid * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ZWLoginViewController *loginViewController = [[ZWLoginViewController alloc] init];
        loginViewController.completionBlock = ^() {
            NSLog(@"登录成功");
        };
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:loginViewController] animated:YES completion:nil];
    });
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
