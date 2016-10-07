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
#import "ZWDataBaseTool.h"

#import "LinqToObjectiveC.h"


@interface ZWFileAndFolderViewController ()


@end

@implementation ZWFileAndFolderViewController

static NSString *const kFileCellIdentifier = @"kFileCellIdentifier";
static NSString *const kFolderCellIdentifier = @"kFolderCellIdentifier";

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.path lastPathComponent];
    
    self.tableView.rowHeight = 55;
    [self.tableView registerClass:[ZWFileCell class] forCellReuseIdentifier:kFileCellIdentifier];
    [self.tableView registerClass:[ZWFolderCell class] forCellReuseIdentifier:kFolderCellIdentifier];
    
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
    self.files = [[[data objectForKey:@"files"] linq_select:^id(NSDictionary *item) {
        ZWFile *file = [ZWFile modelWithDictionary:item];
        file.hasDownloaded = [[ZWDataBaseTool sharedInstance] isFileDownloaded:file.md5];
        return file;
    }] mutableCopy];
    
    self.folders = [[[data objectForKey:@"folders"] linq_select:^id(NSDictionary *item) {
        return [ZWFolder modelWithDictionary:item];
    }] mutableCopy];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
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
    return index < self.files.count;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count + self.folders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isIndexInFiles:indexPath.row]) {
        ZWFile *file = [self.files objectAtIndex:indexPath.row];
        ZWFileCell *cell = [tableView dequeueReusableCellWithIdentifier:kFileCellIdentifier];
        cell.file = file;
        return cell;
    } else {
        ZWFolder *folder = [self.folders objectAtIndex:(indexPath.row - self.files.count)];
        ZWFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kFolderCellIdentifier];
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
        ZWFile *file = [self.files objectAtIndex:indexPath.row];
        ZWFileDetailViewController *fileDetail = [[ZWFileDetailViewController alloc] init];
        fileDetail.file = file;
        fileDetail.path = self.path;
        fileDetail.course = self.course;
        fileDetail.hasDownloaded = file.hasDownloaded;
        if (!file.hasDownloaded) {
            fileDetail.downloadCompletion = ^() {
                file.hasDownloaded = YES;
                [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            };
        }
        [self.navigationController pushViewController:fileDetail animated:YES];
    } else {
        ZWFolder *folder = [self.folders objectAtIndex:(indexPath.row - self.files.count)];
        ZWFileAndFolderViewController *fileAndFolder = [[ZWFileAndFolderViewController alloc] init];
        fileAndFolder.path = [[self.path stringByAppendingPathComponent:folder.name] stringByAppendingString:@"/"];
        fileAndFolder.course = self.course;
        [self.navigationController pushViewController:fileAndFolder animated:YES];
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
