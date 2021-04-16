//
//  VBeatPoint.m
//  ViHealth
//
//  Created by Viatom on 2019/7/23.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import "VBeatPoint.h"

@implementation VBeatPoint

- (instancetype)initWithPointStrcut:(PointData_t)point{
    self = [super init];
    if (self) {
        self.hr = point.hr;
        self.motion = point.motion;
        self.vibration = point.vibration;
    }
    return self;
}

@end
