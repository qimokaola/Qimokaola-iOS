//
//  AppDelegate.m
//  Qimokaola
//
//  Created by Administrator on 15/10/8.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "AppDelegate.h"
#import "ZWPathTool.h"
#import "ZWDownloadCenter.h"
#import "ZWAdvertisementView.h"
#import "YYFPSLabel.h"
#import "ZWLoginAndRegisterViewController.h"
#import "ZWTabBarController.h"
#import "ZWNetworkingManager.h"
#import "ZWAdvertisement.h"
#import "ZWHUDTool.h"
#import "ZWLoginViewController.h"
#import "ZWAPITool.h"
#import "ZWUserManager.h"

#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "JSPatch/JSPatch.h"
#import "UMMobClick/MobClick.h"
#import <UMCommunitySDK/UMCommunitySDK.h>
#import "UMPushSDK_1.3.0/UMessage.h"
#import "ReactiveCocoa.h"
#import <YYKit/YYKit.h>
#import <UMCommunitySDK/UMComDataRequestManager.h>
#import <UMCommunitySDK/UMComSession.h>

@interface AppDelegate () {
    // 记录是否第一次进入，用以决定是否显示网络变化提示 若第一次进入且无网络才显示网络情况
    BOOL firstEnter;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    __weak __typeof(self) weakSelf = self;
    
    firstEnter = YES;
    
    application.applicationIconBadgeNumber = 0;
    
    //JSPatch
    [JSPatch startWithAppKey:@"c0e20e35c39ad9b8"];
#ifdef DEBUG
    NSLog(@"DEBUG MODE");
    [JSPatch setupDevelopment];
#endif
    [JSPatch sync];
    
    // 初始化友盟推送
    //设置 AppKey 及 LaunchOptions
    [UMessage startWithAppkey:@"57b447c6e0f55af52e000e0b" launchOptions:launchOptions];
    //1.3.0版本开始简化初始化过程。如不需要交互式的通知，下面用下面一句话注册通知即可。
    [UMessage registerForRemoteNotifications];
    [UMessage setLogEnabled:YES];

    // 初始化友盟微社区SDK
    [UMCommunitySDK setAppkey:@"57b447c6e0f55af52e000e0b" withAppSecret:@"6133327b2d31ba894071c89b186284ac"];
    
    //初始化友盟应用分析SDK
    UMConfigInstance.appKey = @"561e48d167e58e12fd001243";
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！

    //初始化QQ分享SDK
    [UMSocialData setAppKey:@"57b447c6e0f55af52e000e0b"];
    [UMSocialQQHandler setQQWithAppId:@"1104906908" appKey:@"F3gD6ULgbrpPSqqF" url:@"http://www.baidu.com"];
    
    //0.5秒后开始监听网络变化
    [self performSelector:@selector(monitorNetworkStatus) withObject:nil afterDelay:0.5f];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"LoginState"];
    //检测是否已经登录
    if (isLogin) {
        [self setWindowRootControllerWithClass:[ZWTabBarController class]];
        [[[[self fetchADSignal] timeout:2.0 onScheduler:[RACScheduler mainThreadScheduler]] deliverOnMainThread] subscribeNext:^(ZWAdvertisement *ad) {
            if (ad.res.enabled) {
                ZWAdvertisementView *adView = [[ZWAdvertisementView alloc] initWithWindow:weakSelf.window];
                adView.completion = ^{
                    NSLog(@"ad completion");
                };
                [adView showAdWithADRes:ad.res];
                
            }
        } error:^(NSError *error) {
        }];
    } else {
        //显示登录，注册视图
        [self setWindowRootControllerWithClass:[ZWLoginAndRegisterViewController class]];
    }

    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kUserNeedLoginNotification object:nil] deliverOnMainThread] subscribeNext:^(id x) {
        // 如果学生圈已经登录 则登出
        if ([UMComSession sharedInstance].isLogin) {
            [[UMComSession sharedInstance] userLogout];
        }
        [weakSelf presentLoginViewController];
    }];
    
    // 在确认存在本地用户与用户登录成功之后执行登录学生圈
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kLocalUserLoginStateGuranteedNotification object:nil] deliverOnMainThread] subscribeNext:^(id x) {
        // 本地用户存在，执行学生圈登录流程"
        [weakSelf loginTheStudentCircle];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kUserLoginSuccessNotification object:nil] deliverOnMainThread] subscribeNext:^(id x) {
        // 用户登录成功，执行学生圈登录流程
        [weakSelf loginTheStudentCircle];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kUserLogoutSuccessNotification object:nil] subscribeNext:^(id x) {
        [[ZWUserManager sharedInstance] logoutStudentCircle];
    }];
    
    [[UINavigationBar appearance] setBarTintColor:RGB(80,140,238)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                           NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightBold],
                                                           }];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
#ifdef DEBUG
    YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 100, 0, 0)];
    [fpsLabel sizeToFit];
    [self.window addSubview:fpsLabel];
#endif
    
    return YES;
}

- (void)setWindowRootControllerWithClass:(Class)clazz {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[clazz alloc] init];
}

/**
 执行登录学生圈流程
 */
- (void)loginTheStudentCircle {
    // 登录学生圈
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ZWUserManager sharedInstance] loginStudentCircle];
    });
    
}

- (void)presentLoginViewController {
    [ZWHUDTool showHUDWithTitle:@"登录状态失效 请重新登录" message:nil duration:kShowHUDMid];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDMid * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ZWLoginViewController *loginViewController = [[ZWLoginViewController alloc] init];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginViewController] animated:YES completion:nil];
    });
}

- (RACSignal *)fetchADSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [ZWNetworkingManager getWithURLString:@"http://121.42.177.33:8080/api/sb/getSB"
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          
                                          ZWAdvertisement *ad = [ZWAdvertisement modelWithJSON:responseObject];
                                          [subscriber sendNext:ad];
                                          [subscriber sendCompleted];
                                          
                                      }
                                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          
                                          [subscriber sendError:error];
                                          
                                      }];
        
        return nil;
    }];
}

#pragma mark 检测网络变化,无网络时应用内全局提示
- (void)monitorNetworkStatus {

    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        // 若是首次进入且网络可用则不显示网络状态 非可用才提示
        if (firstEnter && status != AFNetworkReachabilityStatusNotReachable) {
            firstEnter = NO;
            return;
        }
        
        NSString *networkCondition;
        if (status == AFNetworkReachabilityStatusNotReachable) {
            networkCondition = @"网络连接已断开";
        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
            networkCondition=  @"使用蜂窝数据流量";
        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            networkCondition = @"使用Wi-Fi连接";
        } else {
            networkCondition = @"未知的网络连接";
        }
        
        [ZWHUDTool showHUDWithTitle:networkCondition message:nil duration:kShowHUDShort];
        
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
}





- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    

    [UMessage didReceiveRemoteNotification:userInfo];
    
}



- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    
  return  [UMSocialSnsService handleOpenURL:url];

}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {

}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"App Terminate");
    
//    [self.DBQueue close];
    
    //退出应用前保存所有未完成的任务
    //[[ZWDownloadCenter sharedDownloadCenter] saveAllDownloadTasksWhenAppTerminate];
}

@end
