//
//  VTProUser.m
//  LibUseDemo
//
//  Created by viatom on 2020/6/11.
//  Copyright © 2020 Viatom. All rights reserved.
//

#import "VTProUser.h"
#import <objc/runtime.h>

@implementation VTProUser

@synthesize userName = _userName;
@synthesize userID = _userID;
@synthesize gender = _gender;
@synthesize height = _height;
@synthesize weight = _weight;
@synthesize age = _age;
@synthesize birthday = _birthday;
@synthesize iconID = _iconID;

- (instancetype)init{
    if (self = [super init]) {
        self.birthday = [[NSDateComponents alloc] init];
    }
    return self;
}


- (NSString *)description{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    uint count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        id value = [self valueForKey:name] ?:@"nil";
        [dictionary setObject:value forKey:name];
    }
    free(properties);
    return [NSString stringWithFormat:@"<%@: %p> -- %@", [self class], self, dictionary];
}

@end

