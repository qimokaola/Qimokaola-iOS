//
//  ZWFileFolderViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/4/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFileFolderViewController.h"
#import "ZWFileCell.h"
#import "ZWFolderCell.h"
#import "MJRefresh.h"
#import "UIColor+Extension.h"
#import "ZWBrowserViewController.h"
#import "ZWFileDetailViewController.h"
#import "AppDelegate.h"
#import "NSDate+Extension.h"

//下载链接基址
static NSString *BasePath;

@interface ZWFileFolderViewController () <UISearchControllerDelegate, UISearchResultsUpdating>

//路径里的所有文件集合
@property (nonatomic, strong) NSMutableArray *files;
//路径里的所有文件夹集合
@property (nonatomic, strong) NSMutableArray *folders;
//路径里所有文件数量
@property (nonatomic, assign) NSInteger fileCount;
//路径里的所有文件夹数量
@property (nonatomic, assign) NSInteger folderCount;
//文件搜索结果
@property (nonatomic, strong) NSMutableArray *fileSearchResults;
//文件搜索结果数量
@property (nonatomic, assign) NSInteger fileSearchResultsCount;
//文件夹搜索结果
@property (nonatomic, strong) NSMutableArray *folderSearchResults;
//文件夹搜索结果数量
@property (nonatomic, assign) NSInteger folderSearchResultsCount;
//路径名称
@property (nonatomic, copy) NSString *name;
//部分有效路径（有效路径为基本路径与部分有效路径的拼接)
@property (nonatomic, copy) NSString *path;
//数据库操作队列
@property (nonatomic, strong) FMDatabaseQueue *DBQueue;
//搜索控件
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation ZWFileFolderViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.searchController.searchBar removeFromSuperview];
    }
}


+ (void)setBasePath:(NSString *)basePath {
    BasePath = basePath;
}

- (FMDatabaseQueue *)DBQueue {
    if (_DBQueue == nil) {
        
        _DBQueue = [(AppDelegate *)[UIApplication sharedApplication].delegate DBQueue];
        
    }
    return _DBQueue;
}

- (instancetype)initWithChild:(ZWChild *)child andName:(NSString *)name {
    if (self = [super init]) {
        
        _name = name;
        
        _path = child.path;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            _files = [NSMutableArray array];
            [child.files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [_files addObject:[ZWFile modelObjectWithDictionary:(NSDictionary *)obj URLString:[NSString stringWithFormat:@"%@%@", BasePath, _path] filePath:_name]];
                
            }];
            _fileCount = child.files.count;
            
            _folders = [NSMutableArray array];
            [child.folders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [_folders addObject:[ZWFolder modelObjectWithDictionary:(NSDictionary *)obj]];
                
            }];
            _folderCount = child.folders.count;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        });
        
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) weakSelf = self;
    
    //self.view.backgroundColor = [UIColor whiteColor];
    //self.tableView.backgroundColor = RGB(239, 239, 244);
    self.view.backgroundColor = RGB(239, 239, 244);
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.title = self.name;
    
    self.tableView.rowHeight = 55;
    
    //设置tableView分割线只在数据条目显示
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    
    //设置刷新控件
    
    MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf.tableView.mj_header endRefreshing];
            
        });
        
    }];
    
    normalHeader.stateLabel.font = [UIFont systemFontOfSize:14];
    normalHeader.stateLabel.textColor = [UIColor blackColor];
    normalHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:13];
    self.tableView.mj_header = normalHeader;
    
    self.tableView.mj_header.automaticallyChangeAlpha = NO;
    //self.tableView.mj_header.backgroundColor = [UIColor whiteColor];
    self.tableView.mj_header.backgroundColor = RGB(239, 239, 244);
    
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
    
    //设置下级页面的返回键
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    UIBarButtonItem *reportItem = [[UIBarButtonItem alloc] initWithTitle:@"报错" style:UIBarButtonItemStylePlain target:self action:@selector(reportError)];
    
    self.navigationItem.rightBarButtonItems = @[reportItem];
    
}

