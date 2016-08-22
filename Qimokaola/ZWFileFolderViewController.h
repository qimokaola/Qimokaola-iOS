//
//  ZWFileFolderViewController.h
//  Qimokaola
//
//  Created by Administrator on 16/4/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModels.h"

@interface ZWFileFolderViewController : UITableViewController

- (instancetype)initWithChild:(ZWChild *)child andName:(NSString *)name;

+ (void)setBasePath:(NSString *)basePath;

@end
