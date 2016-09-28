//
//  ZWFeedDetailViewController.h
//  Qimokaola
//
//  Created by Administrator on 16/8/28.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UMComDataStorage/UMComFeed.h>
#import <UMComDataStorage/UMComUser.h>
#import <UMComDataStorage/UMComImageUrl.h>
#import <UMComDataStorage/UMComComment.h>
#import <UMCommunitySDK/UMComSession.h>
#import <UMCommunitySDK/UMComDataRequestManager.h>


@interface ZWFeedDetailViewController : UIViewController

@property (nonatomic, copy) void (^deleteCompletion)(void);
@property (nonatomic, copy) void (^isLikedChangedCompletion)(BOOL isLiked);
@property (nonatomic, copy) void (^commentCountChangedCompletion)(NSNumber *commentCount);

/**
 要显示详情的feed
 */
@property (nonatomic, strong) UMComFeed *feed;

/**
 是否点赞
 */
@property (nonatomic, assign) BOOL isLiked;

/**
 是否收藏
 */
@property (nonatomic, assign) BOOL isCollected;

/**
 是否一进入就使评论框获取焦点 当评论数为0时为YES 同时可用来判断评论种类 为YES 则为评论feed
 */
@property (nonatomic, assign) BOOL isCommentTextViewNeedFocusWhenInit;

@end
