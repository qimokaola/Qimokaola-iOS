//
//  ZWFileDetailViewController.h
//  Qimokaola
//
//  Created by Administrator on 16/9/11.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWFile.h"

/**
 *  @author Administrator, 16-09-11 19:09:29
 *
 *  显示文件详情
 */

@interface ZWFileDetailViewController : UIViewController

// 记录文件属于哪个课程
@property (nonatomic, strong) NSString *rootPath;
//@property (nonatomic, strong) ZWFile *file;

@end
