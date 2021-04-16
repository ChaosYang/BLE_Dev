//
//  VTProCommunicate.m
//  LibUseDemo
//
//  Created by viatom on 2020/6/15.
//  Copyright © 2020 Viatom. All rights reserved.
//

#import "VTProCommunicate.h"
#import "VTProSendCmd.h"
#import "VTProReceiveCmd.h"
#import "VTProFileParser.h"
#import "VTProPublicUtils.h"

#define Home_USER_LIST_FILE_NAME                @"usr.dat"
#define DLC_LIST_FILE_NAME                      @"dlc.dat"  //
#define ECG_LIST_FILE_NAME                      @"ecg.dat"
#define SPO2_LIST_FILE_NAME                     @"oxi.dat"
#define SLM_LIST_FILE_NAME                      @"slm.dat"
#define TEMP_LIST_FILE_NAME                     @"tmp.dat"
#define PED_LIST_FILE_NAME                      @"ped.dat"   //
#define NIBP_LIST_FILE_NAME                     @"nibp.dat"
#define SUGER_LIST_FILE_NAME                    @"glu.dat"

@interface VTProCommunicate ()<CBPeripheralDelegate>

/// @brief The last data sent was used to resend
@property (nonatomic, strong) NSData *preSendBuf;


/// @brief The dataPool used to store data from the blueTooth
@property (nonatomic,strong) NSMutableData *dataPool;

@property (nonatomic,strong) NSMutableData *miniDataPool;

@property(nonatomic,assign) VTProCmdType currentType;

/// @brief This characteristic is a writable characteristic of the currently connected peripheral. Need to be set after connection
@property (nonatomic, strong) CBCharacteristic *txCharacteristic;

/**
 *  临时读写文件
 */
@property (nonatomic,strong) VTProFileToRead *temReadFile;

@property (nonatomic, strong) CBService *uartService;

@property (nonatomic, strong) CBService *devService;

@property (nonatomic, strong) CBService *hrService;

@property (nonatomic, strong) CBCharacteristic *readCharacteristic;

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

@property (nonatomic, strong) CBCharacteristic *notifyHrCharacteristic;

@end


@implementation VTProCommunicate

static VTProCommunicate *instance = nil;
//
//+ (VTProCommunicate *)sharedInstance{
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
        _miniDataPool = [NSMutableData data];
    }
    return self;
}

- (void)didReceiveData:(NSData *)data{
    if (data.length > 0) {
        if (data.length > 3 || data.length <= 44) {
            u_char *h = (u_char *)data.bytes;
            if (h[0] != 0xA5 || h[1] != 0x5A) {
                if(_currentType == VTProCmdTypeNone){
                    DLog(@"1111");
                    return;
                }
                [_dataPool appendData:data];
                u_int dataLen = (u_int)_dataPool.length;
                DLog(@"Receive data length: %d, Target length: %d", dataLen, [self callAckLength]);
                if (dataLen < [self callAckLength]) {
                    return;
                }else{
                    // cancel timeout count
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                    [self processAckBuf:_dataPool];
                    [_dataPool setLength:0];
                }
            }else{
                [_miniDataPool appendData:data];
                u_char dataLen = h[2];
                if (_miniDataPool.length % dataLen == 0 && _miniDataPool.length != 0) {
                    u_char *p = (u_char *)data.bytes;
                    char type = p[3];
                    if (type == 0x01) {
                        type = p[24];
                        if (type == 0x02) {
                            DLog(@"Data include ECG & SpO2");
                            // ecg & spo2
                            VTProMiniObject *pkg = [VTProFileParser parseMiniDataWithBuff:data andType:0x05];
                            if (_delegate && [_delegate respondsToSelector:@selector(realTimeCallBackWithObject:)]) {
                                [_delegate realTimeCallBackWithObject:pkg];
                            }
                            [_miniDataPool setLength:0];
                        }else{
                            DLog(@"Data include ECG");
                            // only ecg
                            VTProMiniObject *pkg = [VTProFileParser parseMiniDataWithBuff:data andType:0x01];
                            if (_delegate && [_delegate respondsToSelector:@selector(realTimeCallBackWithObject:)]) {
                                [_delegate realTimeCallBackWithObject:pkg];
                            }
                            [_miniDataPool setLength:0];
                        }
                    }else if (type == 0x02) {
                        DLog(@"Data include SpO2");
                        // only spo2
                        VTProMiniObject *pkg = [VTProFileParser parseMiniDataWithBuff:data andType:0x02];
                        if (_delegate && [_delegate respondsToSelector:@selector(realTimeCallBackWithObject:)]) {
                            [_delegate realTimeCallBackWithObject:pkg];
                        }
                        [_miniDataPool setLength:0];
                    }else{
                        DLog(@"Unkown data");
                    }
                }
            }
        }
    }
}

