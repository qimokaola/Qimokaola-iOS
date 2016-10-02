//
//  ZWReceivedCommentsViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/29.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWReceivedCommentsViewController.h"
#import "ZWHUDTool.h"

@interface ZWReceivedCommentsViewController ()

@end

@implementation ZWReceivedCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override Methods

- (void)fetchCommentsData {
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] fetchCommentsUserReceivedWithCount:5
                                                                      completion:^(NSDictionary *responseObject, NSError *error) {
                                                                          [weakSelf.tableView.mj_header endRefreshing];
                                                                          if (responseObject) {
                                                                              [weakSelf.comments addObjectsFromArray:responseObject[@"data"]];
                                                                              [weakSelf.tableView reloadData];
                                                                          } else {
                                                                              [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"获取数据失败" message:nil duration:kShowHUDShort];
                                                                          }
                                                                      }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWRSCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:RSCommentCellIdentifier];
    cell.comment = self.comments[indexPath.row];
    cell.rsCommentType = ZWRSCommentTypeReceived;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = self.comments[indexPath.row];
    return [tableView cellHeightForIndexPath:indexPath model:model keyPath:@"comment" cellClass:[ZWRSCommentCell class] contentViewWidth:kScreenW];
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
