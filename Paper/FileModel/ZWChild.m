//
//  ZWChild.m
//
//  Created by Administrator  on 16/4/4
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "ZWChild.h"


NSString *const kZWChildPath = @"path";
NSString *const kZWChildFiles = @"files";
NSString *const kZWChildFolders = @"folders";


@interface ZWChild ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ZWChild

@synthesize path = _path;
@synthesize files = _files;
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
            self.path = [self objectOrNilForKey:kZWChildPath fromDictionary:dict];
            self.files = [self objectOrNilForKey:kZWChildFiles fromDictionary:dict];
            self.folders = [self objectOrNilForKey:kZWChildFolders fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.path forKey:kZWChildPath];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForFiles] forKey:kZWChildFiles];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForFolders] forKey:kZWChildFolders];

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

    self.path = [aDecoder decodeObjectForKey:kZWChildPath];
    self.files = [aDecoder decodeObjectForKey:kZWChildFiles];
    self.folders = [aDecoder decodeObjectForKey:kZWChildFolders];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_path forKey:kZWChildPath];
    [aCoder encodeObject:_files forKey:kZWChildFiles];
    [aCoder encodeObject:_folders forKey:kZWChildFolders];
}

- (id)copyWithZone:(NSZone *)zone
{
    ZWChild *copy = [[ZWChild alloc] init];
    
    if (copy) {

        copy.path = [self.path copyWithZone:zone];
        copy.files = [self.files copyWithZone:zone];
        copy.folders = [self.folders copyWithZone:zone];
    }
    
    return copy;
}


@end
