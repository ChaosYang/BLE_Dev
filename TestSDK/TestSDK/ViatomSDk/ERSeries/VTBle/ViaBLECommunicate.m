//
//  ViaBLECommunicate
//  ViHealth
//
//  Created by Viatom on 2018/6/5.
//  Copyright © 2018年 Viatom. All rights reserved.
//

#import "ViaBLECommunicate.h"
#import "ViaBLE.h"



@interface ViaBLECommunicate ()<CBPeripheralDelegate>

/// Peripheral device
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic) BOOL isActive; // 激活状态 激活之后才能收到数据
/**
 *  the dataPool used to store data from the blueTooth
 */
@property (nonatomic,retain) NSMutableData *dataPool;
@property (nonatomic,assign) BOOL isFirstPkg; // 第一包标识   默认否

@property (nonatomic, copy) NotifyHRResult result;
@property (nonatomic, copy) NotifyRSSIValue rssiValue;
@property (nonatomic, copy) DeployStatus deployStatus;

@property (nonatomic, strong) CBCharacteristic *notifyHRCharacteristic;
/// Characteristic value  for write
@property (nonatomic, strong) CBCharacteristic *rxcharacteristic;
/// Characteristic value  for write
@property (nonatomic, strong) CBCharacteristic *txcharacteristic;

@property (nonatomic, strong) CBService *hrService;

@end

@implementation ViaBLECommunicate{
    u_char cmd;
}
u_int via_pkg_length = 0;
u_char via_cmd_type = 0;



//+ (ViaBLECommunicate *)sharedInstance{
//    static ViaBLECommunicate *instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[ViaBLECommunicate alloc] init];
//        instance.dataPool = [NSMutableData dataWithCapacity:10];
//    });
//    return instance;
//}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataPool = [NSMutableData dataWithCapacity:10];
    }
    return self;
}
- (void)enterActiveState:(CBPeripheral *)peripheral{
    _peripheral = peripheral;
    _isActive = YES;
    __weak typeof(self) weakSelf = self;
    [self deployPeriphralServiceAndCharacteristics:^(BOOL completed) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(deployStatus:)]) {
            [weakSelf.delegate deployStatus:completed];
        }
    }];
}

- (void)cancelActiveState{
    _peripheral = nil;
    _isActive = NO;
}

#pragma mark ---  uuid s

+ (CBUUID *) uartServiceUUID
{
  //return [CBUUID UUIDWithString:@"6e400001-b5a3-f393-e0a9-e50e24dcca9e"];
    return [CBUUID UUIDWithString:@"569a1101-b87f-490c-92cb-11ba5ea5167c"];
}

+ (CBUUID *) devServiceUUID
{
    return [CBUUID UUIDWithString:@"14839ac4-7d7e-415c-9a42-167340cf2339"];
}

+ (CBUUID *) txCharacteristicUUID   //data going to the module
{
    //return [CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"];
    return [CBUUID UUIDWithString:@"569a2001-b87f-490c-92cb-11ba5ea5167c"];
}

+ (CBUUID *) devTxCharacteristicUUID   //data going to the module
{
//    return [CBUUID UUIDWithString:@"BA04C4B2-892B-43BE-B69C-5D13F2195392"];
    return [CBUUID UUIDWithString:@"8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3"];
}

+ (CBUUID *) rxCharacteristicUUID  //data coming from the module
{
    //return [CBUUID UUIDWithString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"];
    return [CBUUID UUIDWithString:@"569a2000-b87f-490c-92cb-11ba5ea5167c"];
}

+ (CBUUID *) devRxCharacteristicUUID  //data coming from the module
{
    return [CBUUID UUIDWithString:@"0734594A-A8E7-4B1A-A6B1-CD5243059A57"];
}

+ (CBUUID *) deviceInformationServiceUUID
{
    return [CBUUID UUIDWithString:@"180A"];
}

+ (CBUUID *) hardwareRevisionStringUUID
{
    return [CBUUID UUIDWithString:@"2A27"];
}

+ (CBUUID *)heartRateServiceUUID{
    return [CBUUID UUIDWithString:@"180D"];
}

+ (CBUUID *)heartRateCharacteristic{
    return [CBUUID UUIDWithString:@"2A37"];
}

#pragma mark -- class methods

- (void)via_notifyHeartRate:(NotifyHRResult)result{
    [self notifyHeartRate:result];
}

