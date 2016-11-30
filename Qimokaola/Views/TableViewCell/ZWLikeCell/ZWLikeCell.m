//
//  ZWLikeCell.m
//  Qimokaola
//
//  Created by Administrator on 2016/10/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWLikeCell.h"
#import "ZWReplytPaddingLabel.h"
#import "ZWHUDTool.h"

#import "UMComResouceDefines.h"

@interface ZWLikeCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *schoolLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) ZWReplytPaddingLabel *replyLabel;

@end

@implementation ZWLikeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        [self zw_addSubViews];
    }
    return self;
}

- (void)zw_addSubViews {
    // 内容字体大小
    CGFloat contentLabelFontSize = 16;
    // 中等文字字体大小
    CGFloat midFontSize = 14;
    // 较小文本的字体大小
    CGFloat smallFontSize = 12;
    CGFloat margin = 10.f;
    CGFloat smallMargin = 5.0f;
    CGFloat avatarHeightOrWidth = 35;
    CGFloat singleLineLabelMaxWidth = 200.f;
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.layer.cornerRadius = avatarHeightOrWidth / 2;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.userInteractionEnabled = YES;
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToUser)]];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:midFontSize];
    _nameLabel.numberOfLines = 1;
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:smallFontSize];
    _timeLabel.numberOfLines = 1;
    _timeLabel.textColor = [UIColor lightGrayColor];
    
    _schoolLabel = [[UILabel alloc] init];
    _schoolLabel.font = [UIFont systemFontOfSize:smallFontSize];
    _schoolLabel.numberOfLines = 1;
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
    _contentLabel.text = @"赞了这条动态";
    
    _replyLabel = [[ZWReplytPaddingLabel alloc] init];
    _replyLabel.paddingLabelType = ZWReplyPaddingLabelTypeUserLike;
    [_replyLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickReplyLabel)]];
    
    NSArray *subViews = @[_avatarView, _nameLabel, _timeLabel, _schoolLabel, _contentLabel, _replyLabel];
    [self.contentView sd_addSubviews:subViews];
    
    UIView *contentView = self.contentView;
    
    _avatarView.sd_layout
    .leftSpaceToView(contentView, margin)
    .topSpaceToView(contentView, margin)
    .heightIs(avatarHeightOrWidth)
    .widthIs(avatarHeightOrWidth);
    
    _nameLabel.sd_layout
    .leftSpaceToView(_avatarView, margin)
    .topEqualToView(_avatarView)
    .heightIs(18);
    [_nameLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _timeLabel.sd_layout
    .leftEqualToView(_nameLabel)
    .bottomEqualToView(_avatarView)
    .heightIs(15);
    [_timeLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _schoolLabel.sd_layout
    .leftSpaceToView(_timeLabel, smallMargin)
    .topEqualToView(_timeLabel)
    .heightIs(15);
    [_schoolLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _contentLabel.sd_layout
    .leftEqualToView(_nameLabel)
    .rightSpaceToView(contentView, margin)
    .topSpaceToView(_avatarView, margin)
    .autoHeightRatio(0);
    
    _replyLabel.sd_layout
    .leftEqualToView(_contentLabel)
    .rightEqualToView(_contentLabel)
    .topSpaceToView(_contentLabel, margin);
    
    [self setupAutoHeightWithBottomView:_replyLabel bottomMargin:margin];
}

- (void)setLike:(UMComLike *)like {
    _like = like;
    
    [_avatarView setImageWithURL:[NSURL URLWithString:_like.creator.icon_url.small_url_string] placeholder:[UIImage imageNamed:@"avatar"]];
    _nameLabel.text = _like.creator.name;
    _schoolLabel.text = createSchoolName(_like.creator.custom);
    
    _timeLabel.text = createTimeString(_like.create_time);
    
    _replyLabel.replyFeed = _like.feed;
}

- (void)clickToUser {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickUser:)]) {
        [self.delegate cell:self didClickUser:_like.creator];
    }
}

- (void)clickReplyLabel {
    if (_like.feed.status.intValue >= 2) {
        [ZWHUDTool showHUDWithTitle:@"该动态已被删除，试试别的吧" message:nil duration:kShowHUDShort];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickFeed:)]) {
        [self.delegate cell:self didClickFeed:_like.feed];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
