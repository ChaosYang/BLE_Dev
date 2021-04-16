//
//  VTProMiniObject.m
//  LibUseDemo
//
//  Created by viatom on 2020/6/15.
//  Copyright © 2020 Viatom. All rights reserved.
//

#import "VTProMiniObject.h"
#import <objc/runtime.h>

@implementation VTProMiniObject

- (instancetype)init{
    self = [super init];
    if (self) {
        _ecgArray = [NSMutableArray array];
        _spo2Array = [NSMutableArray array];
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
