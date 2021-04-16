//
//  VTBLEHelper.m
//  TestSDK
//
//  Created by viatom on 2020/8/28.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "VTBLEHelper.h"
#import "VTO2Communicate.h"
#import "ViaCommunicate.h"

@interface VTBLEHelper ()<CBPeripheralDelegate,VTO2CommunicateDelegate,ViaBLECommunicateDelegate>
{
    dispatch_source_t _timer;
}

@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) CBCharacteristic *rxCharacteristic;
@property (nonatomic, strong) CBCharacteristic *txCharacteristic;
@property (nonatomic, strong) CBCharacteristic *realHRCharacteristic;
@property (nonatomic, strong) VTO2Communicate *O2Communicate;
@property (nonatomic, strong) ViaBLECommunicate *ERCommunicate;

@end

@implementation VTBLEHelper

- (VTO2Communicate *)O2Communicate{
    if (!_O2Communicate) {
        _O2Communicate = [[VTO2Communicate alloc]init];
    }
    return _O2Communicate;
}
- (ViaBLECommunicate *)ERCommunicate{
    if (!_ERCommunicate) {
        _ERCommunicate = [[ViaBLECommunicate alloc]init];
    }
    return _ERCommunicate;
}
- (instancetype)initWithCentral:(CBCentralManager *)central{
    self = [super init];
    if (self) {
        self.central = central;
        
    }
    return self;
}

- (void)setDevice:(VTBLEDevice *)device{
    _device = device;
    _peripheral = device.rawPeripheral;
//    _peripheral.delegate = self;
    
    //    [self.ERCommunicate enterActiveState:self.device.rawPeripheral];
    //    self.ERCommunicate.delegate = self;
    
//    self.O2Communicate.peripheral = self.device.rawPeripheral;
//    self.O2Communicate.delegate = self;
    if ([_device.advName containsString:deviceNamePrefix1]) {
        self.O2Communicate.peripheral = self.device.rawPeripheral;
        self.O2Communicate.delegate = self;
    }else if ([_device.advName containsString:deviceNamePrefix2]){
        [self.ERCommunicate enterActiveState:self.device.rawPeripheral];
        self.ERCommunicate.delegate = self;
    }
//    if ([self.device.O2DevicePrefixsArray containsObject:deviceNamePrefix1] && [self.device.O2DevicePrefixsArray containsObject:deviceNamePrefix2]) {
//        self.O2Communicate.peripheral = self.device.rawPeripheral;
//        self.O2Communicate.delegate = self;
//    }else if ([self.device.VTDevicePrefixsArray containsObject:deviceNamePrefix1] && [self.device.VTDevicePrefixsArray containsObject:deviceNamePrefix2]){
//        [self.ERCommunicate enterActiveState:self.device.rawPeripheral];
//        self.ERCommunicate.delegate = self;
//    }
    
    
}

#define vtService1 [CBUUID UUIDWithString:@"569a1101-b87f-490c-92cb-11ba5ea5167c"]
#define vtTxCharacteristic1 [CBUUID UUIDWithString:@"569a2000-b87f-490c-92cb-11ba5ea5167c"]
#define vtRxCharacteristic1 [CBUUID UUIDWithString:@"569a2001-b87f-490c-92cb-11ba5ea5167c"]

#define vtService2 [CBUUID UUIDWithString:@"14839ac4-7d7e-415c-9a42-167340cf2339"]
#define vtTxCharacteristic2 [CBUUID UUIDWithString:@"8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3"]
#define vtRxCharacteristic2 [CBUUID UUIDWithString:@"0734594A-A8E7-4B1A-A6B1-CD5243059A57"]

#define vtHeartRateService [CBUUID UUIDWithString:@"180D"]
#define vtHeartRateCharacteristic [CBUUID UUIDWithString:@"2A37"]

- (void)discoverServices{
    [_peripheral discoverServices:@[vtService1, vtService2, vtHeartRateService]];
}

#pragma mark --- communicate

