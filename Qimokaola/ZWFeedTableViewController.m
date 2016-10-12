//
//  ZWFeedListViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/8/24.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFeedTableViewController.h"
#import "ZWFeedCell.h"
#import "UIColor+Extension.h"
#import "ZWFeedComposeViewController.h"
#import "ZWHUDTool.h"
#import "ZWUserDetailViewController.h"

#import "ZWFeedDetailViewController.h"
#import "ZWFeedComposeViewController.h"
#import <UMComDataStorage/UMComTopic.h>
#import <UMComDataStorage/UMComFeed.h>
#import <UMComDataStorage/UMComUser.h>
#import <UMComDataStorage/UMComImageUrl.h>
#import <UMComDataStorage/UMComLike.h>
#import <UMCommunitySDK/UMComSession.h>
#import "MJRefresh.h"
#import "SDAutoLayout.h"
#import <YYKit/YYKit.h>
#import <LinqToObjectiveC/LinqToObjectiveC.h>

#define kFeedTableViewCellID @"kFeedTableViewCellID"

@interface ZWFeedTableViewController () <ZWFeedCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<UMComFeed *> *feeds;

@end

@implementation ZWFeedTableViewController

#pragma mark - Initialization Methods

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //设置下级页面的返回键
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    self.feeds = [NSMutableArray array];
    
    if (_feedType == ZWFeedTableViewTypeAboutTopic) {
        self.title = self.topic.name;
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_compose_feed"] style:UIBarButtonItemStylePlain target:self action:@selector(presendNewFeedViewController)];
//        rightItem.tintColor = UIColorHex(fd8224);
        self.navigationItem.rightBarButtonItem = rightItem;
    } else if (_feedType == ZWFeedTableViewTypeAboutUser || _feedType == ZWFeedTableViewTypeAboutOthers) {
        self.title = @"动态";
    } else if (_feedType == ZWFeedTableViewTypeAboutCollection) {
        self.title = @"收藏";
    }

    _tableView = [[UITableView alloc] init];
    _tableView.frame = self.view.bounds;
    _tableView.contentInset = UIEdgeInsetsMake(64, 0, 20, 0);
    _tableView.scrollIndicatorInsets = _tableView.contentInset;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView.backgroundColor = [UIColor clearColor];
    [_tableView registerClass:[ZWFeedCell class] forCellReuseIdentifier:kFeedTableViewCellID];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    self.view.backgroundColor = UIColorHex(f2f2f2);
   // self.view.backgroundColor = universalGrayColor;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchFeedsData)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_tableView.mj_header beginRefreshing];
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"dealloc table list");
}

#pragma mark - Normal Methods

