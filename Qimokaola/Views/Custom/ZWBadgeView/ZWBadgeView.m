//
//  ZWBadgeView.m
//  Qimokaola
//
//  Created by Administrator on 2017/3/3.
//  Copyright © 2017年 Administrator. All rights reserved.
//

#import "ZWBadgeView.h"

static const CGFloat fontSize = 13;

@implementation ZWBadgeView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.font = [UIFont systemFontOfSize:fontSize];
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor redColor];
    self.clipsToBounds = true;
}

- (void)setBadgeCount:(NSInteger)badgeCount {
    // Add count to label and size to fit
    
    _badgeCount = badgeCount;
    if (_badgeCount <= 0) {
        self.alpha = 0.0;
        return;
    } else {
        self.alpha = 1.0;
    }
    
    self.text = [NSString stringWithFormat:@"%@", @(_badgeCount)];
    [self sizeToFit];
    
    // Adjust frame to be square for single digits or elliptical for numbers > 9
    CGRect frame = self.frame;
    frame.size.height += (int)(0.2*fontSize);
    frame.size.width = (_badgeCount <= 9) ? frame.size.height : frame.size.width + (int)fontSize;
    self.frame = frame;
    // Set radius and clip to bounds
    self.layer.cornerRadius = frame.size.height/2.0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
