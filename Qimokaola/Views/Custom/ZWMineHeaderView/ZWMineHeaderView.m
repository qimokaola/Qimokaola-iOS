//
//  ZWMineHeaderView.m
//  Qimokaola
//
//  Created by Administrator on 2017/3/2.
//  Copyright © 2017年 Administrator. All rights reserved.
//

#import "ZWMineHeaderView.h"
#import "ZWAPITool.h"

#import <YYKit/YYKit.h>

#define IS_SCREEN_SIZE_LE_4_7 (kScreenH >= 667)

@interface ZWMineHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *schoolNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;

@end

@implementation ZWMineHeaderView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.frame = CGRectMake(0, 0, kScreenW, kScreenH * (IS_SCREEN_SIZE_LE_4_7 ? 0.2 : 0.23));
        NSLog(@"%@", NSStringFromCGRect([UIScreen mainScreen].bounds));
    }
    return self;
}

+ (instancetype)mineHeaderViewInstance {
    return [[NSBundle mainBundle] loadNibNamed:@"ZWMineHeaderView" owner:self options:nil][0];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //self.backgroundColor = defaultBlueColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height / 2;
    self.avatarImageView.layer.masksToBounds = YES;
}

- (void)setUser:(ZWUser *)user {
    _user = user;
    
    [self.avatarImageView setImageURL:[NSURL URLWithString:[[[ZWAPITool base] stringByAppendingString:@"/"] stringByAppendingString:_user.avatar_url]]];
    self.nicknameLabel.text  = _user.nickname;
    self.schoolNameLabel.text = _user.collegeName;
    NSString *genderImageName = [_user.gender isEqualToString:@"男"] ? @"icon_gender_male" : @"icon_gender_female";
    self.genderImageView.image = [UIImage imageNamed:genderImageName];
}

@end
