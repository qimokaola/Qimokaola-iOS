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

@interface ZWTabBarController ()

@property (strong, nonatomic) NSArray *viewControllersInfo;

@end

@implementation ZWTabBarController

- (NSArray *)viewControllersInfo {
    if (_viewControllersInfo == nil) {
        _viewControllersInfo = @[
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
    
    self.tabBar.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray<UIViewController *> *viewControllers = [NSMutableArray array];
    for (NSDictionary *dict in self.viewControllersInfo) {
        Class clazz = dict[@"class"];
        ZWNavigationController *nav = [[ZWNavigationController alloc] initWithRootViewController:[[clazz alloc] init] tabBarItemComponents:@[dict[@"title"], dict[@"image"]]];
        [viewControllers addObject:nav];
    }
    
    self.viewControllers = viewControllers;
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