- (void)goToFeedDetail:(UMComFeed *)feed atIndexPath:(NSIndexPath *)indexPath isFromCommentButton:(BOOL)fromCommentButton {
    
    __weak __typeof(self) weakSelf = self;
    ZWFeedDetailViewController *detailViewController = [[ZWFeedDetailViewController alloc] init];
    detailViewController.feed = feed;
    detailViewController.isCommentTextViewNeedFocusWhenInit = fromCommentButton ? feed.comments_count.intValue == 0 : NO;
    detailViewController.deleteCompletion = ^() {
        [weakSelf removeFeed:feed];
    };
    // isLike 为最新点赞情况
    detailViewController.isLikedChangedCompletion = ^(BOOL isLiked) {
        if (isLiked != feed.liked.boolValue) {
            feed.liked = @(isLiked);
            int likeCount = feed.likes_count.intValue;
            feed.likes_count = isLiked ? @(likeCount + 1) : @(likeCount -1);
            [weakSelf.tableView reloadRow:[weakSelf.feeds indexOfObject:feed] inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    detailViewController.isCollectedChangedCompletion = ^(BOOL isCollected) {
        if (isCollected != feed.has_collected.boolValue) {
            feed.has_collected = @(isCollected);
            [weakSelf.tableView reloadRow:[weakSelf.feeds indexOfObject:feed] inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    detailViewController.commentCountChangedCompletion = ^(NSNumber *commentCount) {
        [weakSelf.feeds objectAtIndex:indexPath.row].comments_count = commentCount;
        [weakSelf.tableView reloadRow:[weakSelf.feeds indexOfObject:feed] inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    };
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)fetchFeedsData {
    __weak __typeof(self) weakSelf = self;
    if (self.feedType == ZWFeedTableViewTypeAboutTopic) {
        //获取feed数据
        [[UMComDataRequestManager defaultManager] fetchFeedsTopicRelatedWithTopicId:self.topic.topicID
                                                                           sortType:UMComTopicFeedSortType_default
                                                                          isReverse:NO
                                                                              count:99999
                                                                         completion:^(NSDictionary *responseObject, NSError *error) {
                                                                             
                                                                             [weakSelf dealWithFetchFeedResult:responseObject error:error];
                                                                         }];
    } else if (self.feedType == ZWFeedTableViewTypeAboutUser) {
        // 获取有关于用户的feed流
        [[UMComDataRequestManager defaultManager] fetchFeedsTimelineWithUid:weakSelf.user.uid
                                                                   sortType:UMComUserTimeLineFeedType_Default
                                                                      count:999999
                                                                 completion:^(NSDictionary *responseObject, NSError *error) {
                                                                     [weakSelf dealWithFetchFeedResult:responseObject error:error];
                                                                 }];
        
    } else if (self.feedType == ZWFeedTableViewTypeAboutCollection) {
        // 获取有关于用户收藏的feed流
        [[UMComDataRequestManager defaultManager] fetchFeedsUserFavouriteWithCount:99999
                                                                        completion:^(NSDictionary *responseObject, NSError *error) {
                                                                            [weakSelf dealWithFetchFeedResult:responseObject error:error];
                                                                        }];
    } else if (self.feedType == ZWFeedTableViewTypeAboutOthers) {
        // 获取有关于用户的feed流
        [[UMComDataRequestManager defaultManager] fetchFeedsTimelineWithUid:weakSelf.user.uid
                                                                   sortType:UMComUserTimeLineFeedType_Default
                                                                      count:999999
                                                                 completion:^(NSDictionary *responseObject, NSError *error) {
                                                                     [weakSelf dealWithFetchFeedResult:responseObject error:error];
                                                                 }];
    }

}

- (void)dealWithFetchFeedResult:(NSDictionary *)responseObject error:(NSError *)error {
    [self.tableView.mj_header endRefreshing];
    if (responseObject) {
        [self.feeds removeAllObjects];
        if (self.feedType != ZWFeedTableViewTypeAboutOthers) {
            [self.feeds addObjectsFromArray:[responseObject objectForKey:@"data"]];
        } else {
            [self.feeds addObjectsFromArray:[[responseObject objectForKey:@"data"] linq_where:^BOOL(UMComFeed *item) {
                return DecodeAnonyousCode(item.custom) == 0;
            }]];
        }
        [self.tableView reloadData];
    } else {
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"出错了，获取失败" message:nil duration:kShowHUDMid];
    }
}

- (void)presendNewFeedViewController {
    __weak __typeof(self) weakSelf = self;
    ZWFeedComposeViewController *createNewFeedViewController = [[ZWFeedComposeViewController alloc] init];
    createNewFeedViewController.topicID = self.topic.topicID;
    createNewFeedViewController.composeType = ZWFeedComposeTypeNewFeed;
    createNewFeedViewController.completion = ^(UMComFeed *newFeed) {
        [weakSelf.feeds insertObject:newFeed atIndex:0];
        [weakSelf.tableView insertRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationTop];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:createNewFeedViewController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)removeFeed:(UMComFeed *)feed {
    NSInteger index = [self.feeds indexOfObject:feed];
    [self.feeds removeObjectAtIndex:index];
    [self.tableView deleteRow:index inSection:0 withRowAnimation:UITableViewRowAnimationFade];
}

- (void)dealWiteSpamResult:(NSDictionary *)responseObject error:(NSError *)error {
    NSString *content = nil;
    if (responseObject) {
        content = @"举报成功";
    } else {
        if (error.code == 40002) {
            content = @"该用户或内容已被举报";
        } else {
            content = @"出错了，举报失败";
        }
    }
    [ZWHUDTool showHUDInView:self.navigationController.view
                   withTitle:content
                     message:nil
                    duration:kShowHUDMid];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:kFeedTableViewCellID];
    UMComFeed *feed = [self.feeds objectAtIndex:indexPath.row];
    cell.feed = feed;
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self.feeds objectAtIndex:indexPath.row];
    return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"feed" cellClass:[ZWFeedCell class] contentViewWidth:kScreenWidth];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
   
    [self goToFeedDetail:[self.feeds objectAtIndex:indexPath.row] atIndexPath:indexPath isFromCommentButton:NO];
}

#pragma mark - ZWFeedCellDelegate

// 点赞
- (void)cell:(ZWFeedCell *)cell didClickLikeButtonInLikeState:(BOOL)isLiked atIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] feedLikeWithFeedID:cell.feed.feedID
                                                          isLike:!isLiked
                                                      completion:^(NSDictionary *responseObject, NSError *error) {
                                                          if (responseObject) {
                                                              cell.feed.liked = @(!isLiked);
                                                              int likeCount = cell.feed.likes_count.intValue;
                                                              cell.feed.likes_count = !isLiked ? @(likeCount + 1) : @(likeCount - 1);
                                                              [weakSelf.tableView reloadRow:[weakSelf.feeds indexOfObject:cell.feed] inSection:0 withRowAnimation:UITableViewRowAnimationNone];
                                                              
                                                          } else {
                                                              [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"呀,出错了！" message:nil duration:kShowHUDMid];
                                                          }
                                                      }];
    
}

// 收藏
- (void)cell:(ZWFeedCell *)cell didClickCollectButtonInCollectState:(BOOL)isCollected atIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] feedFavouriteWithFeedId:cell.feed.feedID
                                                          isFavourite:!isCollected
                                                      completionBlock:^(NSDictionary *responseObject, NSError *error) {
                                                          if (!error) {
                                                              cell.feed.has_collected = @(!isCollected);
                                                              [weakSelf.tableView reloadRow:[weakSelf.feeds indexOfObject:cell.feed] inSection:0 withRowAnimation:UITableViewRowAnimationNone];
                                                          } else {
                                                              [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"呀,出错了！" message:nil duration:kShowHUDMid];
                                                          }
                                                      }];
}

