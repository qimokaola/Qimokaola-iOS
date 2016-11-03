//
//  ZWUserDetailViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/26.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUserDetailViewController.h"
#import "ZWModifyAvatarViewController.h"
#import "ZWHUDTool.h"
#import "ZWAPIRequestTool.h"
#import "ZWUser.h"
#import "ZWFeedTableViewController.h"

#import "ZWUserManager.h"

#import "ZWUMUserFeedCell.h"
#import "ZWAppUserInfoCell.h"
#import "ZWUMUserFeedHeader.h"

#import <SDAutoLayout/SDAutoLayout.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <YYKit/YYKit.h>

#define kUMUserFeedCellIdentifier @"kUMUserFeedCellIdentifier"
#define kAppUserInfoCellIdentifier @"kAppUserInfoCellIdentifier"
#define kUMUserFeedHeaderIdentifier @"kUMUserFeedHeaderIdentifier"

#define kBackgroundViewHeight 252

@interface ZWUserDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *genderView;
@property (nonatomic, strong) UILabel *collegeLabel;
@property (nonatomic, strong) UILabel *academyLabel;
@property (nonatomic, strong) UILabel *titleLabel;

// 需要显示的用户以及用户发送的第一条feed
@property (nonatomic, strong) ZWUser *appUser;
@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, assign) BOOL disappear;

@end
//92, 75, 57
@implementation ZWUserDetailViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar.subviews objectAtIndex:0].alpha = 0.f;
    self.navigationItem.titleView.hidden = YES;
    
    self.disappear = NO;
    
    __weak __typeof(self) weakSelf = self;
    
    [[RACObserve(_tableView, contentOffset) takeUntilBlock:^BOOL(id x) {
        return self.disappear;
    } ] subscribeNext:^(NSNumber *offset) {
        CGFloat yOffset = offset.CGPointValue.y;
        if (yOffset > 0) {
            weakSelf.navigationController.navigationBar.subviews[0].alpha = weakSelf.navigationItem.titleView.alpha = yOffset < 64. ? yOffset / 64. : 1.0;
            if (weakSelf.navigationItem.titleView.hidden) {
                weakSelf.navigationItem.titleView.hidden = NO;
            }
            
        } else {
            weakSelf.navigationController.navigationBar.subviews[0].alpha = self.navigationItem.titleView.alpha = 0.0;
        }
        weakSelf.backgroundView.height = kBackgroundViewHeight - yOffset;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar.subviews objectAtIndex:0].alpha = 1.0f;
    
    self.disappear = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationItem.titleView.alpha = 0.5f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) weakSelf = self;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.backgroundColor = defaultBackgroundColor;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"个人资料";
    titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    [self zw_addSubViews];
    
    MBProgressHUD *hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:nil];

    RACSignal *appUserSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [ZWAPIRequestTool reuqestInfoByName:self.umUser.name result:^(id response, BOOL success) {
            if (success && [[response objectForKey:kHTTPResponseCodeKey] intValue] == 0) {
                weakSelf.appUser = [ZWUser modelWithDictionary:[response objectForKey:kHTTPResponseResKey]];
                NSLog(@"获取App成功");
                [subscriber sendCompleted];
            } else {
                NSLog(@"获取App失败");
                [subscriber sendError:response];
            }
        }];
        return nil;
    }];
    
    RACSignal *feedSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[UMComDataRequestManager defaultManager] fetchFeedsTimelineWithUid:self.umUser.uid
                                                                   sortType:UMComUserTimeLineFeedType_Default
                                                                      count:1
                                                                 completion:^(NSDictionary *responseObject, NSError *error) {
                                                                     if (responseObject) {
                                                                         weakSelf.feed = [(NSArray *)responseObject[@"data"] objectAtIndex:0];
                                                                         NSLog(@"获取UM成功");
                                                                         NSLog(@"%@, %@", responseObject, weakSelf.feed);
                                                                         [subscriber sendCompleted];
                                                                     } else {
                                                                         NSLog(@"获取UM失败");
                                                                         [subscriber sendError:error];
                                                                     }
                                                                 }];
        return nil;
    }];
    
    [[RACSignal merge:@[appUserSignal, feedSignal]] subscribeError:^(NSError *error) {
        [weakSelf dismissHUDAndPop];
    } completed:^{
        if (hud) {
            [hud hideAnimated:YES];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.avatarView setImageURL:[NSURL URLWithString:[[[ZWAPITool base] stringByAppendingString:@"/"] stringByAppendingString:weakSelf.appUser.avatar_url]]];
        weakSelf.collegeLabel.text = weakSelf.appUser.collegeName;
        weakSelf.academyLabel.text = weakSelf.appUser.academyName;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Views

- (void)zw_addSubViews {
    [self initBackgroundView];
    [self initTableView];
    [self initTableHeaderView];
}

- (void)initBackgroundView {
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kBackgroundViewHeight)];
    _backgroundView.backgroundColor = defaultBlueColor;
    [self.view addSubview:_backgroundView];
}