- (void)via_notifyRSSI:(NotifyRSSIValue)rssi{
    [self notifyRSSI:rssi];
}

- (void)via_getDeviceInfo{
    [ViaBLE via_getDeviceInfoAckDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
    }];
}

- (void)via_getFileList{
    [ViaBLE via_getFileListAckDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
    }];
}

- (void)via_readFileStart:(FileReadStart)start{
    [ViaBLE via_startReadFile:start ackDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
    }];
}

- (void)via_readFile:(FileRead)fileRead{
    [ViaBLE via_readFile:fileRead ackDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
    }];

}

- (void)via_readFileEnd{
    [ViaBLE via_endReadFileAckDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
    }];
}

- (void)via_getRealWave:(SendRate)rate{
    [ViaBLE via_getRealTimeWaveform:rate ackDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutRealData];
    }];
}

- (void)via_getRealData:(SendRate)rate{
    [ViaBLE via_getRealData:rate ackDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutRealData];
    }];
}

- (void)via_getBattery{
    [ViaBLE via_getBatteryAckDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
    }];
}

- (void)via_factoryReset{
    [ViaBLE via_restoreFactoryAckDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutFactory];
    }];
}

- (void)via_allReset{
    [ViaBLE via_productReset:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
    }];
}

- (void)via_factorySet:(FactoryConfig)config{
    [ViaBLE via_factoryConfig:config
                   ackDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
                       via_cmd_type = cmd_type;
                       [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
                   }];
}

- (void)via_getECGConfig{
    [ViaBLE via_getER2ConfigAckDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
    }];
}

- (void)via_setER1Config:(ConfiguartionER1)config{
    [ViaBLE via_setER1Config:config ackDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
    }];
}

- (void)via_setER2Config:(Configuartion)config{
    [ViaBLE via_setER2Config:config ackDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
    }];
}

- (void)via_syncTime:(DeviceTime)time{
    [ViaBLE via_syncDeviceTime:time ackDataCmd:^(u_char cmd_type, NSData * _Nonnull data) {
        via_cmd_type = cmd_type;
        [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
    }];
}

#pragma mark ---

- (void)deployPeriphralServiceAndCharacteristics:(DeployStatus)status{
    _deployStatus = status;
    _peripheral.delegate = self;
    _rxcharacteristic = nil;
    _txcharacteristic = nil;
    _notifyHRCharacteristic = nil;
    [_peripheral discoverServices:@[self.class.uartServiceUUID, self.class.deviceInformationServiceUUID, self.class.devServiceUUID,self.class.heartRateServiceUUID]];
}


- (void)notifyHeartRate:(NotifyHRResult)result{
    if (_notifyHRCharacteristic) {
        _result = result;
        [_peripheral setNotifyValue:YES forCharacteristic:_notifyHRCharacteristic];
    }
}

- (void)notifyRSSI:(NotifyRSSIValue)rssi{
    if (_peripheral) {
        _rssiValue = rssi;
        [_peripheral readRSSI];
    }
}


#pragma mark --
/**
 receive data from periphral

 @param data data from periphral
 */
- (void)didReceiveData:(NSData *)data{
    if (!_isActive) {  //未激活 不用管
        NSLog(@"you needs set isActive to yes");
        return;
    }
    [_dataPool appendData:data];
    u_int dataLen = (u_int)_dataPool.length;
    if (_isFirstPkg) {
        Byte *buf = (Byte *)_dataPool.bytes;
        if (buf[0] == 0xA5 && _dataPool.length >= 7) {
            via_pkg_length = buf[5] + (buf[6] << 8) + 8;  //数据总长度
            _isFirstPkg = NO;
        }else if (buf[0] == 0xA5){
            return;
        }else{
            [self clearDataPool];
            return;
        }
    }
    if(dataLen < via_pkg_length){  //蓝牙数据池的数据长度 小于回应包的长度
        return;
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self processAckBuf:[_dataPool copy]];
        [self clearDataPool];
        via_cmd_type = 0;
    }
}


-(void)calWantBytes:(NSData *)data    //获取回应包的长度
{
    u_char *tempBuf = (u_char*)data.bytes;
    via_pkg_length = tempBuf[5] + (tempBuf[6] << 8) + 8;
    _isFirstPkg = NO;
}

#pragma mark - checkme回应包
-(void)processAckBuf:(NSData *)buf
{
    if (_delegate && [_delegate respondsToSelector:@selector(finishedRequest:)]) {
        [_delegate finishedRequest:buf];
    }
}



