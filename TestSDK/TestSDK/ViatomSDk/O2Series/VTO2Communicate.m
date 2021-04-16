//
//  VTO2Communicate.m
//  VTO2Lib
//
//  Created by viatom on 2020/6/28.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "VTO2Communicate.h"
#import "VTO2SendCmd.h"
#import "VTO2ReceiveCmd.h"
#import "VTO2PublicUtils.h"

/**
 Set params
 */
#define SetTIME                   @"SetTIME" //设置时间
#define SetLanguage               @"SetLanguage" //设置语言
#define SetOxiThr                 @"SetOxiThr" //设置血氧震动阈值
#define SetMotor                  @"SetMotor"  //设置震动强度(0、20、40、80、100)
#define SetPedtar                 @"SetPedtar"  //设置计步器目标提醒步数
#define SetLightingMode           @"SetLightingMode"   //设置亮屏模式（0：典型模式，1：憋气模式，2：睡眠模式）
#define SetHeartRateSwitch(name)  ([name hasPrefix:@"O2Ring"] || [name hasPrefix:@"Oxylink"]) ? @"SetHRSwitch" : @"SetHeartRateSwitch" //设置心率震动开关（0：关闭，1：开启）
#define SetHeartRateLowThr(name)  ([name hasPrefix:@"O2Ring"] || [name hasPrefix:@"Oxylink"]) ? @"SetHRLowThr" : @"SetHeartRateLowThr"  //设置心率震动最低阀值（40-60）
#define SetHeartRateHighThr(name) ([name hasPrefix:@"O2Ring"] || [name hasPrefix:@"Oxylink"]) ? @"SetHRHighThr" : @"SetHeartRateHighThr"  //设置心率震动最高阀值（90-180）
#define SetLightStrength(name)    ([name hasPrefix:@"O2Ring"] || [name hasPrefix:@"Oxylink"]) ? @"SetLightStr" : @"SetLightStrength"  //设置屏幕亮度（0：低，1：中，2：高）
#define SetOxiSwitch              @"SetOxiSwitch";   //O2Ring 血氧振动开关
#define SetVolume                 @"SetMotor"//@"SetVolume";   //设置WearO2声音强度(5、10、17、22、35)


@interface VTO2Communicate ()<CBPeripheralDelegate>

/// @brief This characteristic is a writable characteristic of the currently connected peripheral. Need to be set after connection
@property (nonatomic, strong) CBCharacteristic *txCharacteristic;

/// @brief The last data sent was used to resend
@property (nonatomic, strong) NSData *preSendBuf;


/// @brief The dataPool used to store data from the blueTooth
@property (nonatomic,strong) NSMutableData *dataPool;

@property(nonatomic,assign) VTCmdType currentType;

/**
 *  临时读写文件
 */
@property (nonatomic,strong) VTFileToRead *temReadFile;


@property (nonatomic, strong) CBService *uartService;

@property (nonatomic, strong) CBService *devService;

@property (nonatomic, strong) CBService *hrService;

@property (nonatomic, strong) CBCharacteristic *readCharacteristic;

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

@property (nonatomic, strong) CBCharacteristic *notifyHrCharacteristic;


@end


@implementation VTO2Communicate
{
    BOOL _isFirstPkg;
    u_int _pkgLength;
}

static VTO2Communicate *instance = nil;

//+ (VTO2Communicate *)sharedInstance{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[self alloc] init];
//    });
//    return instance;
//}

- (instancetype)init{
    self = [super init];
    if (self) {
        _dataPool = [NSMutableData data];
        _timeout = 5000;
    }
    return self;
}



