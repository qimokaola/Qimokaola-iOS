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
 *  封装了搜索视图
 */

#import <UIKit/UIKit.h>

@interface ZWBaseSearchViewController : UIViewController

// 列表视图
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;

@end
