//
//  ZWBrowserViewController.h
//  Paper
//
//  Created by Administrator on 15/12/8.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  NS_OPTIONS(NSInteger, ZWBrowserLoadType) {
    ZWBrowserLoadTypeFromServices,
    ZWBrowserLoadTypeFromOthers
};

@interface ZWBrowserViewController : UIViewController

- (instancetype)initWithURLString:(NSString *)URLString titleString:(NSString *)titleString loadType:(ZWBrowserLoadType)loadType;


@end
