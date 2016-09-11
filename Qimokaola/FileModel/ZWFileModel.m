//
//  ZWFileModel.m
//
//  Created by Administrator  on 16/4/4
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "ZWFileModel.h"
#import "ZWOldFolder.h"


NSString *const kZWFileModelPath = @"path";
NSString *const kZWFileModelFiles = @"files";
NSString *const kZWFileModelBase = @"base";
NSString *const kZWFileModelFolders = @"folders";


@interface ZWFileModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ZWFileModel

@synthesize path = _path;
@synthesize files = _files;
@synthesize base = _base;
@synthesize folders = _folders;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.path = [self objectOrNilForKey:kZWFileModelPath fromDictionary:dict];
            self.files = [self objectOrNilForKey:kZWFileModelFiles fromDictionary:dict];
            self.base = [self objectOrNilForKey:kZWFileModelBase fromDictionary:dict];
    NSObject *receivedZWFolders = [dict objectForKey:kZWFileModelFolders];
    NSMutableArray *parsedZWFolders = [NSMutableArray array];
    if ([receivedZWFolders isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedZWFolders) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedZWFolders addObject:[ZWOldFolder modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedZWFolders isKindOfClass:[NSDictionary class]]) {
       [parsedZWFolders addObject:[ZWOldFolder modelObjectWithDictionary:(NSDictionary *)receivedZWFolders]];
    }

    self.folders = [NSArray arrayWithArray:parsedZWFolders];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.path forKey:kZWFileModelPath];
    NSMutableArray *tempArrayForFiles = [NSMutableArray array];
    for (NSObject *subArrayObject in self.files) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForFiles addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForFiles addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForFiles] forKey:kZWFileModelFiles];
    [mutableDict setValue:self.base forKey:kZWFileModelBase];
    NSMutableArray *tempArrayForFolders = [NSMutableArray array];
    for (NSObject *subArrayObject in self.folders) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForFolders addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForFolders addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForFolders] forKey:kZWFileModelFolders];

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

    self.path = [aDecoder decodeObjectForKey:kZWFileModelPath];
    self.files = [aDecoder decodeObjectForKey:kZWFileModelFiles];
    self.base = [aDecoder decodeObjectForKey:kZWFileModelBase];
    self.folders = [aDecoder decodeObjectForKey:kZWFileModelFolders];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_path forKey:kZWFileModelPath];
    [aCoder encodeObject:_files forKey:kZWFileModelFiles];
    [aCoder encodeObject:_base forKey:kZWFileModelBase];
    [aCoder encodeObject:_folders forKey:kZWFileModelFolders];
}

- (id)copyWithZone:(NSZone *)zone
{
    ZWFileModel *copy = [[ZWFileModel alloc] init];
    
    if (copy) {

        copy.path = [self.path copyWithZone:zone];
        copy.files = [self.files copyWithZone:zone];
        copy.base = [self.base copyWithZone:zone];
        copy.folders = [self.folders copyWithZone:zone];
    }
    
    return copy;
}


@end
