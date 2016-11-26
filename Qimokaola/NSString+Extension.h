//
//  NSString+URLEncode.h
//  Qimokaola
//
//  Created by Administrator on 16/3/18.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

- (NSString *)URLEncodedString;

- (NSString *)URLDecodedString;


/**
 返回第一个字母（若字符串为中文 则返回第一次字的拼音的第一个字母)

 @return 首字母
 */
- (NSString *)firstWord;

@end
