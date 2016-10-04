//
//  ZWUserLikesViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/10/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUserLikesViewController.h"
#import "ZWUserDetailViewController.h"
#import "ZWFeedDetailViewController.h"
#import "ZWLikeCell.h"
#import "ZWHUDTool.h"

#import <UMCommunitySDK/UMComDataRequestManager.h>

#import <MJRefresh/MJRefresh.h>
#import <SDAutoLayout/SDAutoLayout.h>

#define kUserLikesCellIdentifier @"kUserLikesCellIdentifier"

@interface ZWUserLikesViewController () <UITableViewDelegate, UITableViewDataSource, ZWLikeCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *likes;

@end

@implementation ZWUserLikesViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = defaultBackgroundColor;
    self.title = @"赞";
    
    self.likes = [NSMutableArray array];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters and Setters

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.contentInset = UIEdgeInsetsMake(64, 0, 10, 0);
        _tableView.scrollIndicatorInsets = _tableView.contentInset;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [_tableView registerClass:[ZWLikeCell class] forCellReuseIdentifier:kUserLikesCellIdentifier];
        
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchUserLikes)];
        _tableView.mj_header = header;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - Common Methods

- (void)fetchUserLikes {
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] fetchLikesUserReceivedWithCount:9999
                                                                   completion:^(NSDictionary *responseObject, NSError *error) {
                                                                       [weakSelf.tableView.mj_header endRefreshing];
                                                                       if (responseObject) {
                                                                           [weakSelf.likes removeAllObjects];
                                                                           [weakSelf.likes addObjectsFromArray:responseObject[@"data"]];
                                                                           [weakSelf.tableView reloadData];
                                                                       } else {
                                                                           [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"获取数据失败" message:nil duration:kShowHUDShort];
                                                                       }
                                                                   }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.likes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWLikeCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserLikesCellIdentifier];
    cell.like = [self.likes objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self.likes objectAtIndex:indexPath.row];
    return [tableView cellHeightForIndexPath:indexPath model:model keyPath:@"like" cellClass:[ZWLikeCell class] contentViewWidth:kScreenW];
}

#pragma mark - ZWLikeCellDelegate

- (void)cell:(ZWLikeCell *)cell didClickFeed:(UMComFeed *)feed {
    ZWFeedDetailViewController *feedDetailViewController = [[ZWFeedDetailViewController alloc] init];
    feedDetailViewController.feed = feed;
    [self.navigationController pushViewController:feedDetailViewController animated:YES];
}

- (void)cell:(ZWLikeCell *)cell didClickUser:(UMComUser *)user {
    ZWUserDetailViewController *userDetailViewController = [[ZWUserDetailViewController alloc] init];
    userDetailViewController.user = user;
    [self.navigationController pushViewController:userDetailViewController animated:YES];
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
