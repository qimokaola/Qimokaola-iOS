//
//  ZWNewFeedViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/9/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFeedComposeViewController.h"
#import "ZWFeedComposeTextParser.h"
#import "UIView+Extension.h"
#import "WBTextLinePositionModifier.h"
#import "WBStatusHelper.h"
#import "WBEmoticonInputView.h"

#import "IQKeyboardManager.h"
#import <YYKit/YYKit.h>

@import YangMingShan;

#define kToolbarHeight 46

@interface ZWFeedComposeViewController ()

@end

@implementation ZWFeedComposeViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UIBarButtonItem *leftCancleItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(canclePostNewFeed)];
    self.navigationItem.leftBarButtonItem = leftCancleItem;
    UIBarButtonItem *rightPostItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(postNewFeed)];
    self.navigationItem.rightBarButtonItem = rightPostItem;
    
    if (self.composeType == ZWFeedComposeTypeNewFeed) {
        self.title = @"新鲜事";
    } else {
        self.title = @"发评论";
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
     [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
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

#pragma mark - Lazy Loading


#pragma mark - Common Methods

- (void)canclePostNewFeed {
    __weak __typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"取消编辑？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmCancle = [UIAlertAction actionWithTitle:@"确认取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *continueEditing = [UIAlertAction actionWithTitle:@"继续编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:confirmCancle];
    [alertController addAction:continueEditing];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 @param content Feed的内容
 @param title 标题
 @param location 位置
 @param locationName 地理位置名称
 @param related_uids @用户
 @param topic_ids 话题ID数组
 @param images 图片数组
 @param type 类型（0表示普通，1表示公告，只有管理员才有权限发表公告）
 @param custom 自定义字段
 @param completion 请求回调block，参考 'UMComRequestCompletion'
 @return 返回空
 */
- (void)postNewFeed {
}


@end