- (void)didReceiveData:(NSData *)data{
    [_dataPool appendData:data];
    u_int dataLen = (u_int)_dataPool.length;
    if (_isFirstPkg) {
        u_char *buf = (u_char *)_dataPool.bytes;
        if (buf[0] == 0x55 && _dataPool.length >= 7) {
            _pkgLength = *((u_short *)&buf[5]) + 8;
            _isFirstPkg = NO;
        }else if (buf[0] == 0x55) {
            return;
        }else{
            [self clearDataPool];
            return;
        }
    }
    if (dataLen < _pkgLength) {
        return;
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self processAckBuf:_dataPool];
        [self clearDataPool];
    }
    
}


#pragma mark - 回应包
-(void)processAckBuf:(NSData*)buf
{
    __weak typeof(self) weakself = self;
    switch (_currentType) {
        case VTCmdTypeSyncParam:
        case VTCmdTypeSetFactory:
        {
            [VTO2ReceiveCmd judgeCommonResponse:buf callBack:^(BOOL isOk) {
                if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(commonResponse:andResult:)]) {
                    [weakself.delegate commonResponse:weakself.currentType andResult:(isOk ? VTCommonResultSuccess : VTCommonResultFailed)];
                }
                weakself.currentType = VTCmdTypeNone;
                [weakself.dataPool setLength:0];
            }];
            break;
        }
        case VTCmdTypeStartRead:
        {
            DLog(@"Received a start read Cmd %@", buf);
            [VTO2ReceiveCmd judgeStartReadResponse:buf callBack:^(BOOL isOk, u_int fileSize) {
                if (isOk) {
                    if (fileSize == 0) {
                        DLog(@"File length error, end read");
                        [weakself readFileResult:VTFileLoadResultFailed];
                    }else{
                        DLog(@"Start read file content");
                        [self setCurReadFileVals:fileSize];
                        [weakself readContent];
                    }
                }else{
                    DLog(@"Response error, file does't exist");
                    [weakself readFileResult:VTFileLoadResultNotExist];
                }
            }];
            break;
        }
        case VTCmdTypeReading:{
            DLog(@"Received a read content Cmd %@", buf);
            [VTO2ReceiveCmd judgeReadContentResponse:buf callBack:^(BOOL isOk, NSData * _Nullable contentData) {
                if (isOk) {
                    [weakself.curReadFile.fileData appendData:contentData];
                    weakself.curReadFile.curPkgNum ++;
                    if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(postCurrentReadProgress:)]) {
                        [weakself.delegate postCurrentReadProgress:(double)weakself.curReadFile.curPkgNum/(double)weakself.curReadFile.totalPkgNum];
                    }
                    if (weakself.curReadFile.curPkgNum == weakself.curReadFile.totalPkgNum) {
                        [self endRead];
                    }else{
                        [self readContent];
                    }
                }else{
                    DLog(@"Response error");
                    [self readFileResult:VTFileLoadResultFailed];
                }
            }];
            break;
        }
        case VTCmdTypeEndRead:
        {
            DLog(@"Received read completed response");
            [VTO2ReceiveCmd judgeCommonResponse:buf callBack:^(BOOL isOk) {
              
                [self readFileResult:isOk ? VTFileLoadResultSuccess : VTFileLoadResultFailed];
        
            }];
            break;
        }
        case VTCmdTypeGetInfo:
        {
            [VTO2ReceiveCmd judgeGetInfoResponse:buf callBack:^(BOOL isOk, NSData * _Nullable infoData) {
                if (isOk) {
                    DLog(@"read peripheral's information completed");
                }else{
                    DLog(@"read peripheral's information error");
                }
                if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(getInfoWithResultData:)]) {
                    [weakself.delegate getInfoWithResultData:infoData];
                }
            }];
            break;
        }
        case VTCmdTypeGetRealData:
        {
            [VTO2ReceiveCmd judgeRealDataResponse:buf callBack:^(BOOL isOk, NSData * _Nullable realData) {
                if (isOk) {
                    DLog(@"Real-time data has been received");
                }else{
                    DLog(@"Real-time data error");
                }
                if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(realDataCallBackWithData:)]) {
                    [weakself.delegate realDataCallBackWithData:realData];
                }
            }];
            break;
        }
        case VTCmdTypeGetRealPPG:
        {
            [VTO2ReceiveCmd judgeRealPPGResponse:buf callBack:^(BOOL isOk, NSData * _Nullable realPPG) {
                if (isOk) {
                    
                }else{
                    DLog(@"Real-PPG data error");
                }
                if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(realPPGCallBackWithData:)]) {
                    [weakself.delegate realPPGCallBackWithData:realPPG];
                }
            }];
        }
        default:
            break;
    }
}

