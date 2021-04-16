//
//  VTBLEHelper.h
//  TestSDK
//
//  Created by viatom on 2020/8/28.
//  Copyright © 2020 viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "VTBLEDevice.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VTBLEHelperDelegate <NSObject>

@optional
- (void)servicesAndCharacteristicsConfig:(BOOL)isSuccess withHelper:(id _Nonnull)helper;
- (void)bleHelperRealData:(BOOL)isSuccess withDevice:(VTBLEDevice *_Nonnull)device withHelper:(VTRealObject *_Nonnull)obj;

@end

@interface VTBLEHelper : NSObject

@property (nonatomic, assign) id<VTBLEHelperDelegate> _Nonnull delegate;
@property (nonatomic, strong) CBCentralManager *central;
@property (nonatomic, strong) VTBLEDevice *device;
@property (nonatomic, getter=isConfig) BOOL config;

- (instancetype)initWithCentral:(CBCentralManager * _Nonnull)central;

- (void)discoverServices;

- (void)readData;

@end

NS_ASSUME_NONNULL_END
