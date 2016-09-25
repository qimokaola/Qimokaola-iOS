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
@property (nonatomic, copy) void (^isLikedChangedCompletion)(BOOL isLiked, NSNumber *likeCount);
@property (nonatomic, copy) void (^commentCountChangedCompletion)(NSNumber *commentCount);

@property (nonatomic, strong) UMComFeed *feed;
@property (nonatomic, strong) UMComUser *creator;
@property (nonatomic, assign) BOOL isLiked;

@end
