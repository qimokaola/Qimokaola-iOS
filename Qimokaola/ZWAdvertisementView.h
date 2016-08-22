//
//  ZWAdvertisementView.h
//  Qimokaola
//
//  Created by Administrator on 16/7/12.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWAdvertisement.h"

typedef void(^ADCompleteBlock)(void);

@interface ZWAdvertisementView : UIView

@property (nonatomic, copy) ADCompleteBlock completion;

- (instancetype)initWithWindow:(UIWindow *)window;

//按照广告具体信息显示广告内容以及决定可点击与否
- (void)showAdWithInfo:(NSDictionary *)info;

- (void)showAdWithADRes:(ZWAdvertisementResource *)res;

- (void)checkAD;

@end
