//
//  ZWSingleTypeSearchViewController.h
//  Qimokaola
//
//  Created by Administrator on 16/9/9.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWBaseSearchViewController.h"

/**
 *  @author Administrator, 16-09-09 21:09:57
 *
 *  单一数据类型的显示视图，支持搜索 不直接使用此类 通过继承使用
 *  
 *  多种数据类型的视图难以确定数据类型个数，故难以设计复用的类，故多种数据类型的可根据数据类型个数自行设计
 */

@interface ZWSingleTypeSearchViewController : ZWBaseSearchViewController

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *filteredArray;

@end
