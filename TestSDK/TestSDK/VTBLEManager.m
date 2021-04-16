//
//  VTBLEManager.m
//  TestSDK
//
//  Created by viatom on 2020/8/28.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "VTBLEManager.h"
#import "VTBLEDevice.h"
#import "VTBLEHelper.h"

@interface VTBLEManager ()<CBCentralManagerDelegate, VTBLEHelperDelegate>

@end

@implementation VTBLEManager

#pragma mark ---
static VTBLEManager *_manager = nil;
+ (VTBLEManager *)manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[super allocWithZone:NULL] init];
    });
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [VTBLEManager manager];
}
-(id)copyWithZone:(NSZone *)zone{
    return [VTBLEManager manager];
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return [VTBLEManager manager];
}

#pragma mark --- set & get
- (void)setDelegate:(id<VTBLEManagerDelegate>)delegate{
    _delegate = delegate;
}

- (BOOL)isAutoConnect{
    return YES;
}

#pragma mark --- 华丽丽的的分割线 ---------

- (void)scanWithNumber:(NSUInteger)pN{
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:10];
    dispatch_queue_t mySerialQueue = dispatch_queue_create("com.gcd.queueCreate.mySerialQueue", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < pN; i ++) {
        CBCentralManager *cm = [[CBCentralManager alloc] initWithDelegate:self queue:mySerialQueue];
        VTBLEHelper *obj = [[VTBLEHelper alloc] initWithCentral:cm];
        [tempArr addObject:obj];
    }
    _managerList = [tempArr copy];
}


- (void)stopScan:(CBCentralManager *)central{
    [central stopScan];
}

- (void)connectDevice:(VTBLEDevice *)device withCentral:(CBCentralManager *)central{
    for (VTBLEHelper *obj in _managerList) {
        if ([obj.central isEqual:central]) {
            obj.device = device;
            obj.delegate = self;
        }
    }
    [central connectPeripheral:device.rawPeripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
}

- (void)cancelConnectDevice:(VTBLEHelper *)obj{
    [obj.central cancelPeripheralConnection:obj.device.rawPeripheral];
}

#pragma mark --- data request
- (void)requestDataWithVTObj:(VTBLEHelper * _Nonnull)obj{
    [obj readData];
}

#pragma mark --- helper delegate
- (void)servicesAndCharacteristicsConfig:(BOOL)isSuccess withHelper:(id)helper{
    if (!isSuccess) {
        if (_delegate && [_delegate respondsToSelector:@selector(didCompletedConfig:)]) {
            [_delegate didCompletedConfig:NO];
        }
    }else{
        for (VTBLEHelper *obj in _managerList) {
            if (!obj.isConfig) {
                return;
            }
        }
        if (_delegate && [_delegate respondsToSelector:@selector(didCompletedConfig:)]) {
            [_delegate didCompletedConfig:YES];
        }
    }
    
}
- (void)bleHelperRealData:(BOOL)isSuccess withDevice:(VTBLEDevice * _Nonnull)device withHelper:(VTRealObject * _Nonnull)obj{
//    __weak typeof (self)weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_delegate && [self->_delegate respondsToSelector:@selector(bleManagerRealData:withDevice:withHelper:)]) {
            [self->_delegate bleManagerRealData:isSuccess withDevice:device withHelper:obj];
        }
    });
    
}
#pragma mark --- central manager delegate -------

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    if (central.state == 5) {
        DLog(@"central:%@ start scan", central);
        [central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:YES]}];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(updateStateWithCentral:)]) {
        [_delegate updateStateWithCentral:central];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
//    DLog(@"发现了设备:%@",peripheral.name);

    VTBLEDevice *device = [[VTBLEDevice alloc] initWithPeripheral:peripheral adv:advertisementData RSSI:RSSI];
    if (device) {
        if (_delegate && [_delegate respondsToSelector:@selector(findDevice:withCentral:)]) {
            [_delegate findDevice:device withCentral:central];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    for (VTBLEHelper *obj in _managerList) {
        if ([obj.central isEqual:central]) {
            [obj discoverServices];
            if (_delegate && [_delegate respondsToSelector:@selector(didConnectDevice:)]) {
                [_delegate didConnectDevice:obj];
            }
        }
    }
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    for (VTBLEHelper *obj in _managerList) {
        if ([obj.central isEqual:central]) {
            if (_delegate && [_delegate respondsToSelector:@selector(didFailedToConnectDevice:)]) {
                [_delegate didFailedToConnectDevice:obj];
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    for (VTBLEHelper *obj in _managerList) {
        if ([obj.central isEqual:central]) {
            if (error) { // 主从机自动断开连接
                if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectDevice:)]) {
                    [_delegate didDisconnectDevice:obj];
                }
                if (self.isAutoConnect) {
                    [self connectDevice:obj.device withCentral:obj.central];
                }
            }else{  // 主从机手动断开连接
                if (_delegate && [_delegate respondsToSelector:@selector(didCancelConnectDevice:)]) {
                    [_delegate didCancelConnectDevice:obj];
                }
            }
        }
    }
}


@end
