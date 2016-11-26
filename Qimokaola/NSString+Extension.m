//
//  NSString+URLEncode.m
//  Qimokaola
//
//  Created by Administrator on 16/3/18.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

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

- (NSString *)firstWord {
    NSMutableString *muStr = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)muStr, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)muStr, NULL, kCFStringTransformStripCombiningMarks, NO);
    if (muStr.length > 0) {
        NSString *res = [[muStr uppercaseString] substringToIndex:1];
        return res;
    }
    return @"";
}

@end
