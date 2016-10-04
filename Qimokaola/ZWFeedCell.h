//
////
////  ZWFeedCell.h
////  Qimokaola
////
////  Created by Administrator on 16/8/25.
////  Copyright © 2016年 Administrator. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//#import <UMComDataStorage/UMComFeed.h>
//#import <UMComDataStorage/UMComUser.h>
//#import <UMComDataStorage/UMComImageUrl.h>
//
//@class ZWFeedCell;
//
//@protocol ZWFeedCellDelegate <NSObject>
//
//@required
//
//// 点赞 分享 评论 按钮点击
//- (void)cell:(ZWFeedCell *)cell didClickLikeButtonInLikeState:(BOOL)isLiked atIndexPath:(NSIndexPath *)indexPath;
//- (void)cell:(ZWFeedCell *)cell didClickCommentButtonAtIndexPath:(NSIndexPath *)indexPath;
//
//// 点击右上更多按钮
//- (void)cell:(ZWFeedCell *)cell didClickMoreButtonAtIndexPath:(NSIndexPath *)indexPath;
//
//// 点击用户
//- (void)cell:(ZWFeedCell *)cell didClickUser:(UMComUser *)user atIndexPath:(NSIndexPath *)indexPath;
//
//// 点击文本中的链接 用户
////- (void)cell:(ZWFeedCell *)cell didClickWebLink:(NSString *)link;
//
//@end
//
//@interface ZWFeedCell : UITableViewCell
//
//// 具体的feed
//@property (nonatomic, strong) UMComFeed *feed;
//
//@property (nonatomic, weak) id<ZWFeedCellDelegate> delegate;
//
//// Cell 位置
//@property (nonatomic, strong) NSIndexPath *indexPath;
//
//@property (nonatomic, strong) NSNumber *likeCount;
//@property (nonatomic, strong) NSNumber *commentCount;
//
//@property (nonatomic, assign) BOOL isLiked;
//
//@end
//




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
- (void)cell:(ZWFeedCell *)cell didClickLikeButtonInLikeState:(BOOL)isLiked atIndexPath:(NSIndexPath *)indexPath;
- (void)cell:(ZWFeedCell *)cell didClickCollectButtonInCollectState:(BOOL)isCollected atIndexPath:(NSIndexPath *)indexPath;
- (void)cell:(ZWFeedCell *)cell didClickCommentButtonAtIndexPath:(NSIndexPath *)indexPath;

// 点击右上更多按钮
- (void)cell:(ZWFeedCell *)cell didClickMoreButtonAtIndexPath:(NSIndexPath *)indexPath;

// 点击用户
- (void)cell:(ZWFeedCell *)cell didClickUser:(UMComUser *)user atIndexPath:(NSIndexPath *)indexPath;


@end

@interface ZWFeedCell : UITableViewCell

// 具体的feed
@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, weak) id<ZWFeedCellDelegate> delegate;

// Cell 位置
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSNumber *commentCount;


@end
