//
//  VBeatPoint.h
//  ViHealth
//
//  Created by Viatom on 2019/7/23.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViaBLEStruct.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBeatPoint : NSObject

@property (nonatomic, assign) u_char hr;
@property (nonatomic, assign) u_char motion;
@property (nonatomic, assign) u_char vibration;

- (instancetype)initWithPointStrcut:(PointData_t)point;

@end

NS_ASSUME_NONNULL_END
