//
//  ZWBaseSearchViewController.h
//  Qimokaola
//
//  Created by Administrator on 16/9/8.
//  Copyright © 2016年 Administrator. All rights reserved.
//

/**
 *  @author Administrator, 16-09-08 16:09:18
 *
 *  封装了搜索视图 适用于单一数据类型的展现 多种数据类型即多cell类型需要重写必要方法
 */

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@interface ZWBaseSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate>

// 列表视图
@property (nonatomic, strong) UITableView *tableView;
// 搜索控件
@property (nonatomic, strong) UISearchController *searchController;
// 对外暴露的下拉刷新时执行的方法
- (void)freshHeaderStartFreshing;

@end