- (u_int)callAckLength{
    switch (_currentType) {
        case VTProCmdTypeStartRead:
            return VTProPkgLengthReceive;
        case VTProCmdTypeReading:
            if (_curReadFile.curPkgNum==_curReadFile.totalPkgNum-1) {
                return _curReadFile.lastPkgSize;
            }else{
                return VTProPkgLengthSend + VTProPkgLengthContent;
            }
        case VTProCmdTypeEndRead:
            return VTProPkgLengthReceive;
        case VTProCmdTypeStartWrite:
            return VTProPkgLengthReceive;
        case VTProCmdTypeWriting:
            return VTProPkgLengthReceive;
        case VTProCmdTypeEndWrite:
            return VTProPkgLengthReceive;
        case VTProCmdTypeGetInfo:
            return VTProPkgLengthInfo;
        default:
            return 0;
    }
}

#pragma mark - checkme回应包
-(void)processAckBuf:(NSData*)buf
{
    __weak typeof(self) weakself = self;
    switch (_currentType) {
            //  VTProCmdTypePing/VTProCmdTypeEndRead/VTProCmdTypeStartWrite/VTProCmdTypeWriting/VTProCmdTypeEndWrite/VTProCmdTypeSyncTime/
        case VTProCmdTypePing:
        case VTProCmdTypeStartWrite:
        case VTProCmdTypeWriting:
        case VTProCmdTypeEndWrite:
        case VTProCmdTypeSyncTime:
        {
            [VTProReceiveCmd judgeCommonResponse:buf callBack:^(BOOL isOk) {
                if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(commonResponse:andResult:)]) {
                    [weakself.delegate commonResponse:weakself.currentType andResult:(isOk ? VTProCommonResultSuccess : VTProCommonResultFailed)];
                }
                if (weakself.currentType == VTProCmdTypePing) {
                    if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(currentStateOfPeripheral:)]) {
                        [weakself.delegate currentStateOfPeripheral:VTProStateSyncData];
                    }
                }
                weakself.currentType = VTProCmdTypeNone;
                [weakself.dataPool setLength:0];
            }];
            break;
        }
        case VTProCmdTypeStartRead:
        {
            DLog(@"Received a start read Cmd %@", buf);
            [VTProReceiveCmd judgeStartReadResponse:buf callBack:^(BOOL isOk, u_int fileSize) {
                if (isOk) {
                    if (fileSize == 0) {
                        DLog(@"File length error, end read");
                        [weakself readFileResult:VTProFileLoadResultFailed];
                    }else{
                        DLog(@"Start read file content");
                        [self setCurReadFileVals:fileSize];
                        [weakself readContent];
                    }
                }else{
                    DLog(@"Response error, file does't exist");
                    [weakself readFileResult:VTProFileLoadResultNotExist];
                }
            }];
            break;
        }
        case VTProCmdTypeReading:{
            DLog(@"Received a read content Cmd %@", buf);
            [VTProReceiveCmd judgeReadContentResponse:buf callBack:^(BOOL isOk, NSData * _Nullable contentData) {
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
                    [self readFileResult:VTProFileLoadResultFailed];
                }
            }];
            break;
        }
        case VTProCmdTypeEndRead:
        {
            DLog(@"Received read completed response");
            [VTProReceiveCmd judgeCommonResponse:buf callBack:^(BOOL isOk) {
              
                [self readFileResult:isOk ? VTProFileLoadResultSuccess : VTProFileLoadResultFailed];
        
            }];
            break;
        }
        case VTProCmdTypeGetInfo:
        {
            [VTProReceiveCmd judgeGetInfoResponse:buf callBack:^(BOOL isOk, NSData * _Nullable infoData) {
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
    _curReadFile.lastPkgSize = fileSize%VTProPkgLengthContent;
    if (_curReadFile.lastPkgSize == 0) {//刚好整数包
        _curReadFile.totalPkgNum = fileSize/VTProPkgLengthContent;
        _curReadFile.lastPkgSize = VTProPkgLengthContent + VTProPkgLengthSend;
    }else{
        _curReadFile.totalPkgNum = fileSize/VTProPkgLengthContent + 1;
        _curReadFile.lastPkgSize += VTProPkgLengthSend;
    }
    DLog(@"Total file size: %d, Total file pkg number: %d",_curReadFile.fileSize,_curReadFile.totalPkgNum);
}


- (void)beginPing{
    NSData *data = [VTProSendCmd startPing];
    _currentType = VTProCmdTypePing;
    [self sendCmdWithData:data delay:VTProTimeOutMSPing];
}

- (void)beginGetInfo{
    NSData *data = [VTProSendCmd readInfoPkg];
    _currentType = VTProCmdTypeGetInfo;
    [self sendCmdWithData:data delay:VTProTimeOutMSGeneral];
}

- (void)beginSyncTime:(NSDate *)date{
    NSData *data = [VTProSendCmd syncTimeWithDate:date];
    _currentType = VTProCmdTypeSyncTime;
    [self sendCmdWithData:data delay:VTProTimeOutMSGeneral];
}

- (void)beginReadFileListWithUser:(VTProUser *)user fileType:(VTProFileType)type{
    NSString *userId = user ? [NSString stringWithFormat:@"%d",user.userID] : @"";
    NSString *subFileName = [self createFileName:type];
    if (subFileName == nil) {
        DLog(@"File type is not list type");
        return;
    }
    NSString *fileName = [NSString stringWithFormat:@"%@%@", userId, subFileName];
    [self beginReadFileWithFileName:fileName fileType:type];
}

- (NSString *)createFileName:(VTProFileType)type{
    /*
     VTProFileTypeUserList = 0x01,
     VTProFileTypeDlcList = 0x02,
     VTProFileTypeEcgList = 0x03,
     VTProFileTypeSpO2List = 0x05,
     VTProFileTypeBpList = 0x17,
     VTProFileTypeBgList = 0x18,
     VTProFileTypeTmList = 0x06,
     VTProFileTypeSlmList = 0x04,
     VTProFileTypePedList = 0x0B,
     */
    switch (type) {
        case VTProFileTypeUserList:
            return Home_USER_LIST_FILE_NAME;
        case VTProFileTypeDlcList:
            return DLC_LIST_FILE_NAME;
        case VTProFileTypeEcgList:
            return ECG_LIST_FILE_NAME;
        case VTProFileTypeSpO2List:
            return SPO2_LIST_FILE_NAME;
        case VTProFileTypeBpList:
            return NIBP_LIST_FILE_NAME;
        case VTProFileTypeBgList:
            return SUGER_LIST_FILE_NAME;
        case VTProFileTypeTmList:
            return TEMP_LIST_FILE_NAME;
        case VTProFileTypeSlmList:
            return SLM_LIST_FILE_NAME;
        case VTProFileTypePedList:
            return PED_LIST_FILE_NAME;
        default:
            return nil;
            break;
    }
}

- (void)beginReadDetailFileWithObject:(VTProObject *)object fileType:(VTProFileType)type{
    NSString *fileName = [VTProPublicUtils makeDateFileName:object.dtcDate fileType:type];
    [self beginReadFileWithFileName:fileName fileType:type];
}


- (void)beginReadFileWithFileName:(NSString *)fileName fileType:(VTProFileType)type{
    NSData *startData = [VTProSendCmd startReadFile:fileName];
    _curReadFile = [[VTProFileToRead alloc] initWithFileType:type];
    _curReadFile.fileName = fileName;
    _currentType = VTProCmdTypeStartRead;
    [self sendCmdWithData:startData delay:VTProTimeOutMSGeneral];
}

- (void)readContent{
    NSData *readData = [VTProSendCmd readContentWithOffset:[_curReadFile curPkgNum]];
    _currentType = VTProCmdTypeReading;
    DLog(@"Sending content Cmd，waiting pkg number-->%d",_curReadFile.curPkgNum);
    [self sendCmdWithData:readData delay:VTProTimeOutMSGeneral];
}

- (void)endRead{
    NSData *endData = [VTProSendCmd endReadFile];
    _currentType = VTProCmdTypeEndRead;
    DLog(@"Sending read completed Cmd");
    [self sendCmdWithData:endData delay:VTProTimeOutMSGeneral];
}

- (void)readFileResult:(VTProFileLoadResult)result{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_curReadFile setEnLoadResult:result];
    _currentType = VTProCmdTypeNone;
    _temReadFile = nil;
    _temReadFile = _curReadFile;
    _curReadFile = nil;
    [_dataPool setLength:0];
    if (_delegate && [_delegate respondsToSelector:@selector(readCompleteWithData:)]) {
        [_delegate readCompleteWithData:_temReadFile];
    }
}

- (void)beginWriteFileWithFileName:(NSString *)fileName fileType:(VTProFileType)type andFileData:(NSData *)fileData{
    _curReadFile = [[VTProFileToRead alloc] initWithFileType:type];
    _curReadFile.fileName = fileName;
    _curReadFile.fileData = [fileData mutableCopy];
    _curReadFile.fileSize = (u_int)_curReadFile.fileData.length;
    _curReadFile.lastPkgSize = _curReadFile.fileSize % VTProPkgLengthContent;
    if (_curReadFile.lastPkgSize == 0) {
        _curReadFile.totalPkgNum = _curReadFile.fileSize/VTProPkgLengthContent;
        _curReadFile.lastPkgSize = VTProPkgLengthContent + VTProPkgLengthSend;
    }else{
        _curReadFile.totalPkgNum = _curReadFile.fileSize/VTProPkgLengthContent + 1;
        _curReadFile.lastPkgSize += VTProPkgLengthSend;
    }
    DLog(@"The file length:%d,Total pkg number:%d",_curReadFile.fileSize,_curReadFile.totalPkgNum);
    NSData *writeData ;
    int delay = 0;
    if (_curReadFile.fileType == VTProFileTypeLangPkg) {
        writeData = [VTProSendCmd startWriteFile:fileName fileSize:_curReadFile.fileSize cmd:VTProCmdLangStartUpdate];
        delay = VTProTimeOutMSUpdate;
    }else if (_curReadFile.fileType == VTProFileTypeAppPkg) {
        writeData = [VTProSendCmd startWriteFile:fileName fileSize:_curReadFile.fileSize cmd:VTProCmdAppStartUpdate];
        delay = VTProTimeOutMSUpdate;
    }else{
        writeData = [VTProSendCmd startWriteFile:fileName fileSize:_curReadFile.fileSize cmd:VTProCmdStartWrite];
        delay = VTProTimeOutMSGeneral;
    }
    _currentType = VTProCmdTypeStartWrite;
    [self sendCmdWithData:writeData delay:delay];
}

- (void)writeContent{
    NSData* tempData;
    if (_curReadFile.curPkgNum<_curReadFile.totalPkgNum-1) {
        NSRange range = {_curReadFile.curPkgNum*VTProPkgLengthContent,VTProPkgLengthContent};
        tempData = [_curReadFile.fileData subdataWithRange:(range)];
    }else if(_curReadFile.curPkgNum==_curReadFile.totalPkgNum-1){
        NSRange range = {_curReadFile.curPkgNum*VTProPkgLengthContent,_curReadFile.lastPkgSize - VTProPkgLengthSend};
        tempData = [_curReadFile.fileData subdataWithRange:(range)];
    }else{
        DLog(@"All finished,transfer 'endWrite' method！");
        [self endWrite];
        return;
    }
    NSData *contentData;
    int delay = 0;
    if (_curReadFile.fileType == VTProFileTypeLangPkg) {
        contentData = [VTProSendCmd writeContentWithData:tempData offset:_curReadFile.curPkgNum cmd:VTProCmdLangUpdateData];
        delay = VTProTimeOutMSUpdate;
    }else if (_curReadFile.fileType == VTProFileTypeAppPkg) {
        contentData = [VTProSendCmd writeContentWithData:tempData offset:_curReadFile.curPkgNum cmd:VTProCmdAppUpdateData];
        delay = VTProTimeOutMSUpdate;
    }else{
        contentData = [VTProSendCmd writeContentWithData:tempData offset:_curReadFile.curPkgNum cmd:VTProCmdWriteContent];
        delay = VTProTimeOutMSGeneral;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(postCurrentWriteProgress:)]) {
        [_delegate postCurrentWriteProgress:_curReadFile.curPkgNum*1.0 / _curReadFile.totalPkgNum];
    }
    _curReadFile.curPkgNum ++;
    _currentType = VTProCmdTypeWriting;
    _preSendBuf = contentData;
    [self sendCmdWithData:contentData delay:delay];
}

