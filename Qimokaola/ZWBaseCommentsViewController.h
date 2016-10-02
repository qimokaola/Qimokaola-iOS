//
//  ZWBaseCommentsViewController.h
//  Qimokaola
//
//  Created by Administrator on 2016/9/29.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWRSCommentCell.h"

#import <MJRefresh/MJRefresh.h>
#import <UMComDataStorage/UMComComment.h>
#import <UMCommunitySDK/UMComSession.h>
#import <UMCommunitySDK/UMComDataRequestManager.h>
#import <UMComDataStorage/UMComUser.h>
#import <UMComDataStorage/UMComFeed.h>

static NSString *RSCommentCellIdentifier = @"RSCommentCellIdentifier";

@interface ZWBaseCommentsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

/**
 评论数组
 */
@property (nonatomic, strong) NSMutableArray *comments;

- (void)fetchCommentsData;

@end
