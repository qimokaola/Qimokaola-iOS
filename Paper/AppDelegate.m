//
//  AppDelegate.m
//  Paper
//
//  Created by Administrator on 15/10/8.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "MobClick.h"
#import "JSPatch/JSPatch.h"
#import "JPUSHService.h"
#import "ZWUtilsCenter.h"
#import "ZWDownloadCenter.h"
#import "ZWAdvertisementView.h"
#import "UMCommunity.h"
#import "YYFPSLabel.h"
#import "ZWLoginAndRegisterViewController.h"
#import "ZWTabBarController.h"
#import "ReactiveCocoa.h"
#import "ZWNetworkingManager.h"
#import "NSObject+YYModel.h"
#import "ZWAdvertisement.h"

@interface AppDelegate () <UIAlertViewDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //__weak __typeof(self) weakSelf = self;
    
    application.applicationIconBadgeNumber = 0;
    
    
    //JSPatch
    [JSPatch startWithAppKey:@"c0e20e35c39ad9b8"];
#ifdef DEBUG
    NSLog(@"DEBUG MODE");
    [JSPatch setupDevelopment];
#endif
    [JSPatch sync];
    
    //极光推送
    [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                      UIUserNotificationTypeSound |
                                                      UIUserNotificationTypeAlert)
                                          categories:nil];
    [JPUSHService setupWithOption:launchOptions appKey:@"2ce293670c48d980e31d27c8" channel:@"App Store" apsForProduction:YES];
    
    //初始化友盟SDK
    [UMSocialData setAppKey:@"561e48d167e58e12fd001243"];
    [MobClick startWithAppkey:@"561e48d167e58e12fd001243" reportPolicy:BATCH channelId:nil];
    
    
    //友盟微社区
    // 注：AppSecret要与AppKey匹配
    [UMCommunity setAppKey:@"561e48d167e58e12fd001243" withAppSecret:@"5371d1d9d2c3821a0d8707cf2eb3f394"];

    //初始化QQ分享SDK
    [UMSocialQQHandler setQQWithAppId:@"1104906908" appKey:@"F3gD6ULgbrpPSqqF" url:@"http://www.baidu.com"];
    
    
    //0.5秒后开始监听
    [self performSelector:@selector(monitorNetworkStatus) withObject:nil afterDelay:0.5f];
    
    
    
    
    //创建数据库队列
    self.DBQueue = [FMDatabaseQueue databaseQueueWithPath:[[ZWUtilsCenter documentDirectory] stringByAppendingPathComponent:@"Download_Info.db"]];
    [self.DBQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS download_info (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, course TEXT, link TEXT, type TEXT, size TEXT, time TEXT)";
            BOOL res = [db executeUpdate:sqlCreateTable];
            if (!res) {
                NSLog(@"建立download_info表失败");
            } else {
                NSLog(@"建立download_info表成功或表已存在");
            }
        }
    }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 88, 50, 10)];
    [fpsLabel sizeToFit];
    [application.keyWindow addSubview:fpsLabel];
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"LoginState"];
    //检测是否已经登录
    if (isLogin) {
        
        [self setWindowRootControllerWithClass:[ZWTabBarController class]];
        
        @weakify(self)
        [[[[self fetchADSignal] timeout:2.0 onScheduler:[RACScheduler mainThreadScheduler]] deliverOnMainThread] subscribeNext:^(ZWAdvertisement *ad) {
            
            @strongify(self)
            
            if (ad.res.enabled) {
                
                ZWAdvertisementView *adView = [[ZWAdvertisementView alloc] initWithWindow:self.window];
                adView.completion = ^{
                    NSLog(@"ad completion");
                };
                [adView showAdWithADRes:ad.res];
                
            } else {
                NSLog(@"do not need to show the ad");
            }
            
        } error:^(NSError *error) {
            
            @strongify(self)
            
            NSLog(@"there's one error occured: %@", error);
        }];
        
    } else {
        //显示登录，注册视图
        [self setWindowRootControllerWithClass:[ZWLoginAndRegisterViewController class]];
    }
    
    sleep(5.0);
    
    return YES;
}

