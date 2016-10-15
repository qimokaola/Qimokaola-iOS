//
//  ZWBaseCommentsViewController.h
//  Qimokaola
//
//  Created by Administrator on 2016/9/29.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWReceivedCommentCell.h"
#import "ZWSentCommentCell.h"

#import "ZWBaseTableViewController.h"

#import <MJRefresh/MJRefresh.h>
#import <UMComDataStorage/UMComComment.h>
#import <UMCommunitySDK/UMComSession.h>
#import <UMCommunitySDK/UMComDataRequestManager.h>
#import <UMComDataStorage/UMComUser.h>
#import <UMComDataStorage/UMComFeed.h>

typedef NS_ENUM(NSUInteger, ZWUserCommentsType) {
    ZWUserCommentsTypeReceived = 0, // 收到的评论
    ZWUserCommentsTypeSent // 发出的评论
};

@interface ZWRSCommentsViewController : ZWBaseTableViewController <ZWRSCommentCellDelegate>

@property (nonatomic, assign) ZWUserCommentsType userCommentsType;

- initWithUserCommentsType:(ZWUserCommentsType)userCommentsType;

@end
