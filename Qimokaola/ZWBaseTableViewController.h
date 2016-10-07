//
//  ZWBaseTableViewController.h
//  Qimokaola
//
//  Created by Administrator on 2016/10/6.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWBaseViewController.h"

#import "MJRefresh.h"

@interface ZWBaseTableViewController : ZWBaseViewController  <UITableViewDelegate, UITableViewDataSource>

// 列表视图
@property (nonatomic, strong) UITableView *tableView;

// 对外暴露的下拉刷新时执行的方法
- (void)freshHeaderStartFreshing;

@end
