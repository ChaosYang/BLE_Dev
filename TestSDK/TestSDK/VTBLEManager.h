//
//  VTBLEManager.h
//  TestSDK
//
//  Created by viatom on 2020/8/28.
//  Copyright © 2020 viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTBLEHelper.h"


NS_ASSUME_NONNULL_BEGIN

@protocol VTBLEManagerDelegate <NSObject>

@optional
- (void)updateStateWithCentral:(CBCentralManager * _Nonnull)central;

- (void)findDevice:(VTBLEDevice * _Nonnull)device withCentral:(CBCentralManager * _Nonnull)central;

- (void)didConnectDevice:(VTBLEHelper * _Nonnull)obj;

- (void)didFailedToConnectDevice:(VTBLEHelper * _Nonnull)obj;

- (void)didDisconnectDevice:(VTBLEHelper * _Nonnull)obj;

- (void)didCancelConnectDevice:(VTBLEHelper * _Nonnull)obj;

- (void)didCompletedConfig:(BOOL)success;

- (void)bleManagerRealData:(BOOL)isSuccess withDevice:(VTBLEDevice *_Nonnull)device withHelper:(VTRealObject *_Nonnull)obj;


@end

@interface VTBLEManager : NSObject

@property (nonatomic, readonly, copy) NSArray <VTBLEHelper *> *managerList;
@property (nonatomic, assign) id<VTBLEManagerDelegate> _Nullable delegate;

/// @brief 当主从机由于某种原因自动断开时， 是否自动重连
@property (nonatomic, getter=isAutoConnect) BOOL autoConnect;

+ (VTBLEManager *)manager;

/// @brief 准备搜索pN个外设
/// @param pN  计划连接的外设个数
- (void)scanWithNumber:(NSUInteger)pN;

/// @brief 停止搜索
- (void)stopScan:(CBCentralManager *)central;

/// @brief 连接指定的设备
/// @param device 指定连接的设备
/// @param central  连接设备对应的中心管理者
- (void)connectDevice:(VTBLEDevice * _Nonnull)device withCentral:(CBCentralManager *)central;

/// @brief 取消指定设备的链接
/// @param obj  指定设备以及中心类
- (void)cancelConnectDevice:(VTBLEHelper *)obj;


/// @brief 请求数据  测试接口
/// @param obj VTBLEHelper
- (void)requestDataWithVTObj:(VTBLEHelper * _Nonnull)obj;


@end

NS_ASSUME_NONNULL_END
