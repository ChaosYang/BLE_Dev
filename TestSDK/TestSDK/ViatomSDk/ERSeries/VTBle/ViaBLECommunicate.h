//
//  ViaBLECommunicate
//  ViHealth
//
//  Created by Viatom on 2018/6/5.
//  Copyright © 2018年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ViaHeader.h"

typedef void(^NotifyHRResult)(NSData *hrData);
typedef void(^NotifyRSSIValue)(NSNumber *rssi);
typedef void(^DeployStatus)(BOOL completed);


typedef enum : NSUInteger {
    BLERequestTimeoutNormal = 3000,
    BLERequestTimeoutFactory = 1000,
    BLERequestTimeoutRealData = 490,
} BLERequestTimeout;

@protocol ViaBLECommunicateDelegate <NSObject>

@optional
- (void)finishedRequest:(NSData *)responseData;

@optional
- (void)responseTimeOut:(u_char)cmd;   //将命令传入  方便区分

@optional
- (void)deployStatus:(BOOL)completed;


@end

@interface ViaBLECommunicate : NSObject

@property (nonatomic, assign) id<ViaBLECommunicateDelegate>delegate;


//+ (ViaBLECommunicate *) sharedInstance;


- (void)enterActiveState:(CBPeripheral *)peripheral;
- (void)cancelActiveState;

/**
*   监听心率 通过标准服务
*   Monitoring Heart Rate by Standard Service
*/
- (void)via_notifyHeartRate:(NotifyHRResult)result;

/**
*   监听RSSI
*   Monitoring RSSI
*/
- (void)via_notifyRSSI:(NotifyRSSIValue)rssi;


/**
*   确定好读写特征之后，可通过以下方法进行数据交互
*   After determining the read and write characteristics, you can use the following methods for data interaction
*/

/// 获取设备信息
- (void)via_getDeviceInfo;

/// 获取文件列表
- (void)via_getFileList;

/// 读文件开始，打开文件系统
/// @param start 包含文件名和偏移量的结构体，偏移量可用来进行断点续传
- (void)via_readFileStart:(FileReadStart)start;

/// 正在读文件
/// @param fileRead 包含偏移量的结构体
- (void)via_readFile:(FileRead)fileRead;

/// 读文件结束，关闭文件系统
- (void)via_readFileEnd;

/// 获取实时波形
/// @param rate 频率
- (void)via_getRealWave:(SendRate)rate;

/// 获取实时数据
/// @param rate 频率
- (void)via_getRealData:(SendRate)rate;

/// 获取电池电量信息
- (void)via_getBattery;

/// 恢复出厂设置
- (void)via_factoryReset;

/// 慎用
- (void)via_allReset;

/// 配置参数
/// @param config 参数
- (void)via_factorySet:(FactoryConfig)config;

/// 获取参数
- (void)via_getECGConfig;

/// 配置ER1参数
/// @param config ER1参数
- (void)via_setER1Config:(ConfiguartionER1)config;

/// 配置ER2参数
/// @param config ER2参数
- (void)via_setER2Config:(Configuartion)config;

/// 同步时间
/// @param time 包含年月日时分秒的结构体
- (void)via_syncTime:(DeviceTime)time;



@end

