//
//  ZWStudentCircleViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/7/20.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWStudentCircleViewController.h"
#import "ZWHUDTool.h"
#import "ZWFeedTableViewController.h"
#import "UIColor+Extension.h"

#import "MJRefresh.h"
#import "SDCycleScrollView.h"
#import "ReactiveCocoa.h"
#import <UMCommunitySDK/UMComDataRequestManager.h>
#import <UMComDataStorage/UMComTopic.h>
#import "LinqToObjectiveC.h"
#import <YYKit/YYKit.h>

typedef NS_ENUM(NSInteger, ZWFetchedDataSource) {
    ZWFetchedDataSourceFromHeader,
    ZWFetchedDataSourceFromFooter
};

#define kTopCacheName @"StudentCircleTop"
#define kTopicCacheKey @"TopicCache"

@interface ZWStudentCircleViewController () <SDCycleScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray<UMComTopic *> *topics;
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) YYCache *cache;

@end

@implementation ZWStudentCircleViewController

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.cycleScrollView.autoScroll = YES;
    [self.cycleScrollView adjustWhenControllerViewWillAppera];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    self.navigationController.navigationBar.barTintColor = RGB(246,248,247);
    [self.navigationController.navigationBar setBackgroundImage:[[UIColor whiteColor] parseToImage] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : defaultBlueColor,
                                                           NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightBold],
                                                           }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.cycleScrollView.autoScroll = NO;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.navigationController.navigationBar.barTintColor = defaultBlueColor;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                           NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightBold],
                                                           }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //__weak __typeof(self) weakSelf = self;
    
    self.title = @"学生圈";
    //设置下级页面的返回键
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    self.placeholderImage = [[[UIColor whiteColor] parseToImage] imageByResizeToSize:CGSizeMake(40, 40)];
    
    self.topics = [NSMutableArray array];
    
    self.cache = [[YYCache alloc] initWithName:kTopCacheName];
    [self.topics addObjectsFromArray:(NSArray *)[self.cache objectForKey:kTopicCacheKey]];
    
    NSArray *imgs = @[
                      @"pic1.png",
                      @"pic2.png",
                     @"pic3.png",
                      @"pic4.png"];
    
    
    
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenW, kScreenW / 1.599) shouldInfiniteLoop:YES imageNamesGroup:imgs];
    self.cycleScrollView.delegate = self;
    self.cycleScrollView.autoScrollTimeInterval = 5;
    
    self.tableView.tableHeaderView = self.cycleScrollView;
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil] subscribeNext:^(id x) {
        self.cycleScrollView.autoScroll = NO;
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] subscribeNext:^(id x) {
        self.cycleScrollView.autoScroll = self.isViewLoaded && self.view.window;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Common Methods

- (UIView *)footerView {
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, kScreenW, 50)];
        _footerView.backgroundColor = [UIColor whiteColor];
        UILabel *hintLabel = [[UILabel alloc] initWithFrame:_footerView.bounds];
        hintLabel.numberOfLines = 1;
        hintLabel.textAlignment = NSTextAlignmentCenter;
        hintLabel.font = ZWFont(15);
        hintLabel.text = @"更多频道敬请期待";
        
        [_footerView addSubview:hintLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(71, 0, kScreenW - 71, 0.5)];
        line.backgroundColor = RGB(200, 199, 204);
        [_footerView addSubview:line];
    }
    return _footerView;
}

- (void)freshHeaderStartFreshing {
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] fetchTopicsAllWithCount:100 completion:^(NSDictionary *responseObject, NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        if (responseObject) {
            [weakSelf.topics removeAllObjects];
            [weakSelf.topics addObjectsFromArray:responseObject[@"data"]];
            [weakSelf.tableView reloadData];
            [weakSelf.cache setObject:weakSelf.topics forKey:kTopicCacheKey];
            if (weakSelf.topics.count > 0 && weakSelf.tableView.tableFooterView != weakSelf.footerView) {
                weakSelf.tableView.tableFooterView = weakSelf.footerView;
            }
        } else {
            [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"出错了，获取数据失败" message:nil duration:kShowHUDMid];
        }
    }];
}

#pragma mark SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    //NSLog(@"did scroll to %lu", index);
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    //NSLog(@"did select %lu", index);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.textLabel.textColor = RGB(72, 72, 72);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    
    UMComTopic *topic = [self.topics objectAtIndex:indexPath.row];

    cell.textLabel.text = topic.name;
    cell.detailTextLabel.text = topic.descriptor;
    [cell.imageView setImageWithURL:[NSURL URLWithString:topic.icon_url] placeholder:self.placeholderImage];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    ZWFeedTableViewController *feedListViewController = [[ZWFeedTableViewController alloc] init];
    feedListViewController.feedType = ZWFeedTableViewTypeAboutTopic;
    feedListViewController.topic = self.topics[indexPath.row];
    [self.navigationController pushViewController:feedListViewController animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
