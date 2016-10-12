//
//  ZWUMUserFeedHeader.m
//  Qimokaola
//
//  Created by Administrator on 2016/10/12.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUMUserFeedHeader.h"

@implementation ZWUMUserFeedHeader

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundView = ({
        UIView * view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    
    self.width = kScreenW;
}

@end
