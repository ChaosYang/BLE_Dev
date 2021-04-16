//
//  VBeatResults.h
//  ViHealth
//
//  Created by Viatom on 2019/7/24.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViaBLEStruct.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBeatResults : NSObject

@property (nonatomic, assign) u_int hrTotal;  // 有效心率统计值
@property (nonatomic, assign) u_int hrNumber;   // 有效心率统计个数
@property (nonatomic, assign) u_char avgHR;   
@property (nonatomic, assign) u_char maxHR;

- (void)resultsFromPoint:(PointData_t)point;


@end

NS_ASSUME_NONNULL_END
