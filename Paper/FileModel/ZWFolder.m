//
//  ZWFolders.m
//
//  Created by Administrator  on 16/4/4
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "ZWFolder.h"
#import "ZWChild.h"


NSString *const kZWFoldersName = @"name";
NSString *const kZWFoldersChild = @"child";


@interface ZWFolder ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ZWFolder

@synthesize name = _name;
@synthesize child = _child;


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
            self.name = [self objectOrNilForKey:kZWFoldersName fromDictionary:dict];
            self.child = [ZWChild modelObjectWithDictionary:[dict objectForKey:kZWFoldersChild]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.name forKey:kZWFoldersName];
    [mutableDict setValue:[self.child dictionaryRepresentation] forKey:kZWFoldersChild];

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

    self.name = [aDecoder decodeObjectForKey:kZWFoldersName];
    self.child = [aDecoder decodeObjectForKey:kZWFoldersChild];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_name forKey:kZWFoldersName];
    [aCoder encodeObject:_child forKey:kZWFoldersChild];
}

- (id)copyWithZone:(NSZone *)zone
{
    ZWFolder *copy = [[ZWFolder alloc] init];
    
    if (copy) {

        copy.name = [self.name copyWithZone:zone];
        copy.child = [self.child copyWithZone:zone];
    }
    
    return copy;
}


@end
