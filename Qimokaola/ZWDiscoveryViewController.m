//
//  ZWDiscoveryViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/7/19.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWDiscoveryViewController.h"
#import "ZWAPITool.h"
#import "ZWUserManager.h"

#import "MJRefresh.h"
#import "Masonry.h"
#import "ReactiveCocoa.h"
#import <UMCommunitySDK/UMComDataRequestManager.h>
#import <UMCommunitySDK/UMComSession.h>
#import "YYWebImage.h"


@interface ZWDiscoveryViewController ()

// 头像 用户名等父控件
@property (strong, nonatomic) UIView *userInfoView;

// 头像
@property (strong, nonatomic) UIImageView *avatarImageView;

// 昵称标签
@property (nonatomic, strong) UILabel *nicknameLabel;

// 性别视图
@property (nonatomic, strong) UIImageView *genderView;

// 学校标签
@property (nonatomic, strong) UILabel *schoolLabel;

@property (nonatomic, strong) NSArray *channels;

@end

@implementation ZWDiscoveryViewController

- (NSArray *)channels {
    if (_channels == nil) {
        _channels = @[
                      @{@"icon" : @"radio_button_checked", @"title" : @"我的动态", @"detail" : @"我发的学生圈"},
                      @{@"icon" : @"radio_button_checked", @"title" : @"我的收藏", @"detail" : @"收藏的帖子"},
                      @{@"icon" : @"radio_button_checked", @"title" : @"评论", @"detail" : @"我的评论"},
                      @{@"icon" : @"radio_button_checked", @"title" : @"赞我的", @"detail" : @"你说得好"},
                      @{@"icon" : @"radio_button_checked", @"title" : @"考试倒计时", @"detail" : @"新建倒计时"},
                      @{@"icon" : @"radio_button_checked", @"title" : @"四六级查询", @"detail" : @"免准考号查询"},
                      @{@"icon" : @"radio_button_checked", @"title" : @"加入我们", @"detail" : @"版主及校代表"},
                      ];
    }
    return _channels;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) weakSelf = self;
    
    [self createSubViews];
    
    [[UMComDataRequestManager defaultManager] userCustomAccountLoginWithName:@"ABC"
                                                                    sourceId:@"13110691985"
                                                                    icon_url:nil
                                                                      gender:1
                                                                         age:20
                                                                      custom:@"727489038"
                                                                       score:0.f
                                                                  levelTitle:@"102"
                                                                       level:0
                                                           contextDictionary:@{}
                                                                userNameType:userNameNoRestrict
                                                              userNameLength:userNameLengthNoRestrict
                                                                  completion:^(NSDictionary *responseObject, NSError *error) {
                                                                      NSLog(@"登陆成功");
                                                                      if (error) {
                                                                          NSLog(@"登录发生错误 ;%@", error);
                                                                      } else {
                                                                          if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                                              UMComUser *user = responseObject[UMComModelDataKey];
                                                                              if (user) {
                                                                                  
                                                                                  NSLog(@"%@", user.custom);
                                                                                  
                                                                                  [UMComSession sharedInstance].loginUser = user;
                                                                                  [[UMComDataBaseManager shareManager] saveRelatedIDTableWithType:UMComRelatedRegisterUserID withUsers:@[user]];
                                                                                  
                                                                                  //[UMComSession sharedInstance].token = responseObject[UMComTokenKey];
                                                                                  
//                                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginSucceedNotification object:nil];
                                                                              }
                                                                          }
                                                                      }

                                                                      
                                                                  }];
    
    
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    backgroundView.backgroundColor = RGB(239, 239, 244);
    self.tableView.backgroundView = backgroundView;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    self.tableView.tableFooterView = view;
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView.mj_header endRefreshing];
        });
        
    }];
    
    header.backgroundColor = RGB(239, 239, 244);
    self.tableView.mj_header = header;
    
    ZWUser *loginUser = [ZWUserManager sharedInstance].loginUser;
    [self.avatarImageView yy_setImageWithURL:[NSURL URLWithString:[[ZWAPITool base] stringByAppendingPathComponent:loginUser.avatar_url]] placeholder:[UIImage imageNamed:@"avatar"]];
    self.nicknameLabel.text  = loginUser.nickname;
    //self.schoolLabel.text = loginUser.collegeId;
    NSString *genderImageName = [loginUser.gender isEqualToString:@"男生"] ? @"icon_male" : @"icon_female";
    self.genderView.image = [UIImage imageNamed:genderImageName];
}

- (void)createSubViews {
    __weak __typeof(self) weakSelf = self;
    
    CGFloat sizeRate = 0.7;
    CGFloat marginRate = (1. - sizeRate) / 2.;
    CGFloat margin = 10;
    CGFloat smallMargin = 5.f;
    
    CGFloat genderViewSize = 20.f;
    
    UIColor *commonBlueColor = RGB(80, 140, 238);
    
    //用户信息View
    self.userInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight * 0.15)];
    self.userInfoView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.userInfoView;
    
    //头像View
    self.avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar"]];
    [self.userInfoView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.equalTo(weakSelf.userInfoView.mas_height).multipliedBy(sizeRate);
        make.centerY.equalTo(weakSelf.userInfoView);
        make.left.offset(weakSelf.userInfoView.frame.size.height * marginRate);
    }];
    [self.avatarImageView layoutIfNeeded];
    CALayer *layer = self.avatarImageView.layer;
    layer.borderColor = commonBlueColor.CGColor;
    layer.borderWidth = 2;
    layer.cornerRadius = CGRectGetWidth(self.avatarImageView.frame) / 2.;
    layer.masksToBounds = YES;
    
    //用户名（昵称）View
    self.nicknameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 1;
        label.textColor = commonBlueColor;
        label.font = [UIFont systemFontOfSize:17];
        [label sizeToFit];
        [self.userInfoView addSubview:label];
        
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(weakSelf.avatarImageView.mas_right).with.offset(margin);
            make.bottom.equalTo(weakSelf.userInfoView.mas_centerY).with.offset(-smallMargin);
        }];
        
        label;
        
    });
    
    self.genderView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.userInfoView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(genderViewSize, genderViewSize));
            make.centerY.equalTo(weakSelf.nicknameLabel);
            make.left.equalTo(weakSelf.nicknameLabel.mas_right).with.offset(smallMargin);
        }];
        
        imageView;
    });
    
    //显示下载币文字标签
    self.schoolLabel = ({
        
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 1;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor lightGrayColor];
        [label sizeToFit];
        [self.userInfoView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.nicknameLabel);
            make.top.equalTo(weakSelf.userInfoView.mas_centerY).with.offset(smallMargin);
        }];
        
        label;
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITabelViewDataSource 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSDictionary *dict = self.channels[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:dict[@"icon"]];
    cell.textLabel.text = dict[@"title"];
    cell.detailTextLabel.text = dict[@"detail"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
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
