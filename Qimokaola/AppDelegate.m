//
//  AppDelegate.m
//  Qimokaola
//
//  Created by Administrator on 15/10/8.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "AppDelegate.h"
#import "ZWPathTool.h"
#import "ZWAdvertisementView.h"
#import "ZWLoginAndRegisterViewController.h"
#import "ZWTabBarController.h"
#import "ZWNetworkingManager.h"
#import "ZWAdvertisement.h"
#import "ZWHUDTool.h"
#import "ZWLoginViewController.h"
#import "ZWAPITool.h"
#import "ZWUserManager.h"
#import "UIColor+Extension.h"
#import "ZWUploadFileViewController.h"
#import "ZWBrowserTool.h"

#import <AXWebViewController/AXWebViewController.h>

#import <UMSocialCore/UMSocialCore.h>
#import <JSPatchPlatform/JSPatch.h>
#import "UMMobClick/MobClick.h"
#import <UMCommunitySDK/UMCommunitySDK.h>
#import "UMPushSDK_1.4.0/UMessage.h"
#import "ReactiveCocoa.h"
#import <YYKit/YYKit.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    __weak __typeof(self) weakSelf = self;
    
    application.applicationIconBadgeNumber = 0;
    
    //JSPatch
    [JSPatch startWithAppKey:@"c0e20e35c39ad9b8"];
#ifdef DEBU
    [JSPatch setupDevelopment];
#endif
    [JSPatch sync];
    
    // 初始化友盟推送
    //设置 AppKey 及 LaunchOptions
    [UMessage startWithAppkey:@"57b447c6e0f55af52e000e0b" launchOptions:launchOptions];
    
    //1.3.0版本开始简化初始化过程。如不需要交互式的通知，下面用下面一句话注册通知即可。
    [UMessage registerForRemoteNotifications];
    
    //iOS10必须加下面这段代码。
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    UNAuthorizationOptions types10 = UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:types10 completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //点击允许
            //这里可以添加一些自己的逻辑
        } else {
            //点击不允许
            //这里可以添加一些自己的逻辑
        }
    }];
    
    [UMessage setLogEnabled:YES];

    // 初始化友盟微社区SDK
    [UMCommunitySDK setAppkey:@"57b447c6e0f55af52e000e0b" withAppSecret:@"6133327b2d31ba894071c89b186284ac"];
    
    //初始化友盟应用分析SDK
    UMConfigInstance.appKey = @"561e48d167e58e12fd001243";
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
    
    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"57b447c6e0f55af52e000e0b"];
    //设置分享到QQ互联的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1104906908"  appSecret:@"F3gD6ULgbrpPSqqF" redirectURL:@"http://mobile.umeng.com/social"];

//    //初始化QQ分享SDK
//    [UMSocialData setAppKey:@"57b447c6e0f55af52e000e0b"];
//    [UMSocialQQHandler setQQWithAppId:@"1104906908" appKey:@"F3gD6ULgbrpPSqqF" url:@"http://www.baidu.com"];
    
    //0.5秒后开始监听网络变化
    [self performSelector:@selector(monitorNetworkStatus) withObject:nil afterDelay:0.5f];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kUserNeedLoginNotification object:nil] deliverOnMainThread] subscribeNext:^(id x) {
        [[ZWUserManager sharedInstance] logoutStudentCircle];
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
        [weakSelf presentLoginViewController];
        
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kShowAdNotification object:nil] subscribeNext:^(NSNotification *notification) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ZWBrowserTool openWebAddress:notification.userInfo[@"url"]];
        });
    }];
    
    [[UINavigationBar appearance] setBarTintColor:defaultBlueColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                           NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightBold],
                                                           }];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [[UITabBar appearance] setBackgroundImage:[[UIColor whiteColor] parseToImage]];
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"LoginState"];
    //检测是否已经登录
    if (isLogin) {
        [self setWindowRootControllerWithClass:[ZWTabBarController class]];
        [[[[self fetchADSignal] timeout:5.0 onScheduler:[RACScheduler mainThreadScheduler]] deliverOnMainThread] subscribeNext:^(ZWAdvertisement *ad) {
            if (ad.enabled) {
                ZWAdvertisementView *adView = [[ZWAdvertisementView alloc] initWithWindow:weakSelf.window];
                [adView showAdvertisement:ad];
            }
        } error:^(NSError *error) {
        }];
    } else {
        //显示登录，注册视图
        [self setWindowRootControllerWithClass:[ZWLoginAndRegisterViewController class]];
    }
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
        [UIApplication sharedApplication].keyWindow.rootViewController = [[ZWLoginAndRegisterViewController alloc] init];
    });
}