// 评论
- (void)cell:(ZWFeedCell *)cell didClickCommentButtonAtIndexPath:(NSIndexPath *)indexPath {
    [self goToFeedDetail:cell.feed atIndexPath:[NSIndexPath indexPathForRow:[self.feeds indexOfObject:cell.feed] inSection:0] isFromCommentButton:YES];
}

// 点击用户
- (void)cell:(ZWFeedCell *)cell didClickUser:(UMComUser *)user atIndexPath:(NSIndexPath *)indexPath {
    ZWUserDetailViewController *userDetailViewController = [[ZWUserDetailViewController alloc] init];
    userDetailViewController.umUser = user;
    [self.navigationController pushViewController:userDetailViewController animated:YES];
}

// 点击右上更多按钮
- (void)cell:(ZWFeedCell *)cell didClickMoreButtonAtIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([cell.feed.creator.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid]) {
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UMComDataRequestManager defaultManager] feedDeleteWithFeedID:cell.feed.feedID
                                                                completion:^(NSDictionary *responseObject, NSError *error) {
                                                                    if (responseObject) {
                                                                        [weakSelf removeFeed:cell.feed];
                                                                    } else {
                                                                        [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"出错了，删除失败"  message:nil duration:kShowHUDMid];
                                                                    }
                                                                }];
        }];
        [alertController addAction:deleteAction];
    } else {
        UIAlertAction *reportUserAction = [UIAlertAction actionWithTitle:@"举报用户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UMComDataRequestManager defaultManager] userSpamWitUID:cell.feed.creator.uid
                                                          completion:^(NSDictionary *responseObject, NSError *error) {
                                                              [weakSelf dealWiteSpamResult:responseObject error:error];
                                                          }];
        }];
        UIAlertAction *reportConentAction = [UIAlertAction actionWithTitle:@"举报内容" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UMComDataRequestManager defaultManager] feedSpamWithFeedID:cell.feed.feedID
                                                              completion:^(NSDictionary *responseObject, NSError *error) {
                                                                  [weakSelf dealWiteSpamResult:responseObject error:error];
                                                              }];
        }];
        [alertController addAction:reportUserAction];
        [alertController addAction:reportConentAction];
    }
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [pasteBoard setString:cell.feed.text];
        [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"已复制内容至剪贴板" message:nil duration:kShowHUDMid];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancleAction];
    [alertController addAction:copyAction];
    [self presentViewController:alertController animated:YES completion:nil];
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
