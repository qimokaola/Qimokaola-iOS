//
//  ZWMineViewController.m
//  Qimokaola
//
//  Created by Administrator on 2017/3/2.
//  Copyright © 2017年 Administrator. All rights reserved.
//

#import "ZWMineViewController.h"

#import "ZWAPITool.h"
#import "ZWUserManager.h"
#import "ZWHUDTool.h"
#import "ZWBrowserTool.h"

#import "ZWCountDownListViewController.h"
#import "ZWFeedTableViewController.h"
#import "ZWUserCommentsViewController.h"
#import "ZWUserLikesViewController.h"
#import "ZWUserInfoViewController.h"
#import "ZWMineHeaderView.h"

#import "ZWAccount.h"

#import <UMCommunitySDK/UMComSession.h>
#import "MJRefresh.h"
#import "Masonry.h"
#import "ReactiveCocoa.h"
#import <YYKit/YYKit.h>

@interface ZWMineViewController ()

@property (nonatomic, strong) ZWMineHeaderView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UITableViewCell *commentCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *favoriteCell;

@end

@implementation ZWMineViewController

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    return (ZWMineViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ZWMineViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.tableHeaderView = self.tableHeaderView;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchData)];
    self.tableView.mj_header = header;
    
    __weak __typeof(self) weakSelf = self;
    [RACObserve([ZWUserManager sharedInstance], unreadCommentCount) subscribeNext:^(id x) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.isViewLoaded) {
            [strongSelf updateTableViewCell:strongSelf.commentCell forCount:[x integerValue]];
        }
    }];
    
    [RACObserve([ZWUserManager sharedInstance], unreadLikeCount) subscribeNext:^(id x) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.isViewLoaded) {
            [strongSelf updateTableViewCell:strongSelf.favoriteCell forCount:[x integerValue]];
        }
    }];
}

- (ZWMineHeaderView *)tableHeaderView {
    if (_tableHeaderView == nil) {
        _tableHeaderView = [ZWMineHeaderView mineHeaderViewInstance];
        _tableHeaderView.userInteractionEnabled = YES;
        [_tableHeaderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedTableHeaderView)]];
        _tableHeaderView.user = [ZWUserManager sharedInstance].loginUser;
    }
    return _tableHeaderView;
}

- (void)updateTableViewCell:(UITableViewCell *)cell forCount:(NSUInteger)count
{
    // Count > 0, show count
    if (count > 0) {
        
        // Create label
        CGFloat fontSize = 13;
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:fontSize];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor redColor];
        
        // Add count to label and size to fit
        label.text = [NSString stringWithFormat:@"%@", @(count)];
        [label sizeToFit];
        
        // Adjust frame to be square for single digits or elliptical for numbers > 9
        CGRect frame = label.frame;
        frame.size.height += (int)(0.2*fontSize);
        frame.size.width = (count <= 9) ? frame.size.height : frame.size.width + (int)fontSize;
        label.frame = frame;
        
        // Set radius and clip to bounds
        label.layer.cornerRadius = frame.size.height/2.0;
        label.clipsToBounds = true;
        
        // Show label in accessory view and remove disclosure
        cell.accessoryView = label;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Count = 0, show disclosure
    else {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 设置header的高度
    self.tableHeaderView.frame = CGRectMake(0, 0, kScreenW, kScreenH * 0.15);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Common Methods

- (void)fetchData {
    __weak __typeof(self) weakSelf = self;
    [ZWAPIRequestTool requestUserInfo:^(id response, BOOL success) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.tableView.mj_header endRefreshing];
        if (success && [[response objectForKey:kHTTPResponseCodeKey] intValue] == 0) {
            ZWUser *user = [ZWUser modelWithDictionary:[response objectForKey:kHTTPResponseResKey]];
            if (user) {
                [ZWUserManager sharedInstance].loginUser = user;
                strongSelf.tableHeaderView.user = user;
            }
        } else {
            [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"出现错误" message:nil duration:kShowHUDMid];
        }
    }];
}

- (void)tappedTableHeaderView {
    ZWUserInfoViewController *userInfoViewController = [[ZWUserInfoViewController alloc] init];
    [self.navigationController pushViewController:userInfoViewController animated:YES];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                ZWFeedTableViewController *feedTabelViewController = [[ZWFeedTableViewController alloc] init];
                feedTabelViewController.feedType = ZWFeedTableViewTypeAboutUser;
                feedTabelViewController.user = [UMComSession sharedInstance].loginUser;
                [self.navigationController pushViewController:feedTabelViewController animated:YES];
            }
                break;
                
            case 1: {
                ZWFeedTableViewController *feedTableViewController = [[ZWFeedTableViewController alloc] init];
                feedTableViewController.feedType = ZWFeedTableViewTypeAboutCollection;
                [self.navigationController pushViewController:feedTableViewController animated:YES];
            }
                
                break;
                
            case 2: {
                ZWUserCommentsViewController *commentsViewController = [[ZWUserCommentsViewController alloc] init];
                [self.navigationController pushViewController:commentsViewController animated:YES];
                if ([ZWUserManager sharedInstance].unreadCommentCount > kStudentCircleFetchDataCount) {
                    [ZWUserManager sharedInstance].unreadCommentCount -= kStudentCircleFetchDataCount;
                } else {
                    [ZWUserManager sharedInstance].unreadCommentCount = 0;
                }
                [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            }
                break;
                
            case 3: {
                ZWUserLikesViewController *likeViewController = [[ZWUserLikesViewController alloc] init];
                [self.navigationController pushViewController:likeViewController animated:YES];
                if ([ZWUserManager sharedInstance].unreadLikeCount > kStudentCircleFetchDataCount) {
                    [ZWUserManager sharedInstance].unreadLikeCount -= kStudentCircleFetchDataCount;
                } else {
                    [ZWUserManager sharedInstance].unreadLikeCount = 0;
                }
                [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            }
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        ZWCountDownListViewController *controller = [[ZWCountDownListViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 2) {
        NSString *title = indexPath.row == 0 ? @"意见反馈" : @"加入我们";
        NSString *urlString = indexPath.row == 0 ? @"http://robinchen.mikecrm.com/Fc00ps" : @"http://robinchen.mikecrm.com/V36ze6";
        [ZWBrowserTool openWebAddress:urlString fixedTitle:title];
    }

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
