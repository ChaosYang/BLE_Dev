//
//  ViaCommonParser.m
//  ViaCommunicate
//
//  Created by viatom on 2020/3/20.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "ViaCommonParser.h"
#import "ViaCompress.h"
#import "ViaCRCCheck.h"

@implementation ViaCommonParser

+ (void)via_parserAnalysisData:(NSData *)analysisData callBack:(AnalysisCallback)callBack{
    AnalysisTotalResult totalResult;
    AnalysisResult result;
    [analysisData getBytes:&totalResult length:sizeof(totalResult)];
    NSData *resultData = [analysisData subdataWithRange:NSMakeRange(sizeof(totalResult), analysisData.length - sizeof(totalResult))];
    NSInteger length =  resultData.length/sizeof(result);
    AnalysisResult resultArr[length];
    for (int i = 0; i < length; i++) {
        [resultData getBytes:&result range:NSMakeRange(i*sizeof(result), sizeof(result))];
        resultArr[i] = result;
    }
    callBack(totalResult,resultArr);
}

+ (void)via_ackAnalysis:(NSData *)data result:(AckAnalysis)result{
    u_char *dataBuf = (u_char *)data.bytes;
    NSInteger len = (dataBuf[5]&0xFF) | (dataBuf[6]&0xFF) << 8;
    NSData *sourceData = nil;
    if (dataBuf[3] != VT_Type_Normal) {
        NSLog(@"header error，%@",data);
        result(dataBuf[1],dataBuf[3],nil);
        return;
    }else{
        if (len != data.length - 8) {
            NSLog(@"length error，%@",data);
            result(dataBuf[1],dataBuf[3],nil);
            return;
        }
        if (len > 0) {
            if (len > data.length - 8) {
                len = data.length - 8;
            }
            sourceData = [data subdataWithRange:NSMakeRange(7, len)];
        }
        result(dataBuf[1],dataBuf[3],sourceData);
    }
}

+ (DeviceInfo)via_parserDeviceInfo:(NSData *)normalData{
    DeviceInfo info;
    [normalData getBytes:&info length:sizeof(info)];
    return info;
}

+ (BatteryInfo)via_parserBatteryInfo:(NSData *)normalData{
    BatteryInfo info;
    [normalData getBytes:&info length:sizeof(info)];
    return info;
}

+ (Temperature)via_parserTemperature:(NSData *)normalData{
    Temperature info;
    [normalData getBytes:&info length:sizeof(info)];
    return info;
}

+ (FileList)via_parserFileList:(NSData *)normalData{
    FileList info;
    [normalData getBytes:&info length:sizeof(info)];
    return info;
}

+ (FileStartReadReturn)via_parserFileLength:(NSData *)normalData{
    FileStartReadReturn info;
    [normalData getBytes:&info length:sizeof(info)];
    return info;
}

+ (FileData)via_parserFileData:(NSData *)normalData{
    FileData info;
    [normalData getBytes:&info length:sizeof(info)];
    return info;
}

+ (FileWriteStartReturn)via_parserWriteFile:(NSData *)normalData{
    FileWriteStartReturn info;
    [normalData getBytes:&info length:sizeof(info)];
    return info;
}

+ (UserList)via_parserUserList:(NSData *)normalData{
    UserList info;
    [normalData getBytes:&info length:sizeof(info)];
    return info;
}

+ (NSArray *)via_parserPoints:(NSData *)pointData{
    NSMutableArray *temp = [NSMutableArray array];
    Byte *buffer = (Byte *)pointData.bytes;
    [ViaCompress unCompressInit];
    for (int i = 0; i < pointData.length; i++) {
        // 解压原始文件
        short ecg = [ViaCompress unCompressEcg:buffer[i]];
        float ecgmV = [ViaCommonParser via_mVFromShort:ecg];
        float filtermV;
        // 正常值滤波  非正常值不滤波（方便绘制处理）
        if (ecg != UNCOM_RET_INVALI) {
            if (ecg == 0x7FFF) {
               [temp addObject:@(ecg)];
            }else{
               [temp addObject:@(ecgmV)];
            }
        }else{
            filtermV = ecgmV;
        }
    }
    return [temp copy];
}


+ (NSArray *)via_parserOrignalPoints:(NSData *)pointData{
    NSMutableArray *temp = [NSMutableArray array];
    Byte *buffer = (Byte *)pointData.bytes;
    [ViaCompress unCompressInit];
    for (int i = 0; i < pointData.length; i++) {
        // 解压原始文件
        short ecg = [ViaCompress unCompressEcg:buffer[i]];
        // 正常值滤波  非正常值不滤波（方便绘制处理）
        if (ecg != UNCOM_RET_INVALI ) {
            [temp addObject:@(ecg)];
        }else{
        }
    }
    return [temp copy];
}


+ (float)via_mVFromShort:(short)n{
    return n*0.002467;
}

+ (flagBit)via_flagSplit:(u_char)flag{
    flagBit bit;
    bit.rRemark = flag&0x01;
    bit.signalWeak = (flag >> 1)&0x01;
    bit.signalPoor = (flag >> 2)&0x01;
    bit.batteryStatus = (flag >> 6)&0x03;
    return bit;
}

+ (RunStatusBit)via_runStatusSplit:(u_char)run_status{
    RunStatusBit bit;
    bit.currentStatus = run_status&0x0F;
    bit.latestStatus = (run_status >> 4)&0x0F;
    return bit;
    
}




@end
