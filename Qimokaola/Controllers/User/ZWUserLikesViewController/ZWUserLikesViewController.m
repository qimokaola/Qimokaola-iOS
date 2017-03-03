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

static NSString *const kUserLikesCellIdentifier = @"kUserLikesCellIdentifier";

@interface ZWUserLikesViewController () <ZWLikeCellDelegate>

@property (nonatomic, strong) NSMutableArray *likes;

@property (nonatomic, strong) NSString *nextPageUrl;

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

    self.title = @"赞";
    
    self.likes = [NSMutableArray array];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    [self.tableView registerClass:[ZWLikeCell class] forCellReuseIdentifier:kUserLikesCellIdentifier];
    
    self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooterStartRefreshing)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters and Setters

#pragma mark - Common Methods

- (void)freshHeaderStartFreshing {
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] fetchLikesUserReceivedWithCount:kStudentCircleFetchDataCount
                                                                   completion:^(NSDictionary *responseObject, NSError *error) {
                                                                       [weakSelf dealWithFetchFeedResult:responseObject error:error fromHeader:YES];
                                                                   }];
}

- (void)refreshFooterStartRefreshing {
    if (!self.nextPageUrl) {
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"没有更多了" message:nil duration:kShowHUDShort];
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] fetchNextPageWithNextPageUrl:self.nextPageUrl
                                                           pageRequestType:UMComRequestType_UserReceiveLike
                                                                completion:^(NSDictionary *responseObject, NSError *error) {
                                                                    [weakSelf dealWithFetchFeedResult:responseObject error:error fromHeader:NO];
                                                                }];
}

/**
 处理获取来的数据

 @param responseObject 响应对象
 @param error          错误
 @param isFromeHeader  是否来自头部刷新控件
 */
- (void)dealWithFetchFeedResult:(NSDictionary *)responseObject error:(NSError *)error fromHeader:(BOOL)isFromeHeader {
    if (isFromeHeader) {
        [self.tableView.mj_header endRefreshing];
    } else {
        [self.tableView.mj_footer endRefreshing];
    }
    if (responseObject) {
        if (isFromeHeader) {
            [self.likes removeAllObjects];
        }
        [self.likes addObjectsFromArray:[responseObject objectForKey:@"data"]];
        [self.tableView reloadData];
        self.nextPageUrl = responseObject[@"next_page_url"];
        if (isFromeHeader) {
            if (self.tableView.cellsTotalHeight < kScreenH - 64) {
                self.tableView.mj_footer.hidden = YES;
            } else {
                self.tableView.mj_footer.hidden = NO;
            }
        }
    } else {
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"出现错误，获取失败" message:nil duration:kShowHUDMid];
    }
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
    userDetailViewController.umUser = user;
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