#pragma mark - 底层读写函数
//中心设备与外设之间通信   通过NSData类型数据进行通讯   cmd
-(void)sendCmdWithData:(NSData *)cmd Delay:(int)delay
{
//    DLog(@"执行底层读写函数！！！");
    [self clearDataPool];
#ifndef BUF_LENGTH
#define BUF_LENGTH 20
#endif
    NSInteger alength = BUF_LENGTH;
    for (int i=0; i*alength<cmd.length; i++) {
        if (i > 0) {
            sleep(0.2);
        }
        NSRange range = {i*alength,((i+1)*alength)<cmd.length?alength:cmd.length-i*alength};
        NSData* subCMD = [cmd subdataWithRange:range];
        
        //写数据
        if (self.peripheral.state == CBPeripheralStateConnected ) {
            [self.peripheral writeValue:subCMD forCharacteristic:self.txcharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
   
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(cmdTimeout) withObject:nil afterDelay:delay/1000.0];
}

-(void)cmdTimeout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_delegate && [_delegate respondsToSelector:@selector(responseTimeOut:)]) {
        [_delegate responseTimeOut:via_cmd_type];
    }
    [self clearDataPool];
    via_cmd_type = 0;
   
}


// 清理缓存
-(void)clearDataPool
{
    [_dataPool setLength:0];
    via_pkg_length = 0;
    _isFirstPkg = YES;
}


#pragma mark ---  periphral delegate

//***************************** 连接部分  ********************************************
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error discovering services: %@", error.localizedDescription);
        return;
    }
    for (CBService *s in [peripheral services])
    {
        if ([s.UUID isEqual:self.class.uartServiceUUID])
        {
            [self.peripheral discoverCharacteristics:@[self.class.txCharacteristicUUID, self.class.rxCharacteristicUUID] forService:s];
        }
        else if ([s.UUID isEqual:self.class.deviceInformationServiceUUID])
        {
            [self.peripheral discoverCharacteristics:@[self.class.hardwareRevisionStringUUID] forService:s];
        }
        else if ([s.UUID isEqual:self.class.devServiceUUID])
        {
            [self.peripheral discoverCharacteristics:@[self.class.devTxCharacteristicUUID, self.class.devRxCharacteristicUUID] forService:s];
        }else if ([s.UUID isEqual:self.class.heartRateServiceUUID]){
            _hrService = s;
            [self.peripheral discoverCharacteristics:nil forService:s];
        }
    }
}



- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error discovering characteristics: %@", error.localizedDescription);
        return;
    }
    if (!_notifyHRCharacteristic) {
        for (CBCharacteristic *c in [service characteristics]) {
            if ([c.UUID isEqual:self.class.heartRateCharacteristic]){
                _notifyHRCharacteristic = c;
                break;
            }
        }
    }
    if(!_rxcharacteristic || !_txcharacteristic)
    {
        for (CBCharacteristic *c in [service characteristics])
        {
            if ([c.UUID isEqual:self.class.rxCharacteristicUUID] ||
                [c.UUID isEqual:self.class.devRxCharacteristicUUID])
            {
                _rxcharacteristic = c;
                [_peripheral setNotifyValue:YES forCharacteristic:_rxcharacteristic];
                
            }else if ([c.UUID isEqual:self.class.txCharacteristicUUID] ||
                      [c.UUID isEqual:self.class.devTxCharacteristicUUID]) {
                _txcharacteristic = c;
            }
        }
    }
    if (_hrService) {
        if(_rxcharacteristic && _txcharacteristic && _notifyHRCharacteristic){
            if (_deployStatus) {
                _deployStatus(YES);
            }
        }
    }else{
        if(_rxcharacteristic && _txcharacteristic){
            if (_deployStatus) {
                _deployStatus(YES);
            }
        }
    }
    
}
//************************************************************************************

#pragma mark - 数据传输的重要部分
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error)
    {
        NSLog(@"%@",error.localizedDescription);
        return;
    }
    
    
    if (characteristic == _rxcharacteristic)
    {
       
        [self didReceiveData:characteristic.value];
    }else if (characteristic == _notifyHRCharacteristic){
        if (_result) {
            _result(characteristic.value);
        }
    }
    else if ([characteristic.UUID isEqual:self.class.hardwareRevisionStringUUID])
    {
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    if (_rssiValue) {
        _rssiValue(RSSI);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        return;
    }

}



@end




