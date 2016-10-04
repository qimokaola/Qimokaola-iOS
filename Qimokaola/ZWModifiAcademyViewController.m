//
//  ZWModifiAcademyViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/17.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWModifiAcademyViewController.h"
#import "ZWAPIRequestTool.h"
#import "ZWUserManager.h"
#import "ZWHUDTool.h"

@interface ZWModifiAcademyViewController () <UITableViewDelegate, UITableViewDataSource> {
    // 记录原本的学院位置
    NSIndexPath *preAcademyIndexPath;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *academies;
@property (nonatomic, strong) NSNumber *presentAcademyId;

@end

@implementation ZWModifiAcademyViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = defaultBackgroundColor;
    self.title = @"学院";
    
    _presentAcademyId = [ZWUserManager sharedInstance].loginUser.academyId;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.contentInset = UIEdgeInsetsMake(kNavigationBarHeight, 0, 0, 0);
    _tableView.scrollIndicatorInsets = _tableView.contentInset;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tintColor = [UIColor redColor];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    __weak __typeof(self) weakSelf = self;
    MBProgressHUD *hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:nil];
    [ZWAPIRequestTool requestListAcademyWithParameter:@{@"college" : [ZWUserManager sharedInstance].loginUser.collegeId} result:^(id response, BOOL success) {
        
        if (success && [[response objectForKey:kHTTPResponseCodeKey] intValue] == 0) {
            [hud hideAnimated:YES];
            weakSelf.academies = [response objectForKey:kHTTPResponseResKey];
            [weakSelf.tableView reloadData];
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"加载学院失败 请重试";
            [hud hideAnimated:YES afterDelay:kShowHUDMid];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDMid * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
        
    }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.academies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *academy = [self.academies objectAtIndex:indexPath.row];
    cell.textLabel.text = [academy objectForKey:@"name"];
    if ([_presentAcademyId intValue] == [[academy objectForKey:@"id"] intValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        preAcademyIndexPath = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    
    NSDictionary *academy = [self.academies objectAtIndex:indexPath.row];
    _presentAcademyId = [academy objectForKey:@"id"];
    
    if (indexPath.row != preAcademyIndexPath.row) {
        [tableView reloadRowsAtIndexPaths:@[indexPath, preAcademyIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        __weak __typeof(self) weakSelf = self;
        MBProgressHUD *hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:nil];
        [[ZWUserManager sharedInstance] modifyUserAcademyId:_presentAcademyId result:^(id response, BOOL success) {
            if (success && [[response objectForKey:kHTTPResponseCodeKey] intValue] == 0) {
                [hud hideAnimated:YES];
                [[ZWUserManager sharedInstance] updateAcademyId:_presentAcademyId academyName:[academy objectForKey:@"name"]];
                if (weakSelf.completion) {
                    weakSelf.completion();
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"修改失败,请重试";
                [hud hideAnimated:YES afterDelay:kShowHUDMid];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDMid * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
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
