//
//  ViaHeader.h
//  ViaCommunicate
//
//  Created by viatom on 2020/3/24.
//  Copyright © 2020 viatom. All rights reserved.
//

#ifndef ViaHeader_h
#define ViaHeader_h

#import "ViaBLEMarco.h"
#import "VBeatPoint.h"
#import "VBeatResults.h"


/**
 @param cmd_type CMD Type
 @param pkg_type Pkg Type
 @param data Raw data
 */
typedef void(^AckAnalysis)(u_char cmd_type ,u_char pkg_type,  NSData * _Nullable data);
typedef void(^AnalysisCallback)(AnalysisTotalResult totalResult, AnalysisResult * _Nullable results);
typedef void(^DuoEKHeadTailBack)(FileHead_t head, FileTail_t tail);
typedef void(^DuoEKWaveCallback)(FileHead_t head, FileTail_t tail, NSArray * _Nullable pointArr);
typedef void(^VBeatHeadTailBack)(FileHead_t head, FileTail_t_V tail);
typedef void(^VBeatWaveCallback)(FileHead_t head, FileTail_t_V tail, VBeatResults * _Nullable results, NSArray<VBeatPoint *> * _Nullable pointArr);
typedef void(^AckDataCmd)(u_char cmd_type, NSData * _Nonnull data);

typedef NS_OPTIONS(NSUInteger, ViaECGAnalysisResult) {
    /* 正常心电图
    */
    ViaECGAnalysisResultRegular = 0x01,
   
    /* 导联弱 无法分析
    */
    ViaECGAnalysisResultPoorSignal  = 0x02,

    /* 测量时长低于30秒
    */
    ViaECGAnalysisResultLower30s  = 0x03,
    
    /* 检测到运动 无法分析
    */
    ViaECGAnalysisResultMotion  = 0x04,
    
    /* HR > 100 bpm
    */
    ViaECGAnalysisResultFastHR  = 0x05,
    
    /* HR < 50 bpm
    */
    ViaECGAnalysisResultSlowHR  = 0x05,
};


#endif /* ViaHeader_h */

