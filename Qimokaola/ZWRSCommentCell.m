//
//  ZWRSCommentCell.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/29.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWRSCommentCell.h"

#import "UMComResouceDefines.h"

@interface ZWRSCommentCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *schoolLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) ZWReplytPaddingLabel *replyLabel;
@property (nonatomic, strong) UIButton *commentButton;

@end

@implementation ZWRSCommentCell

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
    
    _replyLabel = [[ZWReplytPaddingLabel alloc] init];
    [_replyLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickReplyLabel)]];
    
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentButton setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(clickCommentButton) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *subViews = @[_avatarView, _nameLabel, _timeLabel, _schoolLabel, _contentLabel, _commentButton, _replyLabel];
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
    
    _commentButton.sd_layout
    .topSpaceToView(contentView, margin)
    .rightSpaceToView(contentView, margin)
    .heightIs(25)
    .widthEqualToHeight();
    
    [self setupAutoHeightWithBottomView:_replyLabel bottomMargin:margin];
}

- (void)setComment:(UMComComment *)comment {
    _comment = comment;
    // 自定义字段 0为不匿名 1为匿名
    if ([[[_comment.custom jsonValueDecoded] objectForKey:@"a"] intValue] == 0) {
        [_avatarView setImageWithURL:[NSURL URLWithString:_comment.creator.icon_url.small_url_string] placeholder:[UIImage imageNamed:@"avatar"]];
        _nameLabel.text = _comment.creator.name;
        _schoolLabel.text = createSchoolName(_comment.creator.custom);
    } else {
        _avatarView.image = [UIImage imageNamed:@"avatar"];
        _nameLabel.text = kStudentCircleAnonyousName;
        _schoolLabel.text = nearBySchoolName;
    }
    
    _timeLabel.text = createTimeString(_comment.create_time);
    _contentLabel.text = _comment.content;

    NSLog(@"%@", _comment);
    if (_comment.reply_comment) {
        _replyLabel.replyComment = _comment.reply_comment;
    } else if (_comment.feed) {
        _replyLabel.replyFeed = _comment.feed;
    }
}

- (void)setRsCommentType:(ZWRSCommentType)rsCommentType {
    _rsCommentType = rsCommentType;
    _commentButton.hidden = _rsCommentType != ZWRSCommentTypeReceived;
}

- (void)clickCommentButton {
    
}

- (void)clickToUser {
    
}

- (void)clickReplyLabel {
    
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
