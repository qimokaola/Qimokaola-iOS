//
//  ZWFeedCell.m
//  Qimokaola
//
//  Created by Administrator on 16/8/25.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFeedCell.h"
#import "SDAutoLayout.h"
#import "SDWeiXinPhotoContainerView.h"
#import "LinqToObjectiveC.h"
#import "Masonry.h"
#import "UIColor+Extension.h"
#import "YYWebImage.h"


@interface ZWFeedCell ()

// 用户头像
@property (nonatomic, strong) UIImageView *avatarView;
// 用户名
@property (nonatomic, strong) UILabel *nameLabel;
// 用户性别图片
@property (nonatomic, strong) UIImageView *genderView;
// 时间标签
@property (nonatomic, strong) UILabel *timeLabel;
// 学校标签
@property (nonatomic, strong) UILabel *schoolLabel;
// 内容
@property (nonatomic, strong) UILabel *contentLabel;
// 图片容器
@property (nonatomic, strong) SDWeiXinPhotoContainerView *picContainerView;
// 喜欢按钮
@property (nonatomic, strong) UIButton *likeButton;
// 评论按钮
@property (nonatomic, strong) UIButton *commentButton;
// 操作按钮
@property (nonatomic, strong) UIButton *moreButton;
// 分享按钮
@property (nonatomic, strong) UIButton *shareButton;
// 分隔视图
@property (nonatomic, strong) UIView *separatorView;
// 水平分隔线1 三个按钮之上
@property (nonatomic, strong) UIView *horizontalLine1;
// 竖直分隔线 点赞 与 分享按钮 之间
@property (nonatomic, strong) UIView *verticalLine1;
// 竖直分隔线 评论 与 分享按钮 之间
@property (nonatomic, strong) UIView *verticalLine2;
// Feed 作者
@property (nonatomic, strong) UMComUser *creator;

@end

@implementation ZWFeedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self createSubViews];
        
    }
    
    return self;
}

