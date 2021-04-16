//
//  ViaVBeatParser.h
//  ViaCommunicate
//
//  Created by viatom on 2020/3/20.
//  Copyright © 2020 viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViaHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViaVBeatParser : NSObject

/// 返回头+尾
/// @param waveData 波形数据原始数据
/// @param callBack 返回闭包
+ (void)via_parserWaveData:(NSData *)waveData callBackHeadAndTail:(VBeatHeadTailBack)callBack;

/// 返回头+尾+ER1点数组
/// @param waveData ER1 波形数据原始数据
/// @param callBack 返回闭包
+ (void)via_parserVBeatWaveData:(NSData *)waveData callBack:(VBeatWaveCallback)callBack;

/// 解析返回ER1配置
/// @param normalData 来源于主机的正常数据
+ (ConfiguartionER1)via_parserER1Config:(NSData *)normalData;

@end

NS_ASSUME_NONNULL_END
