//
//  ZWAccount.m
//  Qimokaola
//
//  Created by Administrator on 2016/11/30.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWAccount.h"

#import <YYKit/YYKit.h>

#import "ZWPathTool.h"

#define kAESKey @"7gy2r78t2bh9p8uI"
#define kAccoutStorageFileName @"Account.dat"

@implementation ZWAccount

- (void)encodeWithCoder:(NSCoder *)aCoder { [self modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self modelCopy]; }
- (NSUInteger)hash { return [self modelHash]; }
- (BOOL)isEqual:(id)object { return [self modelIsEqual:object]; }
- (NSString *)description { return [self modelDescription]; }

- (BOOL)writeData {
    NSData *rawData = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSData *encodedData = [rawData aes256EncryptWithKey:[kAESKey dataUsingEncoding:NSUTF8StringEncoding] iv:nil];
    return [encodedData writeToFile:[[ZWPathTool accountDirectory] stringByAppendingPathComponent:kAccoutStorageFileName] atomically:YES];
}

- (BOOL)readData {
    NSData *rawData = [NSData dataWithContentsOfFile:[[ZWPathTool accountDirectory] stringByAppendingPathComponent:kAccoutStorageFileName]];
    NSData *decodedData = [rawData aes256DecryptWithkey:[kAESKey dataUsingEncoding:NSUTF8StringEncoding] iv:nil];
    ZWAccount *account = (ZWAccount *)[NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    self.account = account.account;
    self.pwd = account.pwd;
    return account != nil;  

}

@end