- (void)createSubViews {
    
    // 内容字体大小
    CGFloat contentLabelFontSize = 16;
    
    // 中等文字字体大小
    CGFloat midFontSize = 15;
    
    // 较小文本的字体大小
    CGFloat smallFontSize = 12;
    
    CGFloat margin = 10.f;
    CGFloat smallMargin = 5.0f;
    CGFloat avatarHeightOrWidth = 40;
    
    CGFloat singleLineLabelMaxWidth = 200.f;
    
    CGFloat genderViewSize = 15;
    
    CGFloat buttonHeight = 35.f;
    
    CGFloat separatorViewHeight = 10.f;
    
    CGFloat separatorLineSize = .5f;
    
    UIColor *separatorColor = universalGrayColor;
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.layer.cornerRadius = avatarHeightOrWidth / 2;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.userInteractionEnabled = YES;
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToUser)]];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:midFontSize];
    _nameLabel.numberOfLines = 1;
    _nameLabel.userInteractionEnabled = YES;
    [_nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToUser)]];
    
    _genderView = [[UIImageView alloc] init];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:smallFontSize];
    _timeLabel.numberOfLines = 1;
    _timeLabel.textColor = [UIColor lightGrayColor];
    
    _schoolLabel = [[UILabel alloc] init];
    _schoolLabel.font = [UIFont systemFontOfSize:smallFontSize];
    _schoolLabel.numberOfLines = 1;
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
    _contentLabel.numberOfLines = 0;
    
    _picContainerView = [[SDWeiXinPhotoContainerView alloc] init];
    
    UIImage *backgroundImage = [[UIColor whiteColor] parseToImage];
    UIImage *highlightedBackgroundImage = [separatorColor parseToImage];
    _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_likeButton setImage:[UIImage imageNamed:@"icon_unlike"] forState:UIControlStateNormal];
    [_likeButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_likeButton setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    
    _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareButton setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [_shareButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_shareButton setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentButton setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
    [_commentButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_commentButton setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setImage:[UIImage imageNamed:@"more_arrow"] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(clickMoreButton) forControlEvents:UIControlEventTouchUpInside];
    
    _separatorView = [[UIView alloc] init];
    _separatorView.backgroundColor = separatorColor;
    
    _horizontalLine1 = [[UIView alloc] init];
    _horizontalLine1.backgroundColor = separatorColor;
    
    _verticalLine1 = [[UIView alloc] init];
    _verticalLine1.backgroundColor = separatorColor;
    
    _verticalLine2 = [[UIView alloc] init];
    _verticalLine2.backgroundColor = separatorColor;
    
    NSArray *views = @[_avatarView, _nameLabel, _genderView, _timeLabel, _schoolLabel, _contentLabel, _picContainerView, _moreButton, _likeButton, _commentButton, _shareButton, _separatorView, _horizontalLine1, _verticalLine1, _verticalLine2];
    
    [self.contentView sd_addSubviews:views];
    
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
    
    _genderView.sd_layout
    .leftSpaceToView(_nameLabel, smallMargin)
    .centerYEqualToView(_nameLabel)
    .heightIs(genderViewSize)
    .widthIs(genderViewSize);
    
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
    .leftSpaceToView(contentView, margin)
    .rightSpaceToView(contentView, margin)
    .topSpaceToView(_avatarView, margin)
    .autoHeightRatio(0);
    
    _picContainerView.sd_layout
    .leftEqualToView(_contentLabel);
    
    _moreButton.sd_layout
    .topSpaceToView(contentView, margin)
    .rightSpaceToView(contentView, margin)
    .widthIs(20)
    .heightIs(20);
    
    _horizontalLine1.sd_layout
    .leftEqualToView(contentView)
    .rightEqualToView(contentView)
    .heightIs(separatorLineSize);
    
    _likeButton.sd_layout
    .leftEqualToView(contentView)
    .topSpaceToView(_horizontalLine1, 0)
    .heightIs(buttonHeight)
    .widthRatioToView(contentView, 1.0 / 3.0);
    
    _verticalLine1.sd_layout
    .leftSpaceToView(_likeButton, 0)
    .centerYEqualToView(_likeButton)
    .widthIs(separatorLineSize)
    .heightRatioToView(_likeButton, 0.6);

    _shareButton.sd_layout
    .leftSpaceToView(_likeButton, 0)
    .topEqualToView(_likeButton)
    .heightIs(buttonHeight)
    .widthRatioToView(_likeButton, 1.0);
    
    _verticalLine2.sd_layout
    .leftSpaceToView(_shareButton, 0)
    .centerYEqualToView(_likeButton)
    .widthIs(separatorLineSize)
    .heightRatioToView(_verticalLine1, 1.0);
    
    _commentButton.sd_layout
    .topEqualToView(_likeButton)
    .rightEqualToView(contentView)
    .heightIs(buttonHeight)
    .widthRatioToView(_likeButton, 1.0);
    
    _separatorView.sd_layout
    .leftEqualToView(contentView)
    .rightEqualToView(contentView)
    .topSpaceToView(_likeButton, 0.1)
    .heightIs(separatorViewHeight);
    
   
}

- (void)setFeed:(UMComFeed *)feed {
    _feed = feed;
    _creator = feed.creator;
    
    [_avatarView yy_setImageWithURL:[NSURL URLWithString:_creator.icon_url.midle_url_string] placeholder:[UIImage imageNamed:@"avatar"]];
    
    _nameLabel.text = _creator.name;
    
    _genderView.image = _creator.gender.intValue == 0 ? [UIImage imageNamed:@"icon_female"] : [UIImage imageNamed:@"icon_male"];
    
    _timeLabel.text = feed.create_time;
    
    _contentLabel.text = feed.text;
    
    _picContainerView.picPathStringsArray = [feed.image_urls linq_select:^id(UMComImageUrl *item) {
        return item.small_url_string;
    }];
    
    _picContainerView.highQuantityPicArray = [feed.image_urls linq_select:^id(UMComImageUrl *item) {
        return item.large_url_string;
    }];
    
    CGFloat picContainerViewTopMargin = 0.f;
    if (feed.image_urls && feed.image_urls.count > 0) {
        picContainerViewTopMargin = 10;
        _horizontalLine1.sd_layout.topSpaceToView(_picContainerView, 10);
    } else {
        _horizontalLine1.sd_layout.topSpaceToView(_contentLabel, 10);
    }
    
    _picContainerView.sd_layout.topSpaceToView(_contentLabel, picContainerViewTopMargin);
    
    [self setupAutoHeightWithBottomView:_separatorView bottomMargin:0.f];
}

- (void)clickToUser {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickUser:user:)]) {
        [self.delegate didClickUser:self user:self.creator];
    }
}

- (void)clickMoreButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickMoreButton:)]) {
        [self.delegate didClickMoreButton:self];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
