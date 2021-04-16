//
//  VTO2WaveObject.m
//  VTO2Lib
//
//  Created by viatom on 2020/6/28.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "VTO2WaveObject.h"
#import <objc/runtime.h>

@implementation VTO2WaveObject

- (NSString *)description{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    uint count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        id value = [self valueForKey:name] ?:@"nil";
        if ([value isKindOfClass:[NSArray class]]) {
            value = [NSString stringWithFormat:@"This is an array which contains %ld elements", (long)[value count]];
        }
        [dictionary setObject:value forKey:name];
    }
    free(properties);
    return [NSString stringWithFormat:@"<%@: %p> -- %@", [self class], self, dictionary];
}


@end
