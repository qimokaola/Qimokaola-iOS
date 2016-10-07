//
//  ZWUserViewController.m
//  Qimokaola
//
//  Created by Administrator on 15/10/11.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "ZWOldDownloadedViewController.h"
#import "UIColor+Extension.h"
#import "FMDB.h"
#import "AppDelegate.h"
#import "ZWDownloadInfoModel.h"
#import "ZWDownloadInfoCell.h"
#import "UMSocial.h"
#import "MBProgressHUD.h"
#import "Masonry.h"
#import "ZWOldFileDetailViewController.h"
#import "ZWOldFile.h"
#import "ZWPathTool.h"

@interface ZWOldDownloadedViewController () <UISearchResultsUpdating, UISearchControllerDelegate>

@property (nonatomic, strong) FMDatabaseQueue *DBQueue;
@property (nonatomic, strong) NSMutableArray *downloadInfos;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) UIImageView *hintView;

//搜索控件
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation ZWOldDownloadedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];

}


- (void)viewDidAppear:(BOOL)animated  {
    
    [super viewDidAppear:animated];
    
    //重新进入时刷新显示
    [self.tableView reloadData];
    [self checkFilesAndSetHint];
}

- (void)viewWillDisappear:(BOOL)animated  {
    
    [super viewWillDisappear:animated];
    
    self.tableView.editing = NO;
    self.navigationItem.rightBarButtonItem.title = @"编辑";
    self.downloadInfos = nil;
    
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.searchController.searchBar removeFromSuperview];
    }
}

- (FMDatabaseQueue *)DBQueue {
    if (_DBQueue == nil) {
        //_DBQueue = [(AppDelegate *)[UIApplication sharedApplication].delegate DBQueue];
    }
    return _DBQueue;
}

- (NSMutableArray *)downloadInfos  {
    if(_downloadInfos == nil)  {
        
        static NSString *const sql = @"SELECT * FROM download_info ORDER BY ID DESC";
        
        _downloadInfos = [NSMutableArray array];
        
        [self.DBQueue inDatabase:^(FMDatabase *db) {
            
            FMResultSet * rs = [db executeQuery:sql];
            while ([rs next]) {
                ZWDownloadInfoModel *model = [ZWDownloadInfoModel downloadInfoWithFMResultSet:rs];
                [_downloadInfos addObject:model];
            }
            [rs close];
        }];
    }
    return _downloadInfos;
}


- (void)initView  {
    
    //编辑按钮
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(edit:)];
    
    self.navigationItem.rightBarButtonItem = editButton;
    
    self.tableView.rowHeight = 55;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    
    //设置搜索控件
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = false;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    //显示无下载文档提示图
    self.hintView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"none_hint"]];
        [self.view addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.view.mas_centerY);
        }];
        
        imageView;
    });
}

#pragma mark 检查文件数量并显示提示图片
- (void)checkFilesAndSetHint {
    
    NSLog(@"下载信息条数: %ld", (unsigned long)self.downloadInfos.count);
    
    self.hintView.hidden = self.downloadInfos.count != 0;
}


- (void)edit:(UIBarButtonItem *)sender  {
    self.tableView.editing = !self.tableView.editing;
    if (self.tableView.isEditing) {
        sender.title = @"完成";
    }  else  {
        sender.title = @"编辑";
    }
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    [self.searchResults removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchController.searchBar.text];
    
    self.searchResults = [[self.downloadInfos filteredArrayUsingPredicate:predicate] mutableCopy];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    searchController.searchBar.searchBarStyle = UIBarStyleDefault;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark 过滤搜索结果
- (void)filterContentWithSearchText:(NSString *)searchText {
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView数据源方法

#pragma mark 返回组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark 返回数据条数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.searchController.active) {
        return self.searchResults.count;
    }
    
    return self.downloadInfos.count;
}

#pragma mark 返回cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZWDownloadInfoCell *cell = [ZWDownloadInfoCell downloadInfoCellWithTablelView:tableView];
    
    ZWDownloadInfoModel *model = [self.searchController.active ? self.searchResults : self.downloadInfos objectAtIndex:indexPath.row];

    cell.downloadInfo = model;
    
    return cell;
}

#pragma mark 编辑某个条目后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        __weak __typeof(self) weakSelf = self;
        
        ZWDownloadInfoModel *model = [self.searchController.active ? self.searchResults : self.downloadInfos objectAtIndex:indexPath.row];
        
//        NSLog(@"url : %@", model.link);
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"DELETE FROM download_info WHERE link = '%@'", model.link];
        if ([[NSFileManager defaultManager] removeItemAtPath:[[ZWPathTool downloadDirectory] stringByAppendingPathComponent:model.name] error:NULL]) {
            
            [self.DBQueue inDatabase:^(FMDatabase *db) {
                
                if([db executeUpdate:deleteSql]) {
                    
                    NSLog(@"文件及数据库信息删除成功: %@", model.name);
                    
                    NSInteger rowInDonwloadInfos = [weakSelf.downloadInfos indexOfObject:model];
                    
                    //删除下载信息数组中的数据
                    [weakSelf.downloadInfos removeObjectAtIndex:rowInDonwloadInfos];
                    
                    //如果处于搜索状态则删除搜索结果中的数据,并更新结果视图
                    if (weakSelf.searchController.active) {
                        [weakSelf.searchResults removeObject:model];
                        NSLog(@"搜索状态");
                        //更新视图
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    } else {
                        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowInDonwloadInfos inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic
                         ];
                    }
                    
                    
                    
                    //检查下载信息数量
                    [weakSelf checkFilesAndSetHint];
                } else {
                    NSLog(@"删除: %@失败", model.name);
                }
                
            }];
            
        } else {
            NSLog(@"删除: %@失败", model.name);
        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


#pragma mark - UITableViewDelegate代理方法

#pragma mark cell点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZWDownloadInfoModel *model = [self.tableView != tableView ? self.searchResults : self.downloadInfos objectAtIndex:indexPath.row];
    ZWOldFile *file = [ZWOldFile fileWithDownloadInfo:model];
    ZWOldFileDetailViewController *detail = [[ZWOldFileDetailViewController alloc] initWithFile:file];
    [self.navigationController pushViewController:detail animated:YES];
}

@end
