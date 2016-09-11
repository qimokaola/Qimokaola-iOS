//
//  ZWFiles.m
//
//  Created by Administrator  on 16/4/4
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "ZWOldFile.h"
#import "FMDB.h"
#import "AppDelegate.h"
#import "ZWFileTool.h"


NSString *const kZWFilesName = @"name";
NSString *const kZWFilesSize = @"size";
NSString *const kZWFilePath = @"path";
NSString *const kZWFilesType = @"type";
NSString *const kZWFilesUrl = @"url";
NSString *const kZWFilesDownload = @"download";

static FMDatabaseQueue *DBQueue;
static NSString *const querySQL = @"SELECT * FROM download_info WHERE link = '%@'";

@interface ZWOldFile ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ZWOldFile

@synthesize name = _name;
@synthesize type = _type;
@synthesize path = _path;
@synthesize url = _url;
@synthesize size = _size;
@synthesize download = _download;

+ (instancetype)fileWithDownloadInfo:(ZWDownloadInfoModel *)model {
    ZWOldFile *file = [[self alloc] init];
    file.name = model.name;
    file.type = model.type;
    file.path = model.course;
    file.url = model.link;
    file.size = model.size;
    file.download = YES;
    return file;
}

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict URLString:(NSString *)URLString filePath:(NSString *)filePath
{
    
    return [[self alloc] initWithDictionary:dict URLString:URLString filePath:filePath];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict URLString:(NSString *)URLString filePath:(NSString *)filePath
{
    self = [super init];
    
    __weak __typeof(self) weakSelf = self;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DBQueue = [(AppDelegate *)[UIApplication sharedApplication].delegate DBQueue];
    });
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.name = [self objectOrNilForKey:kZWFilesName fromDictionary:dict];
        self.size = [ZWFileTool sizeWithDouble:[[self objectOrNilForKey:kZWFilesSize fromDictionary:dict] doubleValue]];
        self.path = filePath;
        self.type = [ZWFileTool typeWithName:self.name];
        self.url = [NSString stringWithFormat:@"%@%@", URLString, self.name];
        
        [DBQueue inDatabase:^(FMDatabase *db) {
            
            if ([db open]) {
                FMResultSet *results = [db executeQuery:[NSString stringWithFormat:querySQL, self.url]];
                weakSelf.download = [results next];
                [results close];
            } else {
                weakSelf.download = NO;
            }
            
        }];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.name forKey:kZWFilesName];
    [mutableDict setValue:self.size forKey:kZWFilesSize];
    [mutableDict setValue:self.path forKey:kZWFilePath];
    [mutableDict setValue:self.type forKey:kZWFilesType];
    [mutableDict setValue:self.url forKey:kZWFilesUrl];
    [mutableDict setValue:[NSNumber numberWithBool:self.download] forKey:kZWFilesDownload];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.name = [aDecoder decodeObjectForKey:kZWFilesName];
    self.size = [aDecoder decodeObjectForKey:kZWFilesSize];
    self.path = [aDecoder decodeObjectForKey:kZWFilePath];
    self.type = [aDecoder decodeObjectForKey:kZWFilesType];
    self.url  = [aDecoder decodeObjectForKey:kZWFilesUrl];
    self.download = [aDecoder decodeBoolForKey:kZWFilesDownload];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_name forKey:kZWFilesName];
    [aCoder encodeObject:_size forKey:kZWFilesSize];
    [aCoder encodeObject:_path forKey:kZWFilePath];
    [aCoder encodeObject:_type forKey:kZWFilesType];
    [aCoder encodeObject:_url forKey:kZWFilesUrl];
    [aCoder encodeBool:_download forKey:kZWFilesDownload];
}

- (id)copyWithZone:(NSZone *)zone
{
    ZWOldFile *copy = [[ZWOldFile alloc] init];
    
    if (copy) {

        copy.name = [self.name copyWithZone:zone];
        copy.size = [self.size copyWithZone:zone];
        copy.path = [self.path copyWithZone:zone];
        copy.type = [self.type copyWithZone:zone];
        copy.url = [self.url copyWithZone:zone];
        copy.download = self.download;
    }
    
    return copy;
}


@end
