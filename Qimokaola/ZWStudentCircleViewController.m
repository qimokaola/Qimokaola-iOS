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

@interface ZWStudentCircleViewController () <SDCycleScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray<UMComTopic *> *topics;
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, copy) NSString *nextPageURL;

@end

@implementation ZWStudentCircleViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.cycleScrollView.autoScroll = YES;
    [self.cycleScrollView adjustWhenControllerViewWillAppera];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.cycleScrollView.autoScroll = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //__weak __typeof(self) weakSelf = self;
    
    self.title = @"学生圈";
    
    self.placeholderImage = [[UIImage imageNamed:@"avatar"] imageByResizeToSize:CGSizeMake(40, 40)];
    
    self.topics = [NSMutableArray array];
    
    NSArray *imgs = @[
                      @"pic1.jpg",
                      @"pic2.jpg",
                      @"pic3.jpg",
                      @"pic4.jpg",
                      @"pic5.jpg"];
    
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, 150) shouldInfiniteLoop:YES imageNamesGroup:imgs];
    self.cycleScrollView.delegate = self;
    self.cycleScrollView.autoScrollTimeInterval = 5;
    self.tableView.tableHeaderView = self.cycleScrollView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footerView;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchTopicData)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.tableView.mj_header beginRefreshing];
        
    });
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchNextPageTopicData)];
    
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

- (void)fetchTopicData {
    [[UMComDataRequestManager defaultManager] fetchTopicsAllWithCount:5 completion:^(NSDictionary *responseObject, NSError *error) {
        
        [self fetchedNewData:responseObject sourceType:ZWFetchedDataSourceFromHeader];
        
    }];
}

- (void)fetchNextPageTopicData {
    
    if (!self.nextPageURL) {
        
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"已经到底了..." message:nil duration:1.0];
        
        [self.tableView.mj_footer endRefreshing];
        
        return;
    }
    
    [[UMComDataRequestManager defaultManager] fetchNextPageWithNextPageUrl:self.nextPageURL pageRequestType:UMComRequestType_AllTopic completion:^(NSDictionary *responseObject, NSError *error) {
        
       [self fetchedNewData:responseObject sourceType:ZWFetchedDataSourceFromFooter];
        
    }];
    
}

- (void)fetchedNewData:(NSDictionary *)data sourceType:(ZWFetchedDataSource)source {
    
    NSArray<UMComTopic *> *tmp = [data objectForKey:@"data"];
    
    NSMutableArray<UMComTopic *> *fetchedTopics = [NSMutableArray array];
    
    for (UMComTopic *topic in tmp) {
        
        NSLog(@"%@", topic.custom);
        [fetchedTopics addObject:topic];
        
    }
    
    NSLog(@"Fetched %ld group data. next page url: %@", fetchedTopics.count, [data objectForKey:@"next_page_url"]);
    
    if (source == ZWFetchedDataSourceFromHeader) {
        
        [self.tableView.mj_header endRefreshing];
        
        if ([[NSSet setWithArray:fetchedTopics] isSubsetOfSet:[NSSet setWithArray:self.topics]]) {
            
            NSLog(@"无新数据");
            
            return;
        }
    } else {
        
        [self.tableView.mj_footer endRefreshing];
        
    }
    
    
    self.nextPageURL = [data objectForKey:@"next_page_url"];
    
    [self.topics addObjectsFromArray:fetchedTopics];
    [self.tableView reloadData];
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