- (void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ZWUMUserFeedCell" bundle:nil] forCellReuseIdentifier:kUMUserFeedCellIdentifier];
    [_tableView registerNib:[UINib nibWithNibName:@"ZWAppUserInfoCell" bundle:nil] forCellReuseIdentifier:kAppUserInfoCellIdentifier];
    [_tableView registerNib:[UINib nibWithNibName:@"ZWUMUserFeedHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:kUMUserFeedHeaderIdentifier];
    [self.view insertSubview:_tableView aboveSubview:_backgroundView];
}

- (void)initTableHeaderView {
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor clearColor];
    _headerView.width = kScreenW;
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.userInteractionEnabled = YES;
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAvatarView)]];
    
    _genderView = [[UIImageView alloc] init];
    _nameLabel = [self commentLabelWithFontSize:16];
    _collegeLabel = [self commentLabelWithFontSize:14];
    _academyLabel = [self commentLabelWithFontSize:14];
    
    NSArray *subViews = @[_avatarView, _genderView, _nameLabel, _genderView, _collegeLabel, _academyLabel];
    [_headerView sd_addSubviews:subViews];
    
    CGFloat margin = 10;
    CGFloat avatarSize = 70.f;
    CGFloat genderSize = 15.f;
    CGFloat labelMaxWidth = 200.f;
    
    _avatarView.sd_layout
    .centerXEqualToView(_headerView)
    .topSpaceToView(_headerView, kNavigationBarHeight + margin)
    .heightIs(avatarSize)
    .widthEqualToHeight();
    _avatarView.sd_cornerRadiusFromHeightRatio = @0.5;
    
    _nameLabel.sd_layout
    .centerXEqualToView(_headerView)
    .topSpaceToView(_avatarView, margin)
    .heightIs(18);
    [_nameLabel setSingleLineAutoResizeWithMaxWidth:labelMaxWidth];
    
    _genderView.sd_layout
    .leftSpaceToView(_nameLabel, margin)
    .centerYEqualToView(_nameLabel)
    .heightIs(genderSize)
    .widthEqualToHeight();
    _genderView.sd_cornerRadiusFromHeightRatio = @0.5;
    
    _collegeLabel.sd_layout
    .centerXEqualToView(_headerView)
    .topSpaceToView(_nameLabel, margin * 2)
    .heightIs(15);
    [_collegeLabel setSingleLineAutoResizeWithMaxWidth:labelMaxWidth];
    
    _academyLabel.sd_layout
    .centerXEqualToView(_headerView)
    .topSpaceToView(_collegeLabel, margin)
    .heightIs(15);
    [_academyLabel setSingleLineAutoResizeWithMaxWidth:labelMaxWidth];
    
    [_headerView setupAutoHeightWithBottomView:_academyLabel bottomMargin:margin * 2];
    
    _genderView.image = [UIImage imageNamed:_umUser.gender.intValue == 0 ? @"icon_gender_female" : @"icon_gender_male"];
    _nameLabel.text = self.umUser.name;
    _collegeLabel.text = @"...";
    _academyLabel.text = @"...";
    
    [_headerView layoutSubviews];
    _tableView.tableHeaderView = _headerView;
    
}

- (UILabel *)commentLabelWithFontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.font = ZWFont(fontSize);
    label.textColor = [UIColor whiteColor];
    return label;
}

- (void)tapToAvatarView {
    ZWModifyAvatarViewController *avatarViewController = [[ZWModifyAvatarViewController alloc] init];
    avatarViewController.avatarViewType = [self.umUser.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid] ? ZWAvatarViewControllerTypeSelf : ZWAvatarViewControllerTypeOthers;
    avatarViewController.avatarUrl = self.umUser.icon_url.large_url_string;
    [self.navigationController pushViewController:avatarViewController animated:YES];
}

#pragma mark - Setters and Getters



#pragma mark - Common Methods

- (void)dismissHUDAndPop {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.navigationController.view];
    if (hud) {
        [hud hideAnimated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ZWUMUserFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:kUMUserFeedCellIdentifier];
        if (!self.feed) {
            cell.contentLabel.text = self.appUser ? @"\n空空如也..." : nil;
            cell.timeLabel.text = nil;
        } else {
            if (DecodeAnonyousCode(self.feed.custom) || [self.umUser.source_uid isEqualToString:[ZWUserManager sharedInstance].loginUser.uid]) {
                cell.contentLabel.text= self.feed.text;
                cell.timeLabel.text = self.feed.create_time;
            } else {
                cell.contentLabel.text = @"\n点击以查看该用户的详细动态";
                cell.timeLabel.text = nil;
            }
        }
        return cell;
    } else {
        ZWAppUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kAppUserInfoCellIdentifier];
        cell.nicknameLabel.text = self.appUser.nickname;
        cell.schoolLabel.text = self.appUser.collegeName;
        cell.academyLabel.text = self.appUser.academyName;
        cell.enterYearLabel.text = self.appUser.enterYear;
        cell.genderLabel.text = self.appUser.gender;
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 100;
    } else {
        return 155;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ZWUMUserFeedHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kUMUserFeedHeaderIdentifier];
    if (section == 0) {
        header.typeImageView.image = [UIImage imageNamed:@"icon_personal_feed"];
        header.typeLabel.text = @"个人动态";
    } else {
        header.typeImageView.image = [UIImage imageNamed:@"icon_personal_info"];
        header.typeLabel.text = @"个人信息";
    }
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (!self.feed) {
            return;
        }
        ZWFeedTableViewController *feedListController = [[ZWFeedTableViewController alloc] init];
        feedListController.feedType = [self.umUser.source_uid isEqualToString:[ZWUserManager sharedInstance].loginUser.uid] ? ZWFeedTableViewTypeAboutUser : ZWFeedTableViewTypeAboutOthers;
        feedListController.user = self.umUser;
        [self.navigationController pushViewController:feedListController animated:YES];
    }
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
