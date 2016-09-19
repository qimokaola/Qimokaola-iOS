//
//  ZWFeedComposeTextParser.h
//  Qimokaola
//
//  Created by Administrator on 2016/9/15.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYKit/YYKit.h>

@interface ZWFeedComposeTextParser : NSObject <YYTextParser>

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightTextColor;

@end