- (void)reportError {
    ZWBrowserViewController *browser = [[ZWBrowserViewController alloc] initWithURLString:@"http://robinchen.mikecrm.com/f.php?t=yFA9QI" titleString:@"报错" loadType:ZWBrowserLoadTypeFromOthers];
    [self.navigationController pushViewController:browser animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    [self.fileSearchResults removeAllObjects];
    [self.folderSearchResults removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchController.searchBar.text];
    
    self.fileSearchResults = [[self.files filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    self.fileSearchResultsCount = self.fileSearchResults.count;
    
    self.folderSearchResults = [[self.folders filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    self.folderSearchResultsCount = self.folderSearchResults.count;

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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return self.folderSearchResultsCount + self.fileSearchResultsCount;
    }
    return self.folderCount + self.fileCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    if ([self isRowInFolders:row]) {
        
        //当前索引小于文件夹数量，故为文件夹
        ZWFolderCell *cell = [ZWFolderCell folderCellWithTableView:tableView];
        
        //根据搜索标记变量从总数据或者搜索结果数据取模型
        ZWFolder *folder = [self.searchController.active ? self.folderSearchResults : self.folders objectAtIndex:row];
        cell.name = folder.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
        
    } else {
        
        ZWFileCell *cell = [ZWFileCell fileCellWithTableView:tableView];
        
        //根据搜索标记变量从总数据或者搜索结果数据取模型
        ZWFile *file = self.searchController.active ? [self.fileSearchResults objectAtIndex:row - self.folderSearchResultsCount] : [self.files objectAtIndex:row - self.folderCount];
        cell.file = file;
        return cell;
        
    }

    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    
    NSInteger row = indexPath.row;
    
    
    if ([self isRowInFolders:row]) {
        
        //当前索引小于文件夹数量，故为文件夹
        //根据搜索标记变量从总数据或者搜索结果数据取模型
        ZWFolder *folder = [self.searchController.active ? self.folderSearchResults : self.folders objectAtIndex:row];
        
        NSLog(@"Folder: %@", folder.name);
        
        ZWFileFolderViewController *fileFolderViewController = [[ZWFileFolderViewController alloc] initWithChild:folder.child andName:folder.name];
        [self.navigationController pushViewController:fileFolderViewController animated:YES];
        
    } else {
        
        __weak typeof(self) weakSelf = self;
        
        ZWFile *file = self.searchController.active ? [self.fileSearchResults objectAtIndex:row - self.folderSearchResultsCount] : [self.files objectAtIndex:row - self.folderCount];
        
        ZWFileDetailViewController *detail = [[ZWFileDetailViewController alloc] initWithFile:file];
        detail.downloadCompletionHandler = ^{
            
            file.download = YES;
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
//            [self.DBQueue inDatabase:^(FMDatabase *db) {
//                
//                //下载成功后保存下载信息至数据库
//                if ([db open]) {
//                    //获取下载完成时的日期
//                    NSString *time = [NSDate current];
//                    
//                    NSString *insertSql1= [NSString stringWithFormat:
//                                           @"INSERT INTO download_info (name, course, link, type, size, time) VALUES ('%@', '%@', '%@', '%@', '%@', '%@')", file.name, self.path, file.url, file.type, file.size, time];
//                    
//                    BOOL res = [db executeUpdate:insertSql1];
//                    
//                    if(res)  {
//                        NSLog(@"保存下载信息成功");
//                    }  else  {
//                        NSLog(@"保存下载信息失败");
//                    }
//                }
//                
//            }];
        };
        [self.navigationController pushViewController:detail animated:YES];
        
        
    }

    
}


/**
 *  @author Administrator, 16-04-06 22:04:15
 *
 *  查询row索引是否是出于文件夹范围内
 *
 *  @param row 索引
 *
 *  @return 是否出于文件夹内
 */
- (BOOL)isRowInFolders:(NSInteger)row {
    return self.searchController.active ? (row < self.folderSearchResultsCount && self.folderSearchResultsCount != 0) : (row < self.folderCount && self.folderCount != 0);
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
