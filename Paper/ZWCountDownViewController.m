//
//  ZWCountDownTableViewController.m
//  Paper
//
//  Created by Administrator on 16/5/19.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWCountDownViewController.h"
#import "Masonry.h"
#import "ZWCreateCountDownViewController.h"

@interface ZWCountDownViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ZWCountDownViewController

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) weakSelf = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"考试倒计时";
    
    //设置下级页面的返回键
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    //放置按钮的View
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(49);
        make.left.right.mas_equalTo(weakSelf.view);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom);
    }];
    
    //添加倒计时按钮
    UIButton *countDownButton = [[UIButton alloc] init];
    [countDownButton addTarget:self action:@selector(createCountDown) forControlEvents:UIControlEventTouchUpInside];
    [countDownButton setTitle:@"新建倒计时" forState:UIControlStateNormal];
    [countDownButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [countDownButton setBackgroundColor:RGB(102., 204., 37.)];
    countDownButton.layer.cornerRadius = 5;
    countDownButton.layer.masksToBounds = YES;
    [bottomView addSubview:countDownButton];
    [countDownButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(bottomView);
        make.height.mas_equalTo(39);
        make.width.mas_equalTo(weakSelf.view.mas_width).with.offset(-40);
    }];
    
    //设置tableView分割线只在数据条目显示
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
}

- (void)createCountDown {
    ZWCreateCountDownViewController *create = [[ZWCreateCountDownViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:create];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 49) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const CellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    
    cell.textLabel.text = @"测试";
    
    return cell;
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