- (void)readData{
    __weak typeof (self)weakSelf = self;
    dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //创建一个定时器，并将定时器的任务交给全局队列执行(并行，不会造成主线程阻塞)
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1* NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        //        [weakSelf.ERCommunicate via_getBattery];
        if ([weakSelf.device.advName containsString:deviceNamePrefix1]) {
             [weakSelf.O2Communicate beginGetRealData];
         }else if ([weakSelf.device.advName containsString:deviceNamePrefix2]){
             [weakSelf.ERCommunicate via_getBattery];
         }
        //        if ([self.device.advName isEqualToString:deviceName1
        //             ]) {
        //                [weakSelf.O2Communicate beginGetRealData];
        //
        //        }else if ([self.device.advName isEqualToString:deviceName2]){
        //            [weakSelf.ERCommunicate via_getBattery];
        //        }
    });
    dispatch_resume(_timer);
    
    //    u_char buf[8];
    //    memset(buf, 0, 8);
    //    buf[0] = 0xAA;
    //    buf[1] = 0x17;
    //    buf[2] = ~0x17;
    //    buf[7] = [self CalCRC8:buf bufSize:7];
    //    NSData *data = [NSData dataWithBytes:buf length:8];
    //    if (_peripheral.state == CBPeripheralStateConnected) {
    //        [_peripheral writeValue:data forCharacteristic:_txCharacteristic type:CBCharacteristicWriteWithoutResponse];
    //    }
}

const unsigned char Table_CRC8[256]={      /*CRC8 ±í*/
    0x00, 0x07, 0x0E, 0x09, 0x1C, 0x1B, 0x12, 0x15,
    0x38, 0x3F, 0x36, 0x31, 0x24, 0x23, 0x2A, 0x2D,
    0x70, 0x77, 0x7E, 0x79, 0x6C, 0x6B, 0x62, 0x65,
    0x48, 0x4F, 0x46, 0x41, 0x54, 0x53, 0x5A, 0x5D,
    0xE0, 0xE7, 0xEE, 0xE9, 0xFC, 0xFB, 0xF2, 0xF5,
    0xD8, 0xDF, 0xD6, 0xD1, 0xC4, 0xC3, 0xCA, 0xCD,
    0x90, 0x97, 0x9E, 0x99, 0x8C, 0x8B, 0x82, 0x85,
    0xA8, 0xAF, 0xA6, 0xA1, 0xB4, 0xB3, 0xBA, 0xBD,
    0xC7, 0xC0, 0xC9, 0xCE, 0xDB, 0xDC, 0xD5, 0xD2,
    0xFF, 0xF8, 0xF1, 0xF6, 0xE3, 0xE4, 0xED, 0xEA,
    0xB7, 0xB0, 0xB9, 0xBE, 0xAB, 0xAC, 0xA5, 0xA2,
    0x8F, 0x88, 0x81, 0x86, 0x93, 0x94, 0x9D, 0x9A,
    0x27, 0x20, 0x29, 0x2E, 0x3B, 0x3C, 0x35, 0x32,
    0x1F, 0x18, 0x11, 0x16, 0x03, 0x04, 0x0D, 0x0A,
    0x57, 0x50, 0x59, 0x5E, 0x4B, 0x4C, 0x45, 0x42,
    0x6F, 0x68, 0x61, 0x66, 0x73, 0x74, 0x7D, 0x7A,
    0x89, 0x8E, 0x87, 0x80, 0x95, 0x92, 0x9B, 0x9C,
    0xB1, 0xB6, 0xBF, 0xB8, 0xAD, 0xAA, 0xA3, 0xA4,
    0xF9, 0xFE, 0xF7, 0xF0, 0xE5, 0xE2, 0xEB, 0xEC,
    0xC1, 0xC6, 0xCF, 0xC8, 0xDD, 0xDA, 0xD3, 0xD4,
    0x69, 0x6E, 0x67, 0x60, 0x75, 0x72, 0x7B, 0x7C,
    0x51, 0x56, 0x5F, 0x58, 0x4D, 0x4A, 0x43, 0x44,
    0x19, 0x1E, 0x17, 0x10, 0x05, 0x02, 0x0B, 0x0C,
    0x21, 0x26, 0x2F, 0x28, 0x3D, 0x3A, 0x33, 0x34,
    0x4E, 0x49, 0x40, 0x47, 0x52, 0x55, 0x5C, 0x5B,
    0x76, 0x71, 0x78, 0x7F, 0x6A, 0x6D, 0x64, 0x63,
    0x3E, 0x39, 0x30, 0x37, 0x22, 0x25, 0x2C, 0x2B,
    0x06, 0x01, 0x08, 0x0F, 0x1A, 0x1D, 0x14, 0x13,
    0xAE, 0xA9, 0xA0, 0xA7, 0xB2, 0xB5, 0xBC, 0xBB,
    0x96, 0x91, 0x98, 0x9F, 0x8A, 0x8D, 0x84, 0x83,
    0xDE, 0xD9, 0xD0, 0xD7, 0xC2, 0xC5, 0xCC, 0xCB,
    0xE6, 0xE1, 0xE8, 0xEF, 0xFA, 0xFD, 0xF4, 0xF3
};

