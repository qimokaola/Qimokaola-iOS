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
#import <UMComDataStorage/UMComFeed.h>
#import <SDAutoLayout/SDAutoLayout.h>

#import <YYKit/YYKit.h>

typedef NS_ENUM(NSUInteger, ZWReplyPaddingLabelType) {
    ZWReplyPaddingLabelTypeComment = 0, // feed评论中
    ZWReplyPaddingLabelTypeReceivedComment, // 收发评论
    ZWReplyPaddingLabelTypeSentComment, // 收发评论
    ZWReplyPaddingLabelTypeUserLike, // 点赞中
};

@interface ZWReplytPaddingLabel : UIView


/**
 可选的回复的评论 当不知道replyComment是否有值时可直接赋值于此值，在setter方法里判断
 */
@property (nonatomic, strong) UMComComment *optionalReplyComment;

/**
 明确replyComment有值时赋值
 */
@property (nonatomic, strong) UMComComment *replyComment;

/**
 回复的feed
 */
@property (nonatomic, strong) UMComFeed *replyFeed;

@property (nonatomic, assign) ZWReplyPaddingLabelType paddingLabelType;

@end