- (void)endWrite{
    NSData *endData ;
    if (_curReadFile.fileType == VTProFileTypeLangPkg) {
        endData = [VTProSendCmd endWriteFileWithCmd:VTProCmdLangEndUpdate];
    }else if (_curReadFile.fileType == VTProFileTypeAppPkg) {
        [self writeFileResult:VTProFileLoadResultSuccess];
        endData = [VTProSendCmd endWriteFileWithCmd:VTProCmdAppEndUpdate];
    }else{
        endData = [VTProSendCmd endWriteFileWithCmd:VTProCmdEndWrite];
    }
    DLog(@"Sending write completed Cmd");
    _currentType = VTProCmdTypeEndWrite;
    [self sendCmdWithData:endData delay:VTProTimeOutMSGeneral];
}

- (void)writeFileResult:(VTProFileLoadResult)result{
    [_curReadFile setEnLoadResult:result];
    _currentType = VTProCmdTypeNone;
    [_dataPool setLength:0];
    if (result == VTProFileLoadResultSuccess) {
        if (_delegate && [_delegate respondsToSelector:@selector(writeSuccessWithData:)]) {
            [_delegate writeSuccessWithData:_curReadFile];
        }
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(writeFailedWithData:)]) {
            [_delegate writeFailedWithData:_curReadFile];
        }
    }
}

