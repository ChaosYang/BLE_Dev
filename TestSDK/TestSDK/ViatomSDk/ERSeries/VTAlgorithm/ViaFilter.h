//
//  ViaFilter.h
//  DuoEK
//
//  Created by Viatom on 2019/5/5.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViaFilter : NSObject

+ (ViaFilter *)shared;
// 初始化滤波算法
- (void)resetParams;

// 对实时数据多个点进行滤波
- (NSArray *)sfilterPointValue:(NSArray *)ptArray;

// 对实时数据单个点进行滤波
- (NSArray *)filterPointValue:(double)ptValue;

// 对存储数据多个点滤波
- (NSArray *)offlineFilterPoints:(NSArray *)ptArray;

@end

NS_ASSUME_NONNULL_END
