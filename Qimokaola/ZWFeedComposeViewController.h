//
//  ZWNewFeedViewController.h
//  Qimokaola
//
//  Created by Administrator on 16/9/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UMCommunitySDK/UMComDataRequestManager.h>
#import <UMComDataStorage/UMComTopic.h>
#import <UMComDataStorage/UMComFeed.h>

/**
 *  @author Administrator, 16-09-12 21:09:22
 *
 *  创建或者回复Feed
 */

typedef NS_ENUM(NSUInteger, ZWFeedComposeType) {
    ZWFeedComposeTypeNewFeed = 0, // 新Feed
    ZWFeedComposeTypeReplyFeed,  // 回复Feed
    ZWFeedComposeTypeReplyComment // 回复评论
};

@interface ZWFeedComposeViewController : UIViewController

// 执行完相关操作后执行的代码
@property (nonatomic, copy) void(^completion)(id result);
// Feed类型
@property (nonatomic, assign) ZWFeedComposeType composeType;
// 若创建新Feed，则topicID应该有值
@property (nonatomic, strong) NSString *topicID;
// 若回复Feed，则feddID应该有值
@property (nonatomic, strong) NSString *feedID;
// 若回复评论 则commentID应该有值
@property (nonatomic, strong) NSString *commentID;

@end
