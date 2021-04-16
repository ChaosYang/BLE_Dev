//
//  ViaBLE.m
//  DuoEK
//
//  Created by Viatom on 2019/4/9.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import "ViaBLE.h"
#import "ViaCompress.h"
#import "ViaFilter.h"
#import "ViaCRCCheck.h"



#define COMMON_LENGTH 8

@implementation ViaBLE

+ (instancetype)shared{
    return [[ViaBLE alloc] init];
}

#pragma mark ----   request/send
#pragma mark ----   common

+ (void)via_echoWithData:(NSData *)echoData ackDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_Echo data:echoData pkgNum:0];
    handle(VT_CMD_Echo,data);
}

+ (void)via_getDeviceInfoAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_GetDeviceInfo data:nil pkgNum:0];
    handle(VT_CMD_GetDeviceInfo,data);
}

+ (void)via_deviceResetAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_Reset data:nil pkgNum:0];
    handle(VT_CMD_Reset,data);
}

+ (void)via_restoreFactoryAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_Restore data:nil pkgNum:0];
    handle(VT_CMD_Restore,data);
}

+ (void)via_productReset:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_ProductReset data:nil pkgNum:0];
    handle(VT_CMD_ProductReset,data);
}

+ (void)via_getBatteryAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_GetBattery data:nil pkgNum:0];
    handle(VT_CMD_GetBattery,data);
}

+ (void)via_startFirmwareUpdate:(StartFirmwareUpdate)firmware ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&firmware length:sizeof(firmware)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_UpdateFirmware data:dataRes pkgNum:0];
    handle(VT_CMD_UpdateFirmware,data);
}

+ (void)via_firmwareUpdate:(FirmwareUpdate)firmware ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&firmware length:sizeof(firmware)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_UpdateFirmwareData data:dataRes pkgNum:0];
    handle(VT_CMD_UpdateFirmwareData,data);
}

+ (void)via_endFirmwareUpdateAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_UpdateFirmwareEnd data:nil pkgNum:0];
    handle(VT_CMD_UpdateFirmwareEnd,data);
}

+ (void)via_startLanguageUpdate:(StartLanguageUpdate)language ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&language length:sizeof(language)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_UpdateLanguage data:dataRes pkgNum:0];
    handle(VT_CMD_UpdateLanguage,data);
}

+ (void)via_languageUpdate:(LanguageUpdate)language ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&language length:sizeof(language)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_UpdateLanguageIng data:dataRes pkgNum:0];
    handle(VT_CMD_UpdateLanguageIng,data);
}

+ (void)via_endLanguageUpdateAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_UpdateLanguageEnd data:nil pkgNum:0];
    handle(VT_CMD_UpdateLanguageEnd,data);
}

+ (void)via_factoryConfig:(FactoryConfig)config ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&config length:sizeof(config)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_RestoreInfo data:dataRes pkgNum:0];
    handle(VT_CMD_RestoreInfo,data);
}

+ (void)via_encryptAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_Encrypt data:nil pkgNum:0];
    handle(VT_CMD_Encrypt,data);
}

+ (void)via_syncDeviceTime:(DeviceTime)time ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&time length:sizeof(time)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_SyncTime data:dataRes pkgNum:0];
    handle(VT_CMD_SyncTime,data);
}

+ (void)via_getDeviceTempAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_GetDeviceTemp data:nil pkgNum:0];
    handle(VT_CMD_GetDeviceTemp,data);
}

+ (void)via_getFileListAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_GetFileList data:nil pkgNum:0];
    handle(VT_CMD_GetFileList,data);
}

+ (void)via_startReadFile:(FileReadStart)read ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&read length:sizeof(read)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_StartRead data:dataRes pkgNum:0];
    handle(VT_CMD_StartRead,data);
}

+ (void)via_readFile:(FileRead)read ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&read length:sizeof(read)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_ReadFile data:dataRes pkgNum:0];
    handle(VT_CMD_ReadFile,data);
}

