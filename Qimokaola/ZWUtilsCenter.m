//
//  ZWUtilsCenter.m
//  Qimokaola
//
//  Created by Administrator on 16/4/6.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUtilsCenter.h"
#import "AFNetworkReachabilityManager.h"


static NSArray *array;

@implementation ZWUtilsCenter

+ (NSString *)parseTypeWithString:(NSString *)type {
    
    type = [type lowercaseString];
    
    if (array == nil) {
        array = @[@"7z", @"doc", @"docx", @"jpg", @"pdf", @"png",
                  @"ppt", @"pptx", @"rar", @"txt", @"video",
                  @"xls", @"zip", @"rtf", @"wps", @"dps", @"et", @"xlt"];
    }
    
    if ([array containsObject:type]) {
        return type;
    }
    
    return @"other";
}

+ (NSString *)typeWithName:(NSString *)name {
    
    NSRange range = [name rangeOfString:@"." options:NSBackwardsSearch];
    NSString *type = [name substringWithRange:NSMakeRange(range.location + 1, [name length] - range.location - 1)];
    return type;
}

+ (NSString *)sizeWithDouble:(double)size {
    NSString *sizeContent = nil;
    
    //最大允许至GB级别
    if (size < 1024) {
        sizeContent = [NSString stringWithFormat:@"%.2fKB", size];
    } else if (size < 1024 * 1024) {
        sizeContent = [NSString stringWithFormat:@"%.2fMB", size / 1024.0];
    } else {
        sizeContent = [NSString stringWithFormat:@"%.2fGB", size / 1024.0 / 1024.0];
    }
    
    return sizeContent;
}

+ (NSString *)downloadDirectory {
    NSString *directory = [[self documentDirectory] stringByAppendingPathComponent:@"Download"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return directory;
}

+ (NSString *)resumeDataDirectory {
    NSString *resumeDataDirectory = [[self documentDirectory] stringByAppendingPathComponent:@"ResumeData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:resumeDataDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resumeDataDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return resumeDataDirectory;
}

+ (NSString *)adImageDirectory {
    NSString *adImageDirectory = [[self documentDirectory] stringByAppendingPathComponent:@"AdImage"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:adImageDirectory])  {
        [[NSFileManager defaultManager] createDirectoryAtPath:adImageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return adImageDirectory;
}

+ (NSString *)appCacheDirectory {
    NSString *cachaDirectory = [[self cacheDirectory] stringByAppendingPathComponent:@"AppCache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachaDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachaDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return cachaDirectory;
}

+ (NSString *)cacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

+ (NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

+ (BOOL)checkNetWorkStateAvailable {
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [self showHUDWithTitle:@"无法下载" message:@"无网络连接" duration:2.0];
        return NO;
    }
    return YES;
}


+ (void)showHUDWithTitle:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration {
    [self showHUDInView:[[UIApplication sharedApplication].windows lastObject] withTitle:title message:message duration:duration];
}

+ (void)showHUDInView:(UIView *)view withTitle:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    //[hud.superview bringSubviewToFront:hud];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = title;
    hud.detailsLabel.text = message;
   // hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:duration];
}

@end
