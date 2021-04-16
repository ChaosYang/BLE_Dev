//
//  VBeatResults.m
//  ViHealth
//
//  Created by Viatom on 2019/7/24.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import "VBeatResults.h"

@implementation VBeatResults

- (instancetype)init{
    self = [super init];
    if (self) {
        self.maxHR = 0;
        self.avgHR = 0;
        self.hrTotal = 0;
        self.hrNumber = 0;
    }
    return self;
}

- (void)resultsFromPoint:(PointData_t)point{
    if (point.hr <= 250 && point.hr >= 30) {
        _maxHR = MAX(_maxHR, point.hr);
        _hrTotal += point.hr;
        _hrNumber ++;
    }
}


@end
