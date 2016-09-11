//
//  ZWFileDetailController.h
//  Qimokaola
//
//  Created by Administrator on 16/4/13.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWOldFile.h"

typedef void(^DownloadCompltionHandler)(void);

@interface ZWOldFileDetailViewController : UIViewController

- (instancetype)initWithFile:(ZWOldFile *)file;

@property (nonatomic, copy) DownloadCompltionHandler downloadCompletionHandler;

@end 