- (void)setWindowRootControllerWithClass:(Class)clazz {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[clazz alloc] init];
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
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            
            [ZWUtilsCenter showHUDWithTitle:@"无网络连接" message:nil duration:1.5];
            
        }
        
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
}

//- (void)displayAd {
//    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSInteger localAdVersion = [userDefaults integerForKey:@"ad_version"];
//    
//    NSURL *infoInServer = [NSURL URLWithString:@"http://121.42.177.33/ads/ads.json"];
//    NSData *infoData = [NSData dataWithContentsOfURL:infoInServer];
//    
//    //infoData不为空，即成功获取到服务器信息
//    if (infoData != nil) {
//        
//        NSLog(@"获取广告信息成功");
//        
//        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:infoData options:NSJSONReadingAllowFragments error:nil];
// 
//        BOOL displayAd = [info[@"display"] boolValue];
//        
//        NSString *serverAdVersion = info[@"adversion"];
//        NSString *serverBuildVersion = info[@"buildversion"];
//        
//        NSString *localBuildVersion = [self buildVersion];
//        
//        if ([localBuildVersion intValue] < [serverBuildVersion intValue]) {
//            
//            NSLog(@"当前应用版本小于最新版本，提示用户");
//            
//            [self shwoUpdateView];
//            
//        }
//        
//        if (displayAd && [localBuildVersion intValue] <= [serverBuildVersion intValue]) {
//            
//            NSLog(@"显示广告");
//            
//            self.adImageView = [[UIImageView alloc]initWithFrame:self.window.frame];
//            [self.window addSubview:self.adImageView];
//            
//            if (localAdVersion != [serverAdVersion intValue]) {
//                
//                NSLog(@"本地广告版本与服务器版本不同，下载新广告图片");
//                
//                UIImage *adImage = [self downAdloadImage];
//        
//                self.adImageView.image = adImage;
//                
//                [userDefaults setInteger:[serverAdVersion integerValue] forKey:@"ad_version"];
//                
//            } else {
//                
//                NSLog(@"本地广告版本与服务器版本相同，使用本地图片");
//                
//                //若图片不存在则下载
//                if (! [[NSFileManager defaultManager] fileExistsAtPath:self.adImagePath]) {
//                    
//                    NSLog(@"广告图片不存在，重新下载");
//                    
//                    [self downAdloadImage];
//                }
//                
//                self.adImageView.image = [UIImage imageWithContentsOfFile:self.adImagePath];
//                
//            }
//            
//            [self removeAdViewWithTimeInterval:3.0];
//            
//        }  else {
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self sendShowAdFinishedNotification];
//            });
//            
//            NSLog(@"不显示广告");
//            [[UIApplication sharedApplication] setStatusBarHidden:NO];
//        
//        }
//        
//    } else {
//        
//        //infoData为空，则无网络或获取失败，则默认加载本地广告图像，若本地无广告图像，则跳过
//        
//        NSLog(@"获取广告信息失败，尝试加载本地广告信息");
//        
//        if ([[NSFileManager defaultManager] fileExistsAtPath:self.adImagePath]) {
//            
//            NSLog(@"本地广告信息存在，加载本地广告信息");
//            
//            self.adImageView = [[UIImageView alloc]initWithFrame:self.window.frame];
//            [self.window addSubview:self.adImageView];
//            
//            self.adImageView.image = [UIImage imageWithContentsOfFile:self.adImagePath];
//            
//            [self removeAdViewWithTimeInterval:3.0];
//            
//        } else {
//            NSLog(@"本地广告信息不存在，跳过显示广告");
//            [[UIApplication sharedApplication] setStatusBarHidden:NO];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self sendShowAdFinishedNotification];
//            });
//        }
//        
//    }
//    
//    
//}
//
//- (void)sendShowAdFinishedNotification {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"PapersShowAdFinished" object:nil];
//}
//
//- (void)removeAdViewWithTimeInterval:(double)time {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [[UIApplication sharedApplication] setStatusBarHidden:NO];
//        
//        [UIView animateWithDuration:0.3 animations:^{
//            
//            self.adImageView.alpha = 0.0;
//            
//        } completion:^(BOOL finished) {
//            
//            [self.adImageView removeFromSuperview];
//            
//            [self sendShowAdFinishedNotification];
//            
//        }];
//        
//    });
//}
//
//- (NSString *)buildVersion {
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    return [infoDictionary objectForKey:@"CFBundleVersion"];
//
//}
//
//- (void)shwoUpdateView {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到新版本，是否前往下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alertView show];
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1054613325"]];
//    }
//}
//
///**
// *  @author Administrator, 16-03-19 21:03:31
// *
// *  下载广告图片并储存
// *
// *  @return 广告图片
// */
//- (UIImage *)downAdloadImage {
//    NSLog(@"下载图片中...");
//    
//    NSURL *adImageURL = [NSURL URLWithString:@"http://121.42.177.33/ads/ads.png"];
//    NSData *adImageData = [NSData dataWithContentsOfURL:adImageURL];
//    UIImage *adImage = [UIImage imageWithData:adImageData];
//    
//    
//    NSLog(@"下载图片完成");
//    
//    [adImageData writeToFile:self.adImagePath atomically:YES];
//    
//    return adImage;
//}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [JPUSHService registerDeviceToken:deviceToken];
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    
    
    NSLog(@"----devicetoken------%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                       stringByReplacingOccurrencesOfString: @">" withString: @""]
                                      stringByReplacingOccurrencesOfString: @" " withString: @""]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    

        
        
        // 取得 APNs 标准信息内容
        NSDictionary *aps = [userInfo valueForKey:@"aps"];
        NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
        NSInteger badge = [[aps valueForKey:@"badge"] integerValue]; //badge数量
        NSString *sound = [aps valueForKey:@"sound"]; //播放的声音
        
        // 取得Extras字段内容
        NSString *customizeField1 = [userInfo valueForKey:@"customizeExtras"]; //服务端中Extras字段，key是自己定义的
        NSLog(@"content =[%@], badge=[%ld], sound=[%@], customize field  =[%@]",content,(long)badge,sound,customizeField1);
        
        // Required
        [JPUSHService handleRemoteNotification:userInfo];

    
}

////iOS 7 Remote Notification
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:  (NSDictionary *)userInfo fetchCompletionHandler:(void (^)   (UIBackgroundFetchResult))completionHandler {
//    
//    NSLog(@"this is iOS7 Remote Notification");
//    
//    // 取得 APNs 标准信息内容
//    NSDictionary *aps = [userInfo valueForKey:@"aps"];
//    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
//    NSInteger badge = [[aps valueForKey:@"badge"] integerValue]; //badge数量
//    NSString *sound = [aps valueForKey:@"sound"]; //播放的声音
//    
//    // 取得Extras字段内容
//    NSString *customizeField1 = [userInfo valueForKey:@"customizeExtras"]; //服务端中Extras字段，key是自己定义的
//    NSLog(@"content =[%@], badge=[%ld], sound=[%@], customize field  =[%@]",content,(long)badge,sound,customizeField1);
//    
//    // Required
//    [JPUSHService handleRemoteNotification:userInfo];
//    completionHandler(UIBackgroundFetchResultNewData);
//}


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
    
    [self.DBQueue close];
    
    //退出应用前保存所有未完成的任务
    //[[ZWDownloadCenter sharedDownloadCenter] saveAllDownloadTasksWhenAppTerminate];
}

@end
