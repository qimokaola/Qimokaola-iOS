//
//  ZWResourceViewController.m
//  Qimokaola
//
//  Created by Administrator on 15/10/8.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "ZWRootPathViewController.h"
#import "AppDelegate.h"
#import "ZWBrowserViewController.h"
#import "UIColor+Extension.h"
#import "ZWFileFolderViewController.h"
#import "ZWAppCache.h"
#import "ZWPopViewController.h"
#import "ZWBrowserViewController.h"
#import "ZWPathTool.h"
#import "ZWHUDTool.h"
#import "ZWAPIRequestTool.h"
#import "ZWUserManager.h"
#import "ZWLoginViewController.h"

#import "ZWUserManager.h"

#import "MJRefresh.h"
#import "ReactiveCocoa.h"
#import <YYKit/YYKit.h>

@interface ZWRootPathViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UIPopoverPresentationControllerDelegate>

// UITableView
@property (nonatomic, strong) UITableView *tableView;
//应用代理
@property (nonatomic, strong) AppDelegate *appDelegate;
//缓存文件
@property (nonatomic, copy) NSString *cacheFile;
//文件数据
@property (nonatomic, strong) ZWFileModel *fileModel;
//文件夹搜索结果
@property (nonatomic, strong) NSMutableArray *folderSearchResults;
//搜索控件
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation ZWRootPathViewController

- (NSString *)cacheFile {
    if (_cacheFile == nil) {
        _cacheFile = [[ZWPathTool appCacheDirectory] stringByAppendingPathComponent:@"FileModel.archive"];
    }
    return _cacheFile;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) weakSelf = self;
    
    // self.appDelegate = [UIApplication sharedApplication].delegate;
    [self initView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRequestWaitingTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf startRefresh];
    });
    
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"PapersClickAdvertisementNotification" object:nil] subscribeNext:^(NSNotification *notification) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ZWBrowserViewController *browser = [[ZWBrowserViewController alloc] initWithURLString:notification.userInfo[@"url"] titleString:@"测试广告" loadType:ZWBrowserLoadTypeFromServices];
            
            @strongify(self)
            [self.navigationController pushViewController:browser animated:YES];
        });
    }];
    
 
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated  {
    
    [super viewWillDisappear:animated];
    
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.searchController.searchBar removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated  {
    
    [super viewWillAppear:animated];
    
    if (self.fileModel == nil) {
        
        ZWFileModel *result = [ZWAppCache loadCachedFileModel];
        
        if (result != nil) {
            NSLog(@"读取缓存数据成功, 加载缓存数据");
            self.fileModel = result;
            [self.tableView reloadData];
        } else {
            NSLog(@"读取缓存数据失败,缓存不存在或为空");
        }
    }
}

- (void)initView  {
    
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor whiteColor];
    
    self.view.backgroundColor = RGB(239, 239, 244);
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //右侧上传按钮
    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [uploadButton setBackgroundImage:[UIImage imageNamed:@"extra_upload"] forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(uploadDoc) forControlEvents:UIControlEventTouchUpInside];
    uploadButton.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *uploadItem = [[UIBarButtonItem alloc] initWithCustomView:uploadButton];
    
    self.navigationItem.rightBarButtonItem = uploadItem;
    
    //设置下级页面的返回键
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    UIBarButtonItem *schoolItem = [[UIBarButtonItem alloc] initWithTitle:@"福州大学" style:UIBarButtonItemStyleDone target:self action:@selector(popToChangeSchool:)];
    self.navigationItem.leftBarButtonItem = schoolItem;
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
        //tableView.backgroundColor = RGB(239, 239, 244);
        tableView.rowHeight = 50;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        //设置tableView分割线只在数据条目显示
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [tableView setTableFooterView:v];
        [self.view addSubview:tableView];
        
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                    refreshingAction:@selector(loadData)];
        
        tableView.mj_header.backgroundColor = RGB(239, 239, 244);
        
        tableView;
    });
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)startRefresh {
    [self.tableView.mj_header beginRefreshing];
}