#pragma mark - 底层读写函数
//中心设备与外设之间通信   通过NSData类型数据进行通讯   cmd
-(void)sendCmdWithData:(NSData *)cmd delay:(int)delay
{
//    NSLog(@"执行底层读写函数！！！");
    [_dataPool setLength:0];
#ifndef BUF_LENGTH
#define BUF_LENGTH 132
#endif
    for (int i=0; i*BUF_LENGTH<cmd.length; i++) {
        NSRange range = {i*BUF_LENGTH,((i+1)*BUF_LENGTH)<cmd.length?BUF_LENGTH:cmd.length-i*BUF_LENGTH};
        NSData* subCMD = [cmd subdataWithRange:range];
        if (_peripheral.state==CBPeripheralStateConnected) {
            [_peripheral writeValue:subCMD forCharacteristic:_txCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(cmdTimeout) withObject:nil afterDelay:delay/1000.0];
    DLog(@"Countdown total %fs", delay/1000.0);
}

-(void)cmdTimeout {
    //判断当前状态
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    DLog(@"Time out,End Cmd");
    //判断当前状态
    if (_currentType == VTProCmdTypeStartWrite || _currentType == VTProCmdTypeWriting || _currentType == VTProCmdTypeEndWrite) {
        _currentType = VTProCmdTypeNone;
        [self writeFileResult:VTProFileLoadResultTimeOut];
    }else if (_currentType == VTProCmdTypeStartRead || _currentType == VTProCmdTypeReading || _currentType == VTProCmdTypeEndRead) {
        _currentType = VTProCmdTypeNone;
        [self readFileResult:VTProFileLoadResultTimeOut];
    }else if (_currentType == VTProCmdTypeGetInfo) {
        _currentType = VTProCmdTypeNone;
        if (_delegate && [_delegate respondsToSelector:@selector(getInfoWithResultData:)]) {
            [_delegate getInfoWithResultData:nil];
        }
    }else {
        if (_delegate && [_delegate respondsToSelector:@selector(commonResponse:andResult:)]) {
            [_delegate commonResponse:_currentType andResult:VTProCommonResultTimeOut];
        }
        if (_currentType == VTProCmdTypePing) {
            if (_delegate && [_delegate respondsToSelector:@selector(currentStateOfPeripheral:)]) {
                [_delegate currentStateOfPeripheral:VTProStateMinimoniter];
            }
        }
        _currentType = VTProCmdTypeNone;
    }

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
    [_peripheral readRSSI];
}

#pragma mark ---  CBPeripheral delegate
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

@implementation VTProFileToRead

- (instancetype)initWithFileType:(VTProFileType)fileType{
    self = [super init];
    if (self) {
        _fileType = fileType;
    }
    return self;
}

@end
