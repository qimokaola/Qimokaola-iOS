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

- (void)setReplyComment:(UMComComment *)replyComment {
    _replyComment = replyComment;
    if (_replyComment) {
        self.hidden = NO;
        NSString *replyContent = nil;
        if (_replyComment.content.length > 0) {
            NSString *creator = [[[_replyComment.custom jsonValueDecoded] objectForKey:@"a"] intValue] == 0 ? _replyComment.creator.name : kStudentCircleAnonyousName;
            replyContent = [NSString stringWithFormat:@"回复@%@的评论：%@", creator, _replyComment.content];
        } else {
            replyContent = @"该评论已被删除";
        }
        _contentLabel.text = replyContent;
    } else {
        self.hidden = YES;
        _contentLabel.text = nil;
    }
}

- (void)setReplyFeed:(UMComFeed *)replyFeed {
    _replyFeed = replyFeed;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
