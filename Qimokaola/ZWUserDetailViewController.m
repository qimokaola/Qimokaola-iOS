//
//  ZWUserDetailViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/26.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUserDetailViewController.h"

#import <SDAutoLayout/SDAutoLayout.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

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

@end
//92, 75, 57
@implementation ZWUserDetailViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar.subviews objectAtIndex:0].alpha = 0.f;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar.subviews objectAtIndex:0].alpha = 1.0f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) weakSelf = self;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"个人资料";
    titleLabel.font =ZWFont(17);
    titleLabel.textColor = [UIColor blackColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    self.navigationItem.titleView.alpha = 0.0;
    
    [self zw_addSubViews];
    
    [RACObserve(_tableView, contentOffset) subscribeNext:^(NSNumber *offset) {
        NSLog(@"%@", offset);
        CGFloat yOffset = offset.CGPointValue.y;
        if (yOffset > 0) {
            // 64 + 10
            if (yOffset > 74) {
                // 74 + 64
                weakSelf.navigationController.navigationBar.subviews[0].alpha = weakSelf.navigationItem.titleView.alpha = yOffset < 138 ? (yOffset - 74) / 64. : 1.0;
            } else {
                weakSelf.navigationController.navigationBar.subviews[0].alpha = self.navigationItem.titleView.alpha = 0.0;
            }
        }
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
    _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = RGB(92., 75., 57.);
    [self.view addSubview:_backgroundView];
}

- (void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view insertSubview:_tableView aboveSubview:_backgroundView];
}

- (void)initTableHeaderView {
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor clearColor];
    _headerView.width = kScreenW;
    
    _avatarView = [[UIImageView alloc] init];
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
    
    
    _avatarView.image = [UIImage imageNamed:@"avatar"];
    _genderView.image = [UIImage imageNamed:_user.gender.intValue == 0 ? @"icon_female" : @"icon_male"];
    _nameLabel.text = @"我是凌子文";
    _collegeLabel.text = @"福州大学";
    _academyLabel.text = @"数学与计算机科学学院";
    
    [_headerView layoutSubviews];
    _tableView.tableHeaderView = _headerView;
    
}

- (UILabel *)commentLabelWithFontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.font = ZWFont(fontSize);
    label.textColor = [UIColor whiteColor];
    return label;
}

#pragma mark - Setters and Getters

- (void)setUser:(UMComUser *)user {
    _user = user;
    
    
}

#pragma mark - Common Methods

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
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
