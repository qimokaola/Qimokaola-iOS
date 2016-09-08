//
//  ZWNewFeedViewController.h
//  Qimokaola
//
//  Created by Administrator on 16/9/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UMComDataStorage/UMComTopic.h>

@interface ZWCreateNewFeedViewController : UIViewController

@property (nonatomic, copy) void(^CompletionBlock)();

@property (nonatomic, strong) NSString *topicID;

@end
