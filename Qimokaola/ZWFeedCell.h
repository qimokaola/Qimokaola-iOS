//
//  ZWFeedCell.h
//  Qimokaola
//
//  Created by Administrator on 16/8/25.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UMComDataStorage/UMComFeed.h>
#import <UMComDataStorage/UMComUser.h>
#import <UMComDataStorage/UMComImageUrl.h>

@class ZWFeedCell;

@protocol ZWFeedCellDelegate <NSObject>

@required

// 点赞 分享 评论 按钮点击
- (void)didClickLikeButton:(ZWFeedCell *)cell;
- (void)didClickShareButton:(ZWFeedCell *)cell;
- (void)didClickCommentButton:(ZWFeedCell *)cell;

// 点击右上更多按钮
- (void)didClickMoreButton:(ZWFeedCell *)cell;

// 点击用户
- (void)didClickUser:(ZWFeedCell *)cell user:(UMComUser *)user;

// 点击文本中的链接 用户
- (void)didClickWebLink:(ZWFeedCell *)cell link:(NSString *)link;
- (void)didClickUserName:(ZWFeedCell *)cell userName:(NSString *)userName;

@end

@interface ZWFeedCell : UITableViewCell

@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, weak) id<ZWFeedCellDelegate> delegate;

@end
