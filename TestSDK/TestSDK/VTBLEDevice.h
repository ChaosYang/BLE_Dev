//
//  VTBLEDevice.h
//  TestSDK
//
//  Created by viatom on 2020/8/31.
//  Copyright © 2020 viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface VTBLEDevice : NSObject

@property (nonatomic, strong) CBPeripheral *rawPeripheral;

@property (nonatomic, copy) NSString *advName;

@property (nonatomic, strong) NSNumber *RSSI;

@property (nonatomic, copy) NSArray *O2DevicePrefixsArray;
@property (nonatomic, copy) NSArray *ProDevicePrefixsArray;
@property (nonatomic, copy) NSArray *VTDevicePrefixsArray;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral adv:(NSDictionary *)advDic RSSI:(NSNumber *)RSSI;

@end

NS_ASSUME_NONNULL_END
