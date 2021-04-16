//
//  VTBLEDevice.m
//  TestSDK
//
//  Created by viatom on 2020/8/31.
//  Copyright © 2020 viatom. All rights reserved.
//


#import "VTBLEDevice.h"

@interface VTBLEDevice ()



@end

@implementation VTBLEDevice

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral adv:(NSDictionary *)advDic RSSI:(NSNumber *)RSSI{
    self = [super init];
    if (self) {
        self.RSSI = RSSI;
        self.rawPeripheral = peripheral;
        self.advName = [advDic objectForKey:@"kCBAdvDataLocalName"];
        if (![self.advName isKindOfClass:[NSNull class]] &&
            ![self.advName isEqualToString:@""] &&
            self.advName != nil &&
            ![peripheral.name isEqualToString:self.advName]) {
            [peripheral setValue:self.advName forKey:@"name"];
        }
        self.rawPeripheral = peripheral;
        if (![self.O2DevicePrefixsArray containsObject:[peripheral.name componentsSeparatedByString:@" "].firstObject] &&
            ![self.ProDevicePrefixsArray containsObject:[peripheral.name componentsSeparatedByString:@" "].firstObject] &&
            ![self.VTDevicePrefixsArray containsObject:[peripheral.name componentsSeparatedByString:@" "].firstObject]) {
            return nil;
        }
    }
    return self;
}

- (NSArray *)O2DevicePrefixsArray{
    if (!_O2DevicePrefixsArray) {
        _O2DevicePrefixsArray = @[@"O2",@"O2BAND",@"SleepO2",@"O2Ring",@"WearO2",@"SleepU",@"Oxylink",@"KidsO2",@"BabyO2",@"Oxyfit"];
    }
    return _O2DevicePrefixsArray;
}
- (NSArray *)ProDevicePrefixsArray{
    if (!_ProDevicePrefixsArray) {
        _ProDevicePrefixsArray = @[@"CheckmePro",@"Pulsebit"];
    }
    return _ProDevicePrefixsArray;
}
- (NSArray *)VTDevicePrefixsArray{
    if (!_VTDevicePrefixsArray) {
        _VTDevicePrefixsArray =  @[@"DuoEK",@"VBeat",@"BP2",@"ER1"];
    }
    return _VTDevicePrefixsArray;
}
@end