-(void)setCurReadFileVals:(u_int)fileSize
{
    if(fileSize <= 0){
        DLog(@"Content length is 0");
        return;
    }
    _curReadFile.fileData = [NSMutableData data];
    _curReadFile.curPkgNum = 0;
    _curReadFile.fileSize = fileSize;
    _curReadFile.lastPkgSize = fileSize%VTPkgLengthContent;
    if (_curReadFile.lastPkgSize == 0) {//刚好整数包
        _curReadFile.totalPkgNum = fileSize/VTPkgLengthContent;
        _curReadFile.lastPkgSize = VTPkgLengthContent + VTPkgLengthSend;
    }else{
        _curReadFile.totalPkgNum = fileSize/VTPkgLengthContent + 1;
        _curReadFile.lastPkgSize += VTPkgLengthSend;
    }
    DLog(@"Total file size: %d, Total file pkg number: %d",_curReadFile.fileSize,_curReadFile.totalPkgNum);
}



- (void)beginGetInfo{
    NSData *data = [VTO2SendCmd readInfoPkg];
    _currentType = VTCmdTypeGetInfo;
    [self sendCmdWithData:data delay:_timeout];
}

- (void)beginGetRealData{
    NSData *data = [VTO2SendCmd readRealData];
    _currentType = VTCmdTypeGetRealData;
    [self sendCmdWithData:data delay:_timeout];
}

- (void)beginGetRealPPG{
    NSData *data = [VTO2SendCmd readRealPPG];
    _currentType = VTCmdTypeGetRealPPG;
    [self sendCmdWithData:data delay:_timeout];
}

- (void)beginFactory{
    NSData *data = [VTO2SendCmd setFactory];
    _currentType = VTCmdTypeSetFactory;
    [self sendCmdWithData:data delay:_timeout];
}

- (void)beginToParamType:(VTParamType)paramType content:(NSString *)paramValue{
    NSString *typeStr = [NSString string];
    switch (paramType) {
        case VTParamTypeDate:
            typeStr = SetTIME;
            break;
        case VTParamTypeOxiThr:
            typeStr = SetOxiThr;
            break;
        case VTParamTypeMotor:
            typeStr = SetMotor;
            break;
        case VTParamTypePedtar:
            typeStr = SetPedtar;
            break;
        case VTParamTypeLightingMode:
            typeStr = SetLightingMode;
            break;
        case VTParamTypeLightStrength:
            typeStr = SetLightStrength(_peripheral.name);
            break;
        case VTParamTypeHeartRateSwitch:
            typeStr = SetHeartRateSwitch(_peripheral.name);
            break;
        case VTParamTypeHeartRateLowThr:
            typeStr = SetHeartRateLowThr(_peripheral.name);
            break;
        case VTParamTypeHeartRateHighThr:
            typeStr = SetHeartRateHighThr(_peripheral.name);
            break;
        case VTParamTypeOxiSwitch:
            typeStr = SetOxiSwitch;
            break;
        default:
            break;
    }
    NSString *str = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",typeStr,paramValue];
    NSData *data = [VTO2SendCmd setParamsContent:str];
    _currentType = VTCmdTypeSyncParam;
    [self sendCmdWithData:data delay:_timeout];
}

