//
//  ZWBaseCommentsViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/29.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWRSCommentsViewController.h"
#import "ZWHUDTool.h"
#import "ZWUserDetailViewController.h"
#import "ZWFeedDetailViewController.h"
#import "ZWFeedComposeViewController.h"


static NSString *const kUserCommentsReceivedIdentifier = @"kUserCommentsReceivedIdentifier";
static NSString *const kUserCommentsSentIdentifier = @"kUserCommentsSentIdentifier";

@interface ZWRSCommentsViewController ()

/**
 评论数组
 */
@property (nonatomic, strong) NSMutableArray *comments;

@property (nonatomic, strong) NSString *nextPageUrl;

@end

@implementation ZWRSCommentsViewController

- initWithUserCommentsType:(ZWUserCommentsType)userCommentsType {
    if (self = [super init]) {
        self.userCommentsType = userCommentsType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.comments = [NSMutableArray array];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 74, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    if (_userCommentsType == ZWUserCommentsTypeReceived) {
        [self.tableView registerClass:[ZWReceivedCommentCell class] forCellReuseIdentifier:kUserCommentsReceivedIdentifier];
    } else {
        [self.tableView registerClass:[ZWSentCommentCell class] forCellReuseIdentifier:kUserCommentsSentIdentifier];
    }
    
    self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooterStartRefreshing)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Loading

#pragma mark - Common Methods

- (void)freshHeaderStartFreshing {
    __weak __typeof(self) weakSelf = self;
    if (_userCommentsType == ZWUserCommentsTypeReceived) {
        [[UMComDataRequestManager defaultManager] fetchCommentsUserReceivedWithCount:kStudentCircleFetchDataCount
                                                                          completion:^(NSDictionary *responseObject, NSError *error) {
                                                                              [weakSelf dealWithFetchFeedResult:responseObject error:error fromHeader:YES];
                                                                          }];
    } else {
        [[UMComDataRequestManager defaultManager] fetchCommentsUserSentWithCount:kStudentCircleFetchDataCount
                                                                      completion:^(NSDictionary *responseObject, NSError *error) {
                                                                          [weakSelf dealWithFetchFeedResult:responseObject error:error fromHeader:YES];
                                                                      }];
    }

}

- (void)refreshFooterStartRefreshing {
    if (!self.nextPageUrl) {
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"没有更多了" message:nil duration:kShowHUDShort];
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    __weak __typeof(self) weakSelf = self;
    UMComPageRequestType type = self.userCommentsType == ZWUserCommentsTypeReceived ? UMComRequestType_UserReceiveComment : UMComRequestType_UserSendComment;
    [[UMComDataRequestManager defaultManager] fetchNextPageWithNextPageUrl:self.nextPageUrl
                                                           pageRequestType:type
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
            [self.comments removeAllObjects];
        }
        [self.comments addObjectsFromArray:[responseObject objectForKey:@"data"]];
        [self.tableView reloadData];
        self.nextPageUrl = responseObject[@"next_page_url"];
        if (isFromeHeader) {
            if (self.tableView.cellsTotalHeight < kScreenH - 64 - 40) {
                self.tableView.mj_footer.hidden = YES;
            } else {
                self.tableView.mj_footer.hidden = NO;
            }
        }
    } else {
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"出现错误，获取失败" message:nil duration:kShowHUDMid];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWRSCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:_userCommentsType == ZWUserCommentsTypeReceived ? kUserCommentsReceivedIdentifier : kUserCommentsSentIdentifier];
    cell.comment = self.comments[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = self.comments[indexPath.row];
    Class clazz = _userCommentsType == ZWUserCommentsTypeReceived ? [ZWReceivedCommentCell class] : [ZWSentCommentCell class];
    return [tableView cellHeightForIndexPath:indexPath model:model keyPath:@"comment" cellClass:clazz contentViewWidth:kScreenW];
}

#pragma mark - ZWRSCommentCellDelegate

- (void)cell:(ZWRSCommentCell *)cell didClickToUser:(UMComUser *)user {
    ZWUserDetailViewController *userDetailViewController = [[ZWUserDetailViewController alloc] init];
    userDetailViewController.umUser = user;
    [self.navigationController pushViewController:userDetailViewController animated:YES];
}

- (void)cell:(ZWRSCommentCell *)cell didClickReplyComment:(UMComComment *)comment {
    
}

- (void)cell:(ZWRSCommentCell *)cell didClickReplyFeed:(UMComFeed *)feed {
    ZWFeedDetailViewController *feedDetailViewController = [[ZWFeedDetailViewController alloc] init];
    feedDetailViewController.feed = feed;
    [self.navigationController pushViewController:feedDetailViewController animated:YES];
}

- (void)cell:(ZWRSCommentCell *)cell didClickCommentButton:(UMComComment *)comment {
    ZWFeedComposeViewController *composeViewController = [[ZWFeedComposeViewController alloc] init];
    composeViewController.composeType = ZWFeedComposeTypeReplyComment;
    composeViewController.replyFeedID = comment.feed.feedID;
    composeViewController.replyCommentID = comment.commentID;
    composeViewController.replyUserID = comment.creator.uid;
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:navc animated:YES completion:nil];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
