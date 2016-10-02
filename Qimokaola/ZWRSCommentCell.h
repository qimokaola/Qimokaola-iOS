//
//  ZWRSCommentCell.h
//  Qimokaola
//
//  Created by Administrator on 2016/9/29.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWReplytPaddingLabel.h"

#import <UMComDataStorage/UMComComment.h>
#import <UMComDataStorage/UMComUser.h>
#import <UMComDataStorage/UMComFeed.h>
#import <UMComDataStorage/UMComImageUrl.h>
#import <UMCommunitySDK/UMComSession.h>


@class ZWRSCommentCell;

@protocol ZWRSCommentCellDelegate <NSObject>


@required

/**
 点击用户的代理方法

 @param cell 评论视图
 @param user 点击的用户
 */
- (void)cell:(ZWRSCommentCell *)cell didClickToUser:(UMComUser *)user;

/**
 点击原评论的代理方法

 @param cell    评论视图
 @param comment 原评论
 */
- (void)cell:(ZWRSCommentCell *)cell didClickReplyComment:(UMComComment *)comment;

/**
 点击原feed的代理方法

 @param cell 评论视图
 @param feed 原feed
 */
- (void)cell:(ZWRSCommentCell *)cell didClickReplyFeed:(UMComFeed *)feed;

@optional

/**
 点击回复的代理方法

 @param cell    评论视图
 @param comment 回复的评论
 */
- (void)cell:(ZWRSCommentCell*)cell  didClickCommentButton:(UMComComment *)comment;

@end

/**
 评论类型
 */
typedef NS_ENUM(NSUInteger, ZWRSCommentType) {
    ZWRSCommentTypeReceived = 0, // 收到的评论
    ZWRSCommentTypeSended // 发出的评论
};

/**
 显示收到以及发出的评论 全名 ZWReceivedAndSendedCommentCell
 */
@interface ZWRSCommentCell : UITableViewCell

@property (nonatomic, strong) UMComComment *comment;

@property (nonatomic, assign) ZWRSCommentType rsCommentType;

@property (nonatomic, weak) id<ZWRSCommentCellDelegate> delegate;

@end
