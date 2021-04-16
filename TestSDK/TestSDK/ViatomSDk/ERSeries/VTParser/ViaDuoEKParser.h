//
//  ViaDuoEKParser.h
//  ViaCommunicate
//
//  Created by viatom on 2020/3/20.
//  Copyright © 2020 viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViaHeader.h"


NS_ASSUME_NONNULL_BEGIN


@interface ViaDuoEKParser : NSObject



/// 根据传入的result返回对应的结果
/// @param result  AnalysisResult .result
+ (ViaECGAnalysisResult)via_parserResult:(u_int)result;

/// 根据获取的正常数据，返回波形点s
/// @param normalData 获取的正常数据
+ (RealTimeWaveform)via_parserRealTimeWaveform:(NSData *)normalData;

/// 根据获取的正常数据，返回波形点及主机的部分实时参数
/// @param normalData 获取的正常数据
+ (RealTimeData)via_parserRealData:(NSData *)normalData;

/// 根据s获取的正常数据，返回ER2配置参数
/// @param normalData 获取的正常数据
+ (Configuartion)via_parserER2Config:(NSData *)normalData;

/// 返回头+尾+ER2点数组
/// @param waveData ER1 波形数据原始数据
/// @param callBack 返回闭包
+ (void)via_parserWaveData:(NSData *)waveData callBack:(DuoEKWaveCallback)callBack;

/// 返回头+尾
/// @param waveData 波形数据原始数据
/// @param callBack 返回闭包
+ (void)via_parserWaveData:(NSData *)waveData callBackHeadAndTail:(DuoEKHeadTailBack)callBack;

@end

NS_ASSUME_NONNULL_END
