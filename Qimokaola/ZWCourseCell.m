//
//  ZWAcademyCell.m
//  Qimokaola
//
//  Created by Administrator on 16/9/10.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWCourseCell.h"
#import "SDAutoLayout.h"

@interface ZWCourseCell ()

// 左边显示文件夹第一个字的视图
@property (nonatomic, strong) UILabel *circleLabel;
// 文件名标签
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIButton *stickButton;

@end

@implementation ZWCourseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSubViews];
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

- (void)createSubViews {
    _circleLabel = [[UILabel alloc] init];
    _circleLabel.numberOfLines = 1;
    _circleLabel.backgroundColor = [UIColor orangeColor];
    _circleLabel.font = ZWFont(20);
    _circleLabel.textColor = [UIColor whiteColor];
    _circleLabel.textAlignment = NSTextAlignmentCenter;
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.numberOfLines = 1;
    _nameLabel.font = ZWFont(18);
    _nameLabel.textColor = [UIColor blackColor];
    
    _stickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_stickButton setBackgroundImage:[UIImage imageNamed:@"icon_course_unstick"] forState:UIControlStateNormal];
    [_stickButton setBackgroundImage:[UIImage imageNamed:@"icon_course_sticked"] forState:UIControlStateSelected];
    
    [_stickButton addTarget:self action:@selector(stickButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView sd_addSubviews:@[_circleLabel, _nameLabel, _stickButton]];
    
    UIView *contentView = self.contentView;
    
    CGFloat margin = 10.f;
    
    _circleLabel.sd_layout
    .centerYEqualToView(contentView)
    .leftSpaceToView(contentView, margin)
    .heightIs(40)
    .widthEqualToHeight();
    _circleLabel.sd_cornerRadiusFromHeightRatio = @(0.5);
    
    _stickButton.sd_layout
    .rightEqualToView(contentView)
    .centerYEqualToView(contentView)
    .widthIs(30)
    .heightEqualToWidth();
    
    _nameLabel.sd_layout
    .leftSpaceToView(_circleLabel, margin)
    .centerYEqualToView(contentView)
    .rightSpaceToView(_stickButton, 5)
    .heightIs(20);
}

- (void)stickButtonClicked {
    _stickButton.selected = !_stickButton.selected;
}

- (void)setFolderName:(NSString *)folderName {
    _folderName = folderName;
    _nameLabel.text = folderName;
    _circleLabel.text = [folderName substringToIndex:1];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _circleLabel.backgroundColor = [UIColor orangeColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
