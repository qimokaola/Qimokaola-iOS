//
//  ZWFileDetailController.h
//  Paper
//
//  Created by Administrator on 16/4/13.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWFile.h"

typedef void(^DownloadCompltionHandler)(void);

@interface ZWFileDetailViewController : UIViewController

- (instancetype)initWithFile:(ZWFile *)file;

@property (nonatomic, copy) DownloadCompltionHandler downloadCompletionHandler;

@end 
