//
//  VTProObject.m
//  LibUseDemo
//
//  Created by viatom on 2020/6/11.
//  Copyright © 2020 Viatom. All rights reserved.
//

#import "VTProObject.h"
#import <objc/runtime.h>

@implementation VTProObject

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

@implementation VTProDlc


@end

@implementation VTProEcg


@end

@implementation VTProSpO2


@end

@implementation VTProBp


@end

@implementation VTProBg

@end

@implementation VTProTm


@end


@implementation VTProSlm

@end


@implementation VTProPed


@end
