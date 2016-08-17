//
//  NSString+URLEncode.m
//  Paper
//
//  Created by Administrator on 16/3/18.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode)

- (NSString *)URLEncodedString
{
    NSString*
    outputStr = (__bridge_transfer NSString *)
        CFURLCreateStringByAddingPercentEscapes(NULL,
                                                (__bridge CFStringRef)self,
                                                NULL,
                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                kCFStringEncodingUTF8);
    
    
    return outputStr;
}
//
//- (NSString *)URLDecoededString {
//        NSMutableString *outputStr = [NSMutableString stringWithString:self];
//        [outputStr replaceOccurrencesOfString:@"+"
//                                   withString:@""
//                                      options:NSLiteralSearch
//                                        range:NSMakeRange(0,
//                                            [outputStr length])];
//        
//        return
//        [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//}

- (NSString *)URLDecodedString 
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)self, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return decodedString;
}
@end
