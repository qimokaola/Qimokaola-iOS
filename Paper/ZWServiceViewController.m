//
//  ZWMoreViewController2.m
//  Paper
//
//  Created by Administrator on 16/2/24.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWServiceViewController.h"
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "ZWServiceCollectionViewCell.h"
#import "UIColor+CommonColor.h"
#import "ZWAboutUsViewController.h"
#import "ZWBrowserViewController.h"
#import "MobClick.h"
#import "MJRefresh.h"
#import "ZWCountDownViewController.h"


static NSString *kCollectionViewCellID = @"collectionViewCellID";
static NSString *kCollectionViewHeaderID = @"collectionViewHeaderID";

@interface ZWServiceViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *services;
@property (nonatomic, strong) NSArray *links;

@end

@implementation ZWServiceViewController

- (NSArray *)services {
    if (_services == nil) {
        NSArray *service1 = @[
                              @{@"icon": @"upload", @"desc": @"上传资源"},
                              @{@"icon": @"mark_query", @"desc": @"成绩查询"},
                              @{@"icon": @"poster", @"desc": @"视频海报"},
                              @{@"icon": @"print", @"desc": @"打印上门"},
                              @{@"icon": @"equipment", @"desc": @"器材正装"},
                              @{@"icon": @"drone", @"desc": @"无人机服务"},
                              @{@"icon": @"carpooling", @"desc": @"福大拼车"},
                              @{@"icon": @"souvenir", @"desc": @"纪念品定制"},
                              @{@"icon": @"picture_print", @"desc": @"相片文印"},
                              @{@"icon": @"second_hand", @"desc": @"二手市场"},
                              @{@"icon": @"extra_service", @"desc": @"服务入驻"},
                              @{@"icon": @"feedback", @"desc": @"投诉反馈"}
                              ];
        
        NSArray *service2 = @[
                              @{@"icon": @"official", @"desc": @"Papers官网"},
                              @{@"icon": @"translation", @"desc": @"百度翻译"},
                              @{@"icon": @"link", @"desc": @"申请友链"}];
        
        _services = @[service1, service2];
    }
    return _services;
}

- (NSArray *)links {
    if (_links == nil) {
        _links = @[@[
                       @"http://robinchen.mikecrm.com/f.php?t=ZmhFim",
                       @"http://112.124.54.19/Score/index.html?identity=3ABD9A9A6B4622BEFDD35CA21905C0CB",
                       @"http://form.mikecrm.com/f.php?t=HIJjLT",
                       @"http://form.mikecrm.com/f.php?t=l7zy0t",
                       @"http://form.mikecrm.com/f.php?t=jFGpR4",
                       @"http://form.mikecrm.com/f.php?t=Q8R9Ag",
                       @"http://weixinpinpin.duapp.com/pinpinPage/index2.jsp",
                       @"http://form.mikecrm.com/EpubV4",
                       @"http://form.mikecrm.com/eVSwqa",
                       @"http://bbs.fzu.edu.cn/forum.php?mod=forumdisplay&fid=311",
                       @"http://robinchen.mikecrm.com/f.php?t=ahOWL2",
                       @"http://robinchen.mikecrm.com/f.php?t=Fc00ps",],
                   
                   @[
                       @"http://fzu2016.com/",
                       @"http://fanyi.baidu.com/",
                       @"http://robinchen.mikecrm.com/f.php?t=foqK6Y"]
                   ];
    }
    return _links;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    
    __weak __typeof(self) weakSelf = self;
    
    self.view.backgroundColor = [UIColor whiteColor];

    
    //设置下级页面的返回键
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    //UICollectionView视图
    //布局方式
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor colorWithRed:240 / 255.0f green:240 / 255.0f blue:240 / 255.0f alpha:1];
    
    //注册cell， 头部
    [self.collectionView registerClass:[ZWServiceCollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewCellID];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ZWMoreCollectionViewHeader" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionViewHeaderID];
    
    [self.view addSubview:self.collectionView];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.collectionView.mj_header endRefreshing];
                
            });
            
        });
        
    }];
    
    
    //提醒标签
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    [self.view bringSubviewToFront:self.HUD];
    
    
    //右侧捐赠按钮
    UIButton *donateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [donateButton setBackgroundImage:[UIImage imageNamed:@"about_icon"] forState:UIControlStateNormal];
    [donateButton addTarget:self action:@selector(donate) forControlEvents:UIControlEventTouchUpInside];
    donateButton.frame = CGRectMake(0, 0, 20, 20);
    UIBarButtonItem *donateItem = [[UIBarButtonItem alloc] initWithCustomView:donateButton];
    
    self.navigationItem.rightBarButtonItem = donateItem;
}

#pragma mark 捐赠
- (void)donate {
    
    [MobClick event:@"Select_About"];
    
    ZWAboutUsViewController *aboutUs = [[ZWAboutUsViewController alloc] init];
    [self.navigationController pushViewController:aboutUs animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.services.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *service = self.services[section];
    return service.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZWServiceCollectionViewCell *cell = [ZWServiceCollectionViewCell serviceCollectionViewCellWithCollectionView:collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellID forIndexPath:indexPath];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray *service = self.services[section];
    NSDictionary *model = service[row];
    cell.model = model;
    return cell;
}

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"highlighted");
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor lightGrayColor];
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"unhightlighted");
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor whiteColor];
//}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionViewHeaderID forIndexPath:indexPath];
    return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((kScreenWidth - 2) / 3, (kScreenWidth - 2) / 3 - 15);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, section == 0 ? 10 : 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kScreenWidth, section == 0 ? 0 : 30);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    [MobClick event:@"Select_Service"];
    
    //获得服务名称
    NSArray *services = self.services[section];
    NSDictionary *service = services[row];
    NSString *serviceName = service[@"desc"];
    
    NSArray *links = self.links[section];
    NSString *link = links[row];

    
    ZWBrowserViewController *browser = [[ZWBrowserViewController alloc] initWithURLString:link titleString:serviceName loadType:ZWBrowserLoadTypeFromServices];
    [self.navigationController pushViewController:browser animated:YES];
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
