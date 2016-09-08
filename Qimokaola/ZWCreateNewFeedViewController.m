//
//  ZWNewFeedViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/9/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWCreateNewFeedViewController.h"
#import <UMCommunitySDK/UMComDataRequestManager.h>

@interface ZWCreateNewFeedViewController ()

@property (nonatomic, strong) UITextField *feedField;

@end

@implementation ZWCreateNewFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createSubViews];
    
    UIBarButtonItem *leftCancleItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(canclePostNewFeed)];
    self.navigationItem.leftBarButtonItem = leftCancleItem;
    UIBarButtonItem *rightPostItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(postNewFeed)];
    self.navigationItem.rightBarButtonItem = rightPostItem;
}

- (void)canclePostNewFeed {
    
    if (_feedField.text.length == 0) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        return;
    }
    
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
    [UMComDataRequestManager feedCreateWithContent:_feedField.text
                                             title:nil
                                          location:nil
                                      locationName:nil
                                      related_uids:nil
                                         topic_ids:@[self.topicID]
                                            images:nil
                                              type:@0
                                            custom:@"测试一下自带字符"
                                        completion:^(NSDictionary *responseObject, NSError *error) {
                                            
                                            NSLog(@"%@ %@", responseObject, error);
                                           
                                            if (responseObject) {
                                                
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                                
                                            }
                                            
                                        }];
}

- (void)createSubViews {
    CGRect frame = self.view.frame;
    frame.origin.y += kNavigationBarHeight;
    frame.size.height -= kNavigationBarHeight;
    _feedField = [[UITextField alloc] initWithFrame:frame];
    _feedField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [self.view addSubview:_feedField];
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
