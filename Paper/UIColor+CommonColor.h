//
//  UIColor+CommonColor.h
//  Paper
//
//  Created by Administrator on 15/10/9.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CommonColor)

+ (instancetype)universalColor;

//颜色转为图片
- (UIImage *) parseToImage;

@end