- (void)beginReadFileWithFileName:(NSString *)fileName{
    NSData *startData = [VTO2SendCmd startReadFile:fileName];
    _curReadFile = [[VTFileToRead alloc] init];
    _curReadFile.fileName = fileName;
    _currentType = VTCmdTypeStartRead;
    [self sendCmdWithData:startData delay:_timeout];
}

- (void)readContent{
    NSData *readData = [VTO2SendCmd readContentWithOffset:[_curReadFile curPkgNum]];
    _currentType = VTCmdTypeReading;
    DLog(@"Sending content Cmd，waiting pkg number-->%d",_curReadFile.curPkgNum);
    [self sendCmdWithData:readData delay:_timeout];
}

- (void)endRead{
    NSData *endData = [VTO2SendCmd endReadFile];
    _currentType = VTCmdTypeEndRead;
    DLog(@"Sending read completed Cmd");
    [self sendCmdWithData:endData delay:_timeout];
}

- (void)readFileResult:(VTFileLoadResult)result{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_curReadFile setEnLoadResult:result];
    _currentType = VTCmdTypeNone;
    _temReadFile = nil;
    _temReadFile = _curReadFile;
    _curReadFile = nil;
    [self clearDataPool];
    if (_delegate && [_delegate respondsToSelector:@selector(readCompleteWithData:)]) {
        [_delegate readCompleteWithData:_temReadFile];
    }
}


