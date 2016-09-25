//
//  ZWFeedListViewController.h
//  Qimokaola
//
//  Created by Administrator on 16/8/24.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UMCommunitySDK/UMComDataRequestManager.h>

typedef NS_ENUM(NSUInteger, ZWFeedTableViewType) {
    ZWFeedTableViewTypeAboutTopic = 0, // 有关话题的 feed 流
    ZWFeedTableViewTypeAboutUser,
};

@interface ZWFeedTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// feed 类型 有关于话题或者有关于用户
@property (nonatomic, assign) ZWFeedTableViewType feedType;
// 有关于话题时 topic必有值
@property (nonatomic, strong) UMComTopic *topic;
// 有关于用户时 user必有值
@property (nonatomic, strong) UMComUser *user;

@end
