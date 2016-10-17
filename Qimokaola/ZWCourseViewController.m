//
//  ZWCourseViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/9/10.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWCourseViewController.h"


@interface ZWCourseViewController ()

@property (nonatomic, strong) UIView *schoolNameView;
@property (nonatomic, strong) UILabel *schoolNameLabel;
@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation ZWCourseViewController

static NSString *const ROOT = @"/";
static NSString *const kCourseCellIdentifier = @"kCourseCellIdentifier";

#pragma mark - Life Cycle

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
    
    __weak __typeof(self) weakSelf = self;
    
    self.hidesBottomBarWhenPushed = NO;
    
    self.tableView.emptyDataSetSource = nil;
    self.tableView.emptyDataSetDelegate = nil;
    
    [self.tableView registerClass:[ZWCourseCell class] forCellReuseIdentifier:kCourseCellIdentifier];
    self.tableView.rowHeight = 50;
    
    ((UISearchBar *)self.tableView.tableHeaderView).placeholder = @"搜索课程";
    
    _schoolNameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 44)];
    _schoolNameView.backgroundColor = [UIColor clearColor];
    [_schoolNameView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popToSwitchSchool:)]];
    
    _schoolNameLabel = [[UILabel alloc] init];
    _schoolNameLabel.font = [[[UINavigationBar appearance] titleTextAttributes] objectForKey:NSFontAttributeName];
    _schoolNameLabel.textColor = [UIColor whiteColor];
    [self setSchoolNameLabelData];
    [_schoolNameLabel sizeToFit];
    [_schoolNameView addSubview:_schoolNameLabel];
    [_schoolNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(weakSelf.schoolNameView);
    }];
    
    _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_switch_school"]];
    [_schoolNameView addSubview:_arrowView];
    [_arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.left.equalTo(weakSelf.schoolNameLabel.mas_right).with.offset(5);
        make.centerY.equalTo(weakSelf.schoolNameLabel);
    }];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    UIBarButtonItem *schoolNameItem = [[UIBarButtonItem alloc] initWithCustomView:_schoolNameView];
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, schoolNameItem];
    
    UIBarButtonItem *uploadItem = [[UIBarButtonItem alloc] initWithTitle:@"上传资料" style:UIBarButtonItemStyleDone target:self action:@selector(tapUpload)];
    self.navigationItem.rightBarButtonItem = uploadItem;
    
    [self checkAppUpdate];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kUserLoginSuccessNotification object:nil] subscribeNext:^(id x) {
        if (!weakSelf.tableView.mj_header.isRefreshing) {
            [weakSelf.tableView.mj_header beginRefreshing];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters & Setters

#pragma mark - Normal Method

- (void)tapUpload {
    __weak __typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择上传方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *uploadByComputer = [UIAlertAction actionWithTitle:@"电脑上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf openUploadMethodViewWithTitle:action.title assetName:@"pic_upload_method_computer"];
    }];
    UIAlertAction *uploadByPhone = [UIAlertAction actionWithTitle:@"手机上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf openUploadMethodViewWithTitle:action.title assetName:@"pic_upload_method_phone"];
    }];
    [alertController addAction:cancleAction];
    [alertController addAction:uploadByComputer];
    [alertController addAction:uploadByPhone];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)openUploadMethodViewWithTitle:(NSString *)title assetName:(NSString *)assetName {
    ZWUploadMethodViewController *uploader = [[ZWUploadMethodViewController alloc] init];
    uploader.title = title;
    uploader.assetName = assetName;
    [self.navigationController pushViewController:uploader animated:YES];
}

- (void)checkAppUpdate {
    __weak __typeof(self) weakSelf = self;
    [ZWAPIRequestTool requestAppInfo:^(id response, BOOL success) {
        if (success) {
            NSDictionary *info = [[response objectForKey:@"results"] objectAtIndex:0];
            NSString *serverVersion = [info objectForKey:@"version"];
            NSString *localVersion =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSArray *serverArray = [serverVersion componentsSeparatedByString:@"."];
            NSArray *localArray = [localVersion componentsSeparatedByString:@"."];
            NSInteger maxCount = MAX(serverArray.count, localArray.count);
            for (int i = 0; i < maxCount; i ++) {
                NSInteger v1 = serverArray.count - 1 >= i ? [serverArray[i] integerValue] : 0;
                NSInteger v2 = localArray.count - 1 >= i ? [localArray[i] integerValue] : 0;
                if (v1 > v2) {
                    [weakSelf showUpdateAlertWithReleaseNotes:[info objectForKey:@"releaseNotes"]];
                    break;
                } else if (v2 > v1) {
                    break;
                }
            }
        }
    }];
}

