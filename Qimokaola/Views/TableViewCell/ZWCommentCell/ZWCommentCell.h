//
//  ZWCommentCell.h
//  Qimokaola
//
//  Created by Administrator on 2016/9/24.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UMComDataStorage/UMComComment.h>
#import <UMComDataStorage/UMComUser.h>
#import <UMComDataStorage/UMComImageUrl.h>

@class ZWCommentCell;

@protocol ZWCommentCellDelegate <NSObject>

// 点击cell上的按钮
- (void)didClickCommentButtonInCell:(ZWCommentCell *)cell;
- (void)didClickMoreButtonInInCell:(ZWCommentCell *)cell;

// 点击用户
- (void)cell:(ZWCommentCell *)cell didClickUser:(UMComUser *)user;

@end

@interface ZWCommentCell : UITableViewCell

@property (nonatomic, strong) UMComComment *comment;

@property (nonatomic, weak) id<ZWCommentCellDelegate> delegate;

@end
