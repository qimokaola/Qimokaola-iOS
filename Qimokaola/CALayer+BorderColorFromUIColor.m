//
//  CALayer+BorderColorFromUIColor.m
//  Qimokaola
//
//  Created by Administrator on 16/7/20.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "CALayer+BorderColorFromUIColor.h"

@implementation CALayer (BorderColorFromUIColor)

- (void)setBorderColorFromUIColor:(UIColor *)borderColorFromUIColor {
    objc_setAssociatedObject(self, @selector(borderColorFromUIColor), borderColorFromUIColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.borderColor = borderColorFromUIColor.CGColor;
}

- (UIColor *)borderColorFromUIColor {
    return objc_getAssociatedObject(self, @selector(borderColorFromUIColor));
}

@end
