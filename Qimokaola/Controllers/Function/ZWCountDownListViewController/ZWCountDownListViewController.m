//
//  ZWCountDownListViewController.m
//  Qimokaola
//
//  Created by Administrator on 2017/2/19.
//  Copyright © 2017年 Administrator. All rights reserved.
//

#import "ZWCountDownListViewController.h"

#import "ZWCountDownCell.h"
#import "ZWAddCountDownViewController.h"

#define kCountDownCellReuseIdentifier @"kCountDownCellReuseIdentifier"

@interface ZWCountDownListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ZWCountDownListViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = defaultPlaceHolderColor;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.tableView registerNib:[UINib nibWithNibName:@"ZWCountDownCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCountDownCellReuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)nibName {
    return NSStringFromClass([self class]);
}

#pragma mark - Common Methods

- (IBAction)addCountDown:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ZWAddCountDownViewController *controller = (ZWAddCountDownViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ZWAddCountDownViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWCountDownCell *cell = [tableView dequeueReusableCellWithIdentifier:kCountDownCellReuseIdentifier];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 101;
}


#pragma mark - DZEmptyDataSet

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView   {
    return [UIImage imageNamed:@"pic_none_hint_gray"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    
    return YES;
}

- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView {
    scrollView.contentOffset = CGPointZero;
}

- (void)emptyDataSetWillDisappear:(UIScrollView *)scrollView {
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