- (void)showUpdateAlertWithReleaseNotes:(NSString *)releaseNotes {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发现新版本" message:releaseNotes preferredStyle:UIAlertControllerStyleAlert];
    // 添加按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"稍后再说" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1054613325"]];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setSchoolNameLabelData {
    _schoolNameLabel.text = [ZWUserManager sharedInstance].loginUser.currentCollegeName;
    _schoolNameView.width = _schoolNameLabel.width + 15;
}

- (void)popToSwitchSchool:(UIGestureRecognizer *)sender {
    __weak __typeof(self) weakSelf = self;
    ZWSwitchSchollViewController *switchSchoolViewController = [[ZWSwitchSchollViewController alloc] init];
    switchSchoolViewController.switchSchoolCompletion = ^(NSString *collegeName, NSString *collegeID) {
        if ([weakSelf.schoolNameLabel.text isEqualToString:collegeName]) {
            return;
        }
        weakSelf.shouldEmptyViewShow = NO;
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.tableView reloadData];
        [[ZWUserManager sharedInstance] updateCurrentCollegeId:@(collegeID.intValue) collegeName:collegeName];
        [weakSelf setSchoolNameLabelData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.shouldEmptyViewShow = YES;
            [weakSelf.tableView.mj_header beginRefreshing];
        });
    };
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:switchSchoolViewController];
    [self presentViewController:navc animated:YES completion:nil];
}

#pragma mark 重写覆盖下拉刷新方法
- (void)freshHeaderStartFreshing {
    __weak __typeof(self) weakSelf = self;
    ZWUser *user = [ZWUserManager sharedInstance].loginUser;
    [ZWAPIRequestTool requstFileAndFolderListInSchool:user.currentCollegeId
                                                 path:ROOT
                                           needDetail:NO
                                               result:^(id response, BOOL success) {
                                                   [weakSelf.tableView.mj_header endRefreshing];
                                                   if (success) {
                                                       [weakSelf loadRemoteData:[response objectForKey:kHTTPResponseResKey]];
                                                   } else {
                                                       NSString *errDesc = nil;
                                                       if ([(NSError *)response code] == -1001) {
                                                           errDesc = @"呀，连接不上服务器了";
                                                       } else {
                                                           errDesc = @"出现错误，获取失败";
                                                       }
                                                       [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:errDesc message:nil duration:kShowHUDMid];
                                                   }
                                                   
                                               }];
}

#pragma mark 处理接收到数据
- (void)loadRemoteData:(NSDictionary *)data {
    self.dataArray = [[[data objectForKey:@"folders"] linq_select:^id(NSDictionary *item) {
        return [ZWFolder modelWithDictionary:item];
    }] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourseCellIdentifier];
    ZWFolder *folder = nil;
    if (self.searchController.active) {
        folder = [self.filteredArray objectAtIndex:indexPath.row];
    } else {
        folder = [self.dataArray objectAtIndex:indexPath.row];
    }
    cell.folderName = folder.name;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    
    NSString *path = nil;
    ZWFolder *folder = nil;
    if (self.searchController.active) {
        folder = [self.filteredArray objectAtIndex:indexPath.row];
    } else {
        folder = [self.dataArray objectAtIndex:indexPath.row];
    }
    path = [[ROOT stringByAppendingPathComponent:folder.name] stringByAppendingString:@"/"];
    ZWFileAndFolderViewController *fileAndFolder = [[ZWFileAndFolderViewController alloc] init];
    fileAndFolder.path = path;
    fileAndFolder.course = folder.name;
    [self.navigationController pushViewController:fileAndFolder animated:YES];
}

#pragma mark - UISearchResultUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.filteredArray removeAllObjects];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", searchController.searchBar.text];
    self.filteredArray = [[self.dataArray filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    searchController.searchBar.searchBarStyle = UIBarStyleDefault;
    if (self.tableView.mj_header.isRefreshing) {
        [self.tableView.mj_header endRefreshing];
    }
    self.tabBarController.tabBar.hidden = YES;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
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
