//
//  ZWFeedListViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/8/24.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFeedTableViewController.h"
#import <UMComDataStorage/UMComTopic.h>
#import <UMComDataStorage/UMComFeed.h>
#import <UMComDataStorage/UMComUser.h>
#import <UMComDataStorage/UMComImageUrl.h>
#import "YYKit.h"
#import "ZWFeedCell.h"
#import "SDAutoLayout.h"
#import <UMCommunitySDK/UMComSession.h>


#define kFeedTableViewCellID @"kFeedTableViewCellID"

@interface ZWFeedTableViewController () <ZWFeedCellDelegate>

@property (nonatomic, strong) NSMutableArray<UMComFeed *> *feeds;

@end

@implementation ZWFeedTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.feeds = [NSMutableArray array];
    
    [[UMComDataRequestManager defaultManager] fetchFeedsTopicRelatedWithTopicId:self.topic.topicID
                                                                       sortType:UMComTopicFeedSortType_default
                                                                      isReverse:NO
                                                                          count:20
                                                                     completion:^(NSDictionary *responseObject, NSError *error) {
                                                                         
                                                                         
                                                                         [self.feeds addObjectsFromArray:[responseObject objectForKey:@"data"]];
                                                                         [self.tableView reloadData];
                                                                         
                                                                         
                                                                     }];
    
    [self.tableView registerClass:[ZWFeedCell class] forCellReuseIdentifier:kFeedTableViewCellID];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    cell.feed = [self.feeds objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    
}

#pragma mark - ZWFeedCellDelegate

- (void)didClickLikeButton:(ZWFeedCell *)cell {
    
}

- (void)didClickShareButton:(ZWFeedCell *)cell {
    
}

- (void)didClickCommentButton:(ZWFeedCell *)cell {
    
}

- (void)didClickMoreButton:(ZWFeedCell *)cell {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *collectAction = [UIAlertAction actionWithTitle:@"收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    if ([[UMComSession sharedInstance].loginUser.uid isEqualToString:cell.feed.creator.uid]) {
        
    } else {
        
    }
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [alertController addAction:collectAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didClickUser:(ZWFeedCell *)cell user:(UMComUser *)user {
    NSLog(@"%@", user.name);
}

- (void)didClickUserName:(ZWFeedCell *)cell userName:(NSString *)userName {
    
}

- (void)didClickWebLink:(ZWFeedCell *)cell link:(NSString *)link {
    
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
