//
//  ViaCommonParser.h
//  ViaCommunicate
//
//  Created by viatom on 2020/3/20.
//  Copyright © 2020 viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViaHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViaCommonParser : NSObject

/// 解析历史波形点数据
/// @param analysisData 读取主机原始数据
/// @param callBack 返回闭包AnalysisCallback
+ (void)via_parserAnalysisData:(NSData *)analysisData callBack:(AnalysisCallback)callBack;

/**
 @param data data from via's device
 @param result view block AckAnalysis
 */
+ (void)via_ackAnalysis:(NSData *)data result:(AckAnalysis)result;


/**
 @param normalData normal data from via's device
 @return struct DeviceInfo
 */
+ (DeviceInfo)via_parserDeviceInfo:(NSData *)normalData;

/**
 @param normalData normal data from via's device
 @return struct BatteryInfo
 */
+ (BatteryInfo)via_parserBatteryInfo:(NSData *)normalData;

/**
 @param normalData normal data from via's device
 @return struct Temperature
 */
+ (Temperature)via_parserTemperature:(NSData *)normalData;

/**
 @param normalData normal data from via's device
 @return struct FileList
 */
+ (FileList)via_parserFileList:(NSData *)normalData;

/**
 @param normalData normal data from via's device
 @return struct FileStartReadReturn
 */
+ (FileStartReadReturn)via_parserFileLength:(NSData *)normalData;

/**
 @param normalData normal data from via's device
 @return struct FileData
 */
+ (FileData)via_parserFileData:(NSData *)normalData;

/**
 @param normalData normal data from via's device
 @return struct FileWriteStartReturn
 */
+ (FileWriteStartReturn)via_parserWriteFile:(NSData *)normalData;

/**
 @param normalData normal data from via's device
 @return struct UserList
 */
+ (UserList)via_parserUserList:(NSData *)normalData;

#pragma mark --- 解压压缩过的原始点数据
// 原始值float
+ (NSArray *)via_parserPoints:(NSData *)pointData;

//  原始值short
+ (NSArray *)via_parserOrignalPoints:(NSData *)pointData;


#pragma mark --- data covert to mV
// 原始值 short -> float
+ (float)via_mVFromShort:(short)n;

#pragma mark --- sys_flag split
+ (flagBit)via_flagSplit:(u_char)flag;

#pragma mark --- run_status split
+ (RunStatusBit)via_runStatusSplit:(u_char)run_status;

@end

NS_ASSUME_NONNULL_END
