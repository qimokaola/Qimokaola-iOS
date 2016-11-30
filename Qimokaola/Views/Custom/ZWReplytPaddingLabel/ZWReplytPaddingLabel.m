//
//  ZWPaddingLabel.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/29.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWReplytPaddingLabel.h"

@interface ZWReplytPaddingLabel ()

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation ZWReplytPaddingLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    self.backgroundColor = RGB(220., 243., 248.);
    self.layer.cornerRadius = 5.f;
    
    CGFloat margin = 10.f;
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = ZWFont(14);
    _contentLabel.textColor = [UIColor blackColor];
    [self addSubview:_contentLabel];
    
    _contentLabel.sd_layout
    .leftSpaceToView(self, margin)
    .topSpaceToView(self, margin)
    .rightSpaceToView(self, margin)
    .autoHeightRatio(0);
    
    [self setupAutoHeightWithBottomView:_contentLabel bottomMargin:margin];
}


/**
 此方法主要用在feed详情的评论列表里，因其不确定是否有评论

 @param optionalReplyComment 可选的replyComment
 */
- (void)setOptionalReplyComment:(UMComComment *)optionalReplyComment {
    _optionalReplyComment = optionalReplyComment;
    // 若可选的replyComment有值 则直接赋值给replyComment
    if (_optionalReplyComment) {
        self.replyComment = _optionalReplyComment;
    } else {
        self.hidden = YES;
        _contentLabel.text = nil;
    }
}


/**
 此方法用在收到或者发出的评论里，因为若赋值则表明一定有值

 @param replyComment replyComment
 */
- (void)setReplyComment:(UMComComment *)replyComment {
    _replyComment = replyComment;
    self.hidden = NO;
    
    NSString *replyContent = nil;
    if (_replyComment.status.intValue == 0) {
        NSString *creator = DecodeAnonyousCode(_replyComment.custom) ? _replyComment.creator.name : kStudentCircleAnonyousName;
        replyContent = [NSString stringWithFormat:@"回复@%@的评论：%@", creator, _replyComment.content];
    } else {
        replyContent = @"该评论已被删除";
    }
    _contentLabel.text = replyContent;
}

/**
 此方法用在收到或者发出的评论里，因为若赋值则表明一定有值

 @param replyFeed
 */
- (void)setReplyFeed:(UMComFeed *)replyFeed {
    _replyFeed = replyFeed;
    
    self.hidden = NO;
    
    NSString *feedContent = nil;
    if (_replyFeed.status.intValue < 2) {
        if (_paddingLabelType == ZWReplyPaddingLabelTypeReceivedComment) {
            feedContent = DecodeAnonyousCode(_replyFeed.custom) ? [NSString stringWithFormat:@"回复我的主题: %@", _replyFeed.text] : [NSString stringWithFormat:@"回复我的匿名主题: %@", _replyFeed.text];
        } else if (_paddingLabelType == ZWReplyPaddingLabelTypeSentComment) {
            NSString *creator = DecodeAnonyousCode(_replyFeed.custom) ? _replyFeed.creator.name : kStudentCircleAnonyousName;
            feedContent = [NSString stringWithFormat:@"回复@%@的主题：%@", creator, _replyFeed.text];
        } else if (_paddingLabelType == ZWReplyPaddingLabelTypeUserLike) {
            NSString *creator = DecodeAnonyousCode(_replyFeed.custom) ? _replyFeed.creator.name : kStudentCircleAnonyousName;
            feedContent = [NSString stringWithFormat:@"@%@: %@", creator, _replyFeed.text];
        }
    } else {
        feedContent = @"该动态已被删除";
    }
    _contentLabel.text = feedContent;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