- (void)popToChangeSchool:(UIBarButtonItem *)sender {
    
    __weak __typeof(self) weakSelf = self;
    
    ZWPopViewController *popViewController = [[ZWPopViewController alloc] init];
//    popViewController.block = ^(NSString *school) {
//        
//        if ([weakSelf.navigationItem.leftBarButtonItem.title isEqualToString:school]) {
//            return;
//        }
//        
//        weakSelf.navigationItem.leftBarButtonItem.title = school;
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [weakSelf startRefresh];
//        });
//    };
    popViewController.modalPresentationStyle = UIModalPresentationPopover;
    popViewController.popoverPresentationController.barButtonItem = sender;
    popViewController.preferredContentSize = CGSizeMake(400, 400);
    popViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popViewController.popoverPresentationController.delegate = self;
    
    [self presentViewController:popViewController animated:YES completion:nil];
}

#pragma mark 加载数据
- (void)loadData  {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak __typeof(self) weakSelf = self;
        [ZWNetworkingManager getWithURLString:@"http://121.42.177.33:8082/files.json" success:^(NSURLSessionDataTask *task, id responseObject) {
            
            [weakSelf receiveResponse:responseObject];
            
        } failure:^(NSURLSessionDataTask *task, id responseObject) {
            
            [ZWHUDTool showHUDWithTitle:@"错误信息" message:@"获取数据失败" duration:2.0];
            
            [weakSelf.tableView.mj_header endRefreshing];
            
            
        }];
    });
}

- (void)receiveResponse:(NSDictionary *)result {

    
    __weak __typeof(self) weakSelf = self;
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        
        if (weakSelf.fileModel == nil || ![weakSelf.fileModel.dictionaryRepresentation isEqualToDictionary:result]) {
            
            NSLog(@"数据已更新或原本数据不存在，加载最新数据");
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                weakSelf.fileModel = [[ZWFileModel alloc] initWithDictionary:result];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf.tableView reloadData];
                    
                    [weakSelf.tableView.mj_header endRefreshing];
                });
                
                if ([ZWAppCache saveCacheFileModel:weakSelf.fileModel]) {
                    NSLog(@"写入数据至缓存文件成功");
                } else {
                    NSLog(@"写入数据至缓存文件失败");
                }
                
            });
            
        } else {
            
            NSLog(@"无数据更新，使用原本数据");
            
            [weakSelf.tableView.mj_header endRefreshing];
        }
        
        
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//
//    CGFloat panTranslateY = [scrollView.panGestureRecognizer translationInView:scrollView].y;
//    if (panTranslateY < 0) {
//
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//
//        [self.tabBarController.tabBar setHidenWithAnimation:YES];
//
//    } else {
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//        [self.tabBarController.tabBar setHidenWithAnimation:NO];
//    }
//
//}


#pragma mark 弹出上传文件页面
- (void)uploadDoc {
    ZWBrowserViewController *browser = [[ZWBrowserViewController alloc] initWithURLString:@"http://robinchen.mikecrm.com/f.php?t=ZmhFim" titleString:@"上传资源" loadType:ZWBrowserLoadTypeFromOthers];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.folderSearchResults removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchController.searchBar.text];
    self.folderSearchResults = [[self.fileModel.folders filteredArrayUsingPredicate:resultPredicate] mutableCopy];
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

#pragma mark - UITableView delegate dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return self.folderSearchResults.count;
    }
    return self.fileModel.folders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *const RootPathCellID = @"RootPathCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RootPathCellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RootPathCellID];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = indexPath.row;
    
    ZWOldFolder *folder = [self.searchController.active ? self.folderSearchResults : self.fileModel.folders objectAtIndex:row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = folder.name;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    
    NSInteger row = indexPath.row;
    
    ZWOldFolder *folder = [self.searchController.active ? self.folderSearchResults : self.fileModel.folders objectAtIndex:row];
    
    [ZWFileFolderViewController setBasePath:self.fileModel.base];
    ZWFileFolderViewController *fileFolderViewController = [[ZWFileFolderViewController alloc] initWithChild:folder.child andName:folder.name];
    [self.navigationController pushViewController:fileFolderViewController animated:YES];
    
}



-(void)dealloc{
    //移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
