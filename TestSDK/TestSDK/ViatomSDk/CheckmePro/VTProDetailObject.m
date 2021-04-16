//
//  VTProDetailObject.m
//  LibUseDemo
//
//  Created by viatom on 2020/6/12.
//  Copyright © 2020 Viatom. All rights reserved.
//

#import "VTProDetailObject.h"
#import <objc/runtime.h>

@implementation VTProDetailObject

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

@implementation VTProEcgDetail

- (instancetype)init{
    self = [super init];
    if (self) {
        self.arrEcgContent = [NSMutableArray arrayWithCapacity:10];
        self.arrEcgHeartRate = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

@end

@implementation VTProSlmDetail

- (instancetype)init{
    self = [super init];
    if (self) {
        self.arrOxValue = [NSMutableArray arrayWithCapacity:10];
        self.arrPrValue = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

@end