- (uint8_t)CalCRC8:(u_char *)RP_ByteData bufSize:(u_int)Buffer_Size
{
    uint8_t x,R_CRC_Data;
    uint32_t i;
    
    R_CRC_Data=0;
    for(i=0;i<Buffer_Size;i++)
    {
        x = R_CRC_Data ^ (*RP_ByteData);
        R_CRC_Data = Table_CRC8[x];
        RP_ByteData++;
    }
    return R_CRC_Data;
}
#pragma mark ViaBLECommunicateDelegate
- (void)deployStatus:(BOOL)completed{
    if (completed) {
        DLog(@"配置完成");
        
    }
}
- (void)finishedRequest:(NSData *)responseData{
    [ViaCommonParser via_ackAnalysis:responseData result:^(u_char cmd_type, u_char pkg_type, NSData * _Nullable data) {
        if (pkg_type == VT_Type_Normal) {
            if (cmd_type == VT_CMD_GetBattery) {
                DLog(@"设备:%@",self.device.advName);
            }
        }
    }];
    
}
#pragma mark VTO2CommunicateDelegate
- (void)realDataCallBackWithData:(NSData *)realData{
    DLog(@"realData:%@",realData);
    if (realData == nil) {
        return;
    }
    VTRealObject *rObj = [VTO2Parser parseO2RealObjectWithData:realData];
    if (_delegate && [_delegate respondsToSelector:@selector(bleHelperRealData:withDevice:withHelper:)]) {
        [_delegate bleHelperRealData:YES withDevice:self.device withHelper:rObj];
    }
    //
    //    self.descLab.text = [rObj description];
}
#pragma mark --- CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        DLog(@"discover services error: %@", error.localizedDescription);
        return;
    }
    for (CBService *s in [peripheral services]) {
        if ([s.UUID isEqual:vtService1]) {
            [peripheral discoverCharacteristics:@[vtTxCharacteristic1, vtRxCharacteristic1] forService:s];
        }else if ([s.UUID isEqual:vtService2]) {
            [peripheral discoverCharacteristics:@[vtTxCharacteristic2, vtRxCharacteristic2] forService:s];
        }else if ([s.UUID isEqual:vtHeartRateService]) {
            [peripheral discoverCharacteristics:@[vtHeartRateCharacteristic] forService:s];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error){
        DLog(@"discover characterist error: %@", error.localizedDescription);
        return;
    }
    for (CBCharacteristic *c in [service characteristics]) {
        if ([c.UUID isEqual:vtRxCharacteristic2] ||
            [c.UUID isEqual:vtRxCharacteristic1] ) {
            _rxCharacteristic = c;
            [peripheral setNotifyValue:YES forCharacteristic:c];
        }else if ([c.UUID isEqual:vtTxCharacteristic2] ||
                  [c.UUID isEqual:vtTxCharacteristic1]) {
            _txCharacteristic = c;
        }else if ([c.UUID isEqual:vtHeartRateCharacteristic]) {
            _realHRCharacteristic = c;
        }
    }
    if (_rxCharacteristic && _txCharacteristic) {
        _config = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(servicesAndCharacteristicsConfig:withHelper:)]) {
            [_delegate servicesAndCharacteristicsConfig:YES withHelper:self];
        }
    }else {
        _config = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(servicesAndCharacteristicsConfig:withHelper:)]) {
            [_delegate servicesAndCharacteristicsConfig:NO withHelper:self];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        DLog(@"update value error: %@", error.localizedDescription);
        return;
    }
    if ([characteristic isEqual:_rxCharacteristic]) {
        DLog(@"设备%@收到数据:%@",peripheral,characteristic.value);
    }else if ([characteristic isEqual:_realHRCharacteristic]) {
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
}



@end
