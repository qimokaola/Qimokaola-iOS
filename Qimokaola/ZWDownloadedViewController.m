//
//  ZWDownloadedViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/10/7.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWDownloadedViewController.h"
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

@interface ZWDownloadedViewController () <UISearchResultsUpdating, UISearchControllerDelegate>

@property (nonatomic, strong) UIImageView *hintView;

@end

@implementation ZWDownloadedViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"已下载";
    self.hidesBottomBarWhenPushed = NO;
    self.tableView.mj_header = nil;
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
}

- (void)initView  {
    
    //编辑按钮
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(edit:)];
    self.navigationItem.rightBarButtonItem = editButton;
    
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
    
    //NSLog(@"下载信息条数: %ld", (unsigned long)self.downloadInfos.count);
    
    //self.hintView.hidden = self.downloadInfos.count != 0;
}


- (void)edit:(UIBarButtonItem *)sender  {
    self.tableView.editing = !self.tableView.editing;
    if (self.tableView.isEditing) {
        sender.title = @"完成";
    }  else  {
        sender.title = @"编辑";
    }
}



#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    searchController.searchBar.searchBarStyle = UIBarStyleDefault;
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
   // [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView数据源方法


#pragma mark 返回cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWDownloadInfoCell *cell = [ZWDownloadInfoCell downloadInfoCellWithTablelView:tableView];
//    ZWDownloadInfoModel *model = [self.searchController.active ? self.searchResults : self.downloadInfos objectAtIndex:indexPath.row];
//    cell.downloadInfo = model;
    return cell;
}

#pragma mark 编辑某个条目后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
//        __weak __typeof(self) weakSelf = self;
//        
//        ZWDownloadInfoModel *model = [self.searchController.active ? self.searchResults : self.downloadInfos objectAtIndex:indexPath.row];
//        
//        //        NSLog(@"url : %@", model.link);
//        
//        NSString *deleteSql = [NSString stringWithFormat:
//                               @"DELETE FROM download_info WHERE link = '%@'", model.link];
//        if ([[NSFileManager defaultManager] removeItemAtPath:[[ZWPathTool downloadDirectory] stringByAppendingPathComponent:model.name] error:NULL]) {
//            
//            [self.DBQueue inDatabase:^(FMDatabase *db) {
//                
//                if([db executeUpdate:deleteSql]) {
//                    
//                    NSLog(@"文件及数据库信息删除成功: %@", model.name);
//                    
//                    NSInteger rowInDonwloadInfos = [weakSelf.downloadInfos indexOfObject:model];
//                    
//                    //删除下载信息数组中的数据
//                    [weakSelf.downloadInfos removeObjectAtIndex:rowInDonwloadInfos];
//                    
//                    //如果处于搜索状态则删除搜索结果中的数据,并更新结果视图
//                    if (weakSelf.searchController.active) {
//                        [weakSelf.searchResults removeObject:model];
//                        NSLog(@"搜索状态");
//                        //更新视图
//                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                    } else {
//                        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowInDonwloadInfos inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic
//                         ];
//                    }
//                    
//                    
//                    
//                    //检查下载信息数量
//                    [weakSelf checkFilesAndSetHint];
//                } else {
//                    NSLog(@"删除: %@失败", model.name);
//                }
//                
//            }];
//            
//        } else {
//            NSLog(@"删除: %@失败", model.name);
//        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


#pragma mark - UITableViewDelegate代理方法

#pragma mark cell点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    ZWDownloadInfoModel *model = [self.tableView != tableView ? self.searchResults : self.downloadInfos objectAtIndex:indexPath.row];
//    ZWOldFile *file = [ZWOldFile fileWithDownloadInfo:model];
//    ZWOldFileDetailViewController *detail = [[ZWOldFileDetailViewController alloc] initWithFile:file];
//    [self.navigationController pushViewController:detail animated:YES];
}

@end
