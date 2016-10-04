//
//  ZWFileAndFolderViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/9/9.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFileAndFolderViewController.h"
#import "ZWFileCell.h"
#import "ZWFolderCell.h"
#import "ZWFileDetailViewController.h"

#import "LinqToObjectiveC.h"


@interface ZWFileAndFolderViewController ()

@end

@implementation ZWFileAndFolderViewController

static NSString *const FileCellIdentifier = @"FileCellIdentifier";
static NSString *const FolderCellIdentifier = @"FolderCellIdentifier";

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.path lastPathComponent];
    
    self.tableView.rowHeight = 55;
    [self.tableView registerClass:[ZWFileCell class] forCellReuseIdentifier:FileCellIdentifier];
    [self.tableView registerClass:[ZWFolderCell class] forCellReuseIdentifier:FolderCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Normal Method

/**
 *  @author Administrator, 16-09-09 21:09:25
 *
 *  下拉刷新时调用此方法
 */
- (void)freshHeaderStartFreshing {
    __weak __typeof(self) weakSelf = self;
    [ZWAPIRequestTool requstFileAndFolderListInSchool:[ZWUserManager sharedInstance].loginUser.collegeId
                                                 path:self.path
                                           needDetail:YES
                                               result:^(id response, BOOL success) {
                                                   
                                                   [weakSelf.tableView.mj_header endRefreshing];
                                                   
                                                   if (success) {
                                                       NSDictionary *res = [response objectForKey:kHTTPResponseResKey];
                                                       [weakSelf loadRemoteData:res];
                                                   }
                                                   
                                               }];
}


- (void)loadRemoteData:(NSDictionary *)data {
    
    NSLog(@"%@", data);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.files = [[[data objectForKey:@"files"] linq_select:^id(NSDictionary *item) {
            return [ZWFile modelWithDictionary:item];
        }] mutableCopy];
        
        self.folders = [[[data objectForKey:@"folders"] linq_select:^id(NSDictionary *item) {
            return [ZWFolder modelWithDictionary:item];
        }] mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

/**
 *  @author Administrator, 16-09-10 23:09:01
 *
 *  判断是否位于文件范围
 *
 *  @param index 索引
 *
 *  @return 是否
 */
- (BOOL)isIndexInFiles:(NSInteger)index {
    if (self.searchController.active) {
        return index < self.filteredFiles.count;
    } else {
        return index < self.files.count;
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return self.filteredFiles.count + self.filteredFolder.count;
    } else {
        return self.files.count + self.folders.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isIndexInFiles:indexPath.row]) {
        ZWFile *file = nil;
        if (self.searchController.active) {
            file = [self.filteredFiles objectAtIndex:indexPath.row];
        } else {
            file = [self.files objectAtIndex:indexPath.row];
        }
        
        ZWFileCell *cell = [tableView dequeueReusableCellWithIdentifier:FileCellIdentifier];
        cell.file = file;
        return cell;
    } else {
        ZWFolder *folder = nil;
        if (self.searchController.active) {
            folder = [self.filteredFolder objectAtIndex:(indexPath.row - self.filteredFiles.count)];
        } else {
            folder = [self.folders objectAtIndex:(indexPath.row - self.files.count)];
        }
        
        ZWFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:FolderCellIdentifier];
        cell.folderName = folder.name;
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    
    if ([self isIndexInFiles:indexPath.row]) {
        ZWFile *file = nil;
        if (self.searchController.active) {
            file = [self.filteredFiles objectAtIndex:indexPath.row];
        } else {
            file = [self.files objectAtIndex:indexPath.row];
        }
        ZWFileDetailViewController *fileDetail = [[ZWFileDetailViewController alloc] init];
        fileDetail.file = file;
        fileDetail.path = self.path;
        [self.navigationController pushViewController:fileDetail animated:YES];
    } else {
        ZWFolder *folder = nil;
        if (self.searchController.active) {
            folder = [self.filteredFolder objectAtIndex:(indexPath.row - self.filteredFiles.count)];
        } else {
            folder = [self.folders objectAtIndex:(indexPath.row - self.files.count)];
        }
        ZWFileAndFolderViewController *fileAndFolder = [[ZWFileAndFolderViewController alloc] init];
        fileAndFolder.path = [[self.path stringByAppendingPathComponent:folder.name] stringByAppendingString:@"/"];
        [self.navigationController pushViewController:fileAndFolder animated:YES];
    }
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.filteredFiles removeAllObjects];
    [self.filteredFolder removeAllObjects];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", searchController.searchBar.text];
    self.filteredFiles = [[self.files filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    self.filteredFolder = [[self.folders filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