#pragma mark - 底层读写函数
//中心设备与外设之间通信   通过NSData类型数据进行通讯   cmd
-(void)sendCmdWithData:(NSData *)cmd delay:(u_int)delay
{
//    NSLog(@"执行底层读写函数！！！");
    [self clearDataPool];
#ifndef BUF_LENGTH
#define BUF_LENGTH 20
#endif
    for (int i=0; i*BUF_LENGTH<cmd.length; i++) {
        if (i > 0) {
            sleep(0.2);
        }
        NSRange range = {i*BUF_LENGTH,((i+1)*BUF_LENGTH)<cmd.length?BUF_LENGTH:cmd.length-i*BUF_LENGTH};
        NSData* subCMD = [cmd subdataWithRange:range];
        DLog(@"current write value : %@", subCMD);
        if (_peripheral.state==CBPeripheralStateConnected) {
            [_peripheral writeValue:subCMD forCharacteristic:_txCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(cmdTimeout) withObject:nil afterDelay:delay/1000.0];
//    DLog(@"Countdown total %fs", delay/1000.0);
}

-(void)cmdTimeout{
    //判断当前状态
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    DLog(@"Time out,End Cmd");
    //判断当前状态
    if (_currentType == VTCmdTypeStartRead || _currentType == VTCmdTypeReading || _currentType == VTCmdTypeEndRead) {
        _currentType = VTCmdTypeNone;
        [self readFileResult:VTFileLoadResultTimeOut];
    }else if (_currentType == VTCmdTypeGetInfo) {
        _currentType = VTCmdTypeNone;
        if (_delegate && [_delegate respondsToSelector:@selector(getInfoWithResultData:)]) {
            [_delegate getInfoWithResultData:nil];
        }
    }else if (_currentType == VTCmdTypeGetRealData) {
        _currentType = VTCmdTypeNone;
        if (_delegate && [_delegate respondsToSelector:@selector(realDataCallBackWithData:)]) {
            [_delegate realDataCallBackWithData:nil];
        }
    }else if (_currentType == VTCmdTypeGetRealPPG) {
        _currentType = VTCmdTypeNone;
        if (_delegate && [_delegate respondsToSelector:@selector(realPPGCallBackWithData:)]) {
            [_delegate realPPGCallBackWithData:nil];
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(commonResponse:andResult:)]) {
            [_delegate commonResponse:_currentType andResult:VTCommonResultTimeOut];
        }
        _currentType = VTCmdTypeNone;
    }

}

-(void)clearDataPool{
    [_dataPool setLength:0];
    _pkgLength = 0;
    _isFirstPkg = YES;
}



- (void)setPeripheral:(CBPeripheral *)peripheral{
    _peripheral = peripheral;
    [self deployServicesAndCharacterists];
}


#pragma mark ---- uuid ----

#define uartServiceUUID [CBUUID UUIDWithString:@"569a1101-b87f-490c-92cb-11ba5ea5167c"]

#define deviceServiceUUID [CBUUID UUIDWithString:@"14839ac4-7d7e-415c-9a42-167340cf2339"]

#define heartRateServiceUUID [CBUUID UUIDWithString:@"180D"]

#define rxCharacteristUUID [CBUUID UUIDWithString:@"569a2000-b87f-490c-92cb-11ba5ea5167c"]

#define txCharacteristicUUID [CBUUID UUIDWithString:@"569a2001-b87f-490c-92cb-11ba5ea5167c"]

#define devRxCharacteristicUUID [CBUUID UUIDWithString:@"0734594A-A8E7-4B1A-A6B1-CD5243059A57"]

#define devTxCharacteristicUUID [CBUUID UUIDWithString:@"8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3"]

#define heartRateCharacteristicUUID [CBUUID UUIDWithString:@"2A37"]

- (void)deployServicesAndCharacterists{
    _peripheral.delegate = self;
    [_peripheral discoverServices:@[uartServiceUUID, deviceServiceUUID, heartRateServiceUUID]];
}

- (void)readRSSI{
    _peripheral.delegate = self;
    [_peripheral readRSSI];
}


#pragma mark ----- CBPeripheral delegate ----
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        DLog(@"Error discovering services : %@, (%@)", peripheral, error.localizedDescription);
        return;
    }
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:uartServiceUUID]) {
            self.uartService = service;
            [_peripheral discoverCharacteristics:@[rxCharacteristUUID, txCharacteristicUUID] forService:self.uartService];
        }else if ([service.UUID isEqual:deviceServiceUUID]) {
            self.devService = service;
            [_peripheral discoverCharacteristics:@[devRxCharacteristicUUID, devTxCharacteristicUUID] forService:self.devService];
        }else if ([service.UUID isEqual:heartRateServiceUUID]) {
            self.hrService = service;
            [_peripheral discoverCharacteristics:nil forService:self.hrService];
        }else{
            DLog(@"Not discovering any available services");
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        DLog(@"Error discovering characteristics : %@, (%@)", peripheral, error.localizedDescription);
        return;
    }
    for (CBCharacteristic *c in service.characteristics) {
        if ([c.UUID isEqual:rxCharacteristUUID] ||
            [c.UUID isEqual:devRxCharacteristicUUID]) {
            self.readCharacteristic = c;
            [_peripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
        }else if ([c.UUID isEqual:txCharacteristicUUID] ||
                  [c.UUID isEqual:devTxCharacteristicUUID]) {
            self.writeCharacteristic = c;
        }else if ([c.UUID isEqual:heartRateCharacteristicUUID]) {
            self.notifyHrCharacteristic = c;
        }
    }
    if (_writeCharacteristic && _readCharacteristic) {
        _txCharacteristic = _writeCharacteristic;
        if (_delegate && [_delegate respondsToSelector:@selector(serviceDeployed:)]) {
            [_delegate serviceDeployed:YES];
        }
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(serviceDeployed:)]) {
            [_delegate serviceDeployed:NO];
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        return;
    }
    DLog(@"update value : %@",characteristic.value);
    if (characteristic == _readCharacteristic) {
        [self didReceiveData:characteristic.value];
    }else if (_notifyHrCharacteristic && characteristic == _notifyHrCharacteristic) {
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    if (_delegate && [_delegate respondsToSelector:@selector(updatePeripheralRSSI:)]) {
        [_delegate updatePeripheralRSSI:RSSI];
    }
}




@end

@implementation VTFileToRead

@end
