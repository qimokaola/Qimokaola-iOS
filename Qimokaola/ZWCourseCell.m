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

@end

@implementation ZWCourseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSubViews];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    
    [self.contentView sd_addSubviews:@[_circleLabel, _nameLabel]];
    
    UIView *contentView = self.contentView;
    
    CGFloat margin = 10.f;
    
    _circleLabel.sd_layout
    .centerYEqualToView(contentView)
    .leftSpaceToView(contentView, margin)
    .heightIs(40)
    .widthEqualToHeight();
    _circleLabel.sd_cornerRadiusFromHeightRatio = @(0.5);
    
    _nameLabel.sd_layout
    .leftSpaceToView(_circleLabel, margin)
    .centerYEqualToView(contentView)
    .heightIs(20);
    [_nameLabel setSingleLineAutoResizeWithMaxWidth:200];
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
