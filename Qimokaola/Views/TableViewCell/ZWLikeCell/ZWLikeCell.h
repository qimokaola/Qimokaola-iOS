//
//  ZWLikeCell.h
//  Qimokaola
//
//  Created by Administrator on 2016/10/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UMComDataStorage/UMComLike.h>
#import <UMComDataStorage/UMComUser.h>
#import <UMComDataStorage/UMComFeed.h>
#import <UMComDataStorage/UMComImageUrl.h>

@class ZWLikeCell;

@protocol ZWLikeCellDelegate <NSObject>

- (void)cell:(ZWLikeCell *)cell didClickUser:(UMComUser *)user;
- (void)cell:(ZWLikeCell *)cell didClickFeed:(UMComFeed *)feed;

@end

@interface ZWLikeCell : UITableViewCell

@property (nonatomic, strong) UMComLike *like;
@property (nonatomic, weak) id<ZWLikeCellDelegate> delegate;

@end
