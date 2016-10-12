//
//  ZWUserDetailViewController.h
//  Qimokaola
//
//  Created by Administrator on 2016/9/26.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UMCommunitySDK/UMComDataRequestManager.h>
#import <UMCommunitySDK/UMComSession.h>
#import <UMComDataStorage/UMComUser.h>
#import <UMComDataStorage/UMComImageUrl.h>
#import <UMComDataStorage/UMComFeed.h>

@interface ZWUserDetailViewController : UIViewController

@property (nonatomic, strong) UMComUser *umUser;

@end
