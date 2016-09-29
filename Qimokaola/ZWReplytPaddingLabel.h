//
//  ZWPaddingLabel.h
//  Qimokaola
//
//  Created by Administrator on 2016/9/29.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UMComDataStorage/UMComComment.h>
#import <UMComDataStorage/UMComUser.h>
#import <SDAutoLayout/SDAutoLayout.h>

#import <YYKit/YYKit.h>

@interface ZWReplytPaddingLabel : UIView


/**
 回复的评论
 */
@property (nonatomic, strong) UMComComment *replyComment;


/**
 回复的feed
 */
@property (nonatomic, strong) UMComFeed *replyFeed;

@end