- (RACSignal *)fetchADSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [ZWAPIRequestTool requestSBInfo:^(id response, BOOL success) {
            if (success && [[response objectForKey:kHTTPResponseCodeKey] intValue] == 0) {
                ZWAdvertisement *ad = [ZWAdvertisement modelWithJSON:[response objectForKey:kHTTPResponseResKey]];
                [subscriber sendNext:ad];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:response];
            }
        }];
        return nil;
    }];
}

#pragma mark 检测网络变化,无网络时应用内全局提示
- (void)monitorNetworkStatus {

    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
//        NSString *networkCondition;
//        if (status == AFNetworkReachabilityStatusNotReachable) {
//            networkCondition = @"网络连接已断开";
//        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
//            networkCondition=  @"使用蜂窝数据流量";
//        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
//            networkCondition = @"使用Wi-Fi连接";
//        } else {
//            networkCondition = @"未知的网络连接";
//        }
//        
//        [ZWHUDTool showHUDWithTitle:networkCondition message:nil duration:kShowHUDShort];
//        
//        if (status != AFNetworkReachabilityStatusNotReachable) {
//            NSLog(@"change");
//            [[ZWUserManager sharedInstance] loginStudentCircle];
//        }
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [ZWHUDTool showHUDWithTitle:@"网络连接已断开" message:nil duration:kShowHUDShort];
        } else {
            //网络改变之后且有网的情况下重新登录学生圈
            [[ZWUserManager sharedInstance] loginStudentCircle];
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
//    NSLog(@"%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
//                  stringByReplacingOccurrencesOfString: @">" withString: @""]
//                 stringByReplacingOccurrencesOfString: @" " withString: @""]);
    // 1.2.7版本开始不需要用户再手动注册devicetoken，SDK会自动注册
    //[UMessage registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"%@", userInfo);
    //关闭友盟自带的弹出框
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@ no completion", userInfo);
    //关闭友盟自带的弹出框
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //关闭友盟自带的弹出框
        [UMessage setAutoAlert:NO];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于前台时的本地推送接受
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于后台时的本地推送接受
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError");
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"ios 8");
    NSLog(@"openURL:%@ sourceApplication:%@ annotation:%@", url, sourceApplication, annotation);
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        if (![ZWUserManager sharedInstance].isLogin) {
            [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
            [ZWHUDTool showHUDWithTitle:@"只有在登录状态下才能上传文件哦" message:nil duration:kShowHUDMid];
        } else {
            [self presentUploadViewWithFileName:url];
        }
    }
    return  [[UMSocialManager defaultManager] handleOpenURL:url];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    NSLog(@"openURL:%@ options:%@", url, options);
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        if (![ZWUserManager sharedInstance].isLogin) {
            [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
            [ZWHUDTool showHUDWithTitle:@"只有在登录状态下才能上传文件哦" message:nil duration:kShowHUDMid];
        } else {
            [self presentUploadViewWithFileName:url];
        }
    }
    return  [[UMSocialManager defaultManager] handleOpenURL:url];
}

- (void)presentUploadViewWithFileName:(NSURL *)url {

    ZWUploadFileViewController *uploader = [[ZWUploadFileViewController alloc] init];
    uploader.fileUrl = url;
    [(UINavigationController *)[(UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController selectedViewController] pushViewController:uploader animated:YES];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"handleOpenURL: %@", url);
    return  [[UMSocialManager defaultManager] handleOpenURL:url];
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
}

@end