+ (void)via_endReadFileAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_EndRead data:nil pkgNum:0];
    handle(VT_CMD_EndRead,data);
}

+ (void)via_startWriteFileAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_StartWrite data:nil pkgNum:0];
    handle(VT_CMD_StartWrite,data);
}

+ (void)via_writeFile:(FileWrite)write ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&write length:sizeof(write)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_WriteData data:dataRes pkgNum:0];
    handle(VT_CMD_WriteData,data);
}

+ (void)via_endWriteFileAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_EndWrite data:nil pkgNum:0];
    handle(VT_CMD_EndWrite,data);
}

+ (void)via_deleteFileByName:(NSString *)fileName ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes =[fileName dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_DeleteFile data:dataRes pkgNum:0];
    handle(VT_CMD_DeleteFile,data);
}

+ (void)via_getUserListAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_GetUserList data:nil pkgNum:0];
    handle(VT_CMD_GetUserList,data);
}

+ (void)via_enterDfuModelAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VT_CMD_EnterDFU data:nil pkgNum:0];
    handle(VT_CMD_EnterDFU,data);
}

#pragma mark ----   ER1
+ (void)via_setER1Config:(ConfiguartionER1)config ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&config length:sizeof(config)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VTECG_Cmd_SetConfig data:dataRes pkgNum:0];
    handle(VTECG_Cmd_SetConfig,data);
}

#pragma mark ----   ER2
+ (void)via_getRealTimeWaveform:(SendRate)rate ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&rate length:sizeof(rate)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VTECG_Cmd_GetRealWave data:dataRes pkgNum:0];
    handle(VTECG_Cmd_GetRealWave,data);
}

+ (void)via_getRealData:(SendRate)rate ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&rate length:sizeof(rate)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VTECG_Cmd_GetRealData data:dataRes pkgNum:0];
    handle(VTECG_Cmd_GetRealData,data);
}

+ (void)via_getER2ConfigAckDataCmd:(AckDataCmd)handle{
    NSData *data = [[ViaBLE shared] via_cmdWithType:VTECG_Cmd_GetConfig data:nil pkgNum:0];
    handle(VTECG_Cmd_GetConfig,data);
}

+ (void)via_setER2Config:(Configuartion)config ackDataCmd:(AckDataCmd)handle{
    NSData *dataRes = [NSData dataWithBytes:&config length:sizeof(config)];
    NSData *data = [[ViaBLE shared] via_cmdWithType:VTECG_Cmd_SetConfig data:dataRes pkgNum:0];
    handle(VTECG_Cmd_SetConfig,data);
}

#pragma mark ---- base

- (nonnull NSData *)via_cmdWithType:(u_char)type data:(NSData *)data pkgNum:(int)pkgNum{
    u_char *dataBuf = (u_char *)data.bytes;
    int bufLength = (int)data.length + COMMON_LENGTH;
    u_char buf[bufLength];
    buf[0] = (u_char)ViaBLE_Header;
    buf[1] = (u_char)type;
    buf[2] = (u_char)~type;
    buf[3] = (u_char)VT_Type_Request;
    buf[4] = (u_char)pkgNum;
    buf[5] = (u_char)data.length;
    buf[6] = (u_char)data.length >> 8;
    for (int i = 0; i < data.length; i ++) {
        buf[i+7] = dataBuf[i];
    }
    buf[bufLength-1] = [ViaCRCCheck calCRC8:buf bufSize:bufLength-1];
    return [NSData dataWithBytes:buf length:bufLength];
}

/**
 @param cArray c array
 @param buf raw data-> bytes
 @param bufIndex first element index
 */
- (void)assignCArray:(u_char *)cArray buf:(u_char *)buf bufIndex:(int)bufIndex{
    size_t cLen = strlen((char *)cArray);
    for (int i = 0; i < cLen; i ++) {
        cArray[i] = buf[bufIndex + i];
    }
}



@end

