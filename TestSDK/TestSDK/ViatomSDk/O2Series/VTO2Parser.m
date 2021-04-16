//
//  VTO2Parser.m
//  VTO2Lib
//
//  Created by viatom on 2020/6/28.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "VTO2Parser.h"
#import "VTO2Def.h"

#define LE_P2U16(p,u) do{u=0;u = (p)[0]|((p)[1]<<8);}while(0)

#define LE_P2U32(p,u) do{u=0;u = (p)[0]|((p)[1]<<8)|((p)[2]<<16)|((p)[3]<<24);}while(0)

#define BE_P2U16(p,u) do{u=0;u = ((p)[0]<<8)|((p)[1]);}while(0)
#define BE_P2U32(p,u) do{u=0;u = ((p)[0]<<24)|((p)[1]<<16)|((p)[2]<<8)|((p)[3]);}while(0)

#define P2U16(p,u) LE_P2U16((p),(u))
#define P2U32(p,u) LE_P2U32((p),(u))


@implementation VTO2Parser

+ (VTO2Info *)parseO2InfoWithData:(NSData *)infoData{
    NSError *error ;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:infoData options:NSJSONReadingMutableLeaves error:&error];
    
    if (!error) {
        VTO2Info *info = [[VTO2Info alloc] init];
        info.region = [dic objectForKey:@"Region"];
        info.model = [dic objectForKey:@"Model"];
        info.hardware = [dic objectForKey:@"HardwareVer"];
        info.software = [dic objectForKey:@"SoftwareVer"];
        info.languageVer = [dic objectForKey:@"LanguageVer"];
        info.curLanguage = [dic objectForKey:@"CurLanguage"];
        info.sn = [dic objectForKey:@"SN"];
        info.spcpVer = [dic objectForKey:@"SPCPVer"];
        info.fileVer = [dic objectForKey:@"FileVer"];
        info.curDate = [dic objectForKey:@"CurTIME"];
        info.curBattery = [dic objectForKey:@"CurBAT"];
        info.fileList = [dic objectForKey:@"FileList"];
        info.curOxiThr = [dic objectForKey:@"CurOxiThr"];
        info.curMotor = [dic objectForKey:@"CurMotor"];
        info.curPedThr = [dic objectForKey:@"CurPedtar"];
        info.curMode = [dic objectForKey:@"CurMode"];
        info.curBatState = [dic objectForKey:@"CurBatState"];
        info.curState = [dic objectForKey:@"CurState"];
        info.blVer = [dic objectForKey:@"BootloaderVer"];
        info.lightingMode = [dic objectForKey:@"LightingMode"];
        if ([[dic allKeys] containsObject:@"HRSwitch"]) {
            info.hrSwitch = [dic objectForKey:@"HRSwitch"];   //
        }else{
            info.hrSwitch = [dic objectForKey:@"HeartRateSwitch"];
        }
        if ([[dic allKeys] containsObject:@"HRLowThr"]) {
            info.hrLowThr = [dic objectForKey:@"HRLowThr"];
        }else{
            info.hrLowThr = [dic objectForKey:@"HeartRateLowThr"];
        }
        if ([[dic allKeys] containsObject:@"HRHighThr"]) {
            info.hrHighThr = [dic objectForKey:@"HRHighThr"];
        }else{
            info.hrHighThr = [dic objectForKey:@"HeartRateHighThr"];
        }
        if ([[dic allKeys] containsObject:@"LightStr"]) {
            info.lightStrength = [dic objectForKey:@"LightStr"];
        }else{
            info.lightStrength = [dic objectForKey:@"LightStrength"];
        }
        info.oxiSwitch = [dic objectForKey:@"OxiSwitch"];
        info.branchCode = [dic objectForKey:@"BranchCode"];
        return info;
    }else{
        DLog(@"error: %@",error);
    }
    return nil;
}


+ (VTO2Object *)parseO2ObjectWithData:(NSData *)fileData{
    NSAssert(fileData != nil, @"The file does not exist.");
    NSAssert(fileData.length >= 40, @"The file's length error");
    u_char *b = (u_char *)fileData.bytes;
    NSAssert(b[0] >= 2, @"The file's version not support");
    VTO2Object *obj = [[VTO2Object alloc] init];
    obj.fileVer = b[0];
    obj.mode = b[1];
    P2U16(&b[2], obj.year);
    obj.month = b[4];
    obj.day = b[5];
    obj.hour = b[6];
    obj.minute = b[7];
    obj.second = b[8];
    P2U16(&b[13], obj.recordTime);
    obj.averageSpO2 = b[17];
    obj.lowestSpO2 = b[18];
    obj.dropsL3 = b[19];
    obj.dropsL4 = b[20];
    obj.T90 = b[21];
    P2U16(&b[22], obj.dropTime);
    obj.dropNumber = b[24];
    obj.score = b[25]/10.0;
    P2U32(&b[26], obj.steps);
    obj.waveData = [fileData subdataWithRange:NSMakeRange(40, fileData.length - 40)];
    return obj;
}


+ (NSArray<VTO2WaveObject *> *)parseO2WaveObjectArrayWithWaveData:(NSData *)waveData{
    NSAssert(waveData != nil, @"Wave file does not exist.");
    u_char *b = (u_char *)waveData.bytes;
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < waveData.length; i += 5) {
        VTO2WaveObject *wObj = [[VTO2WaveObject alloc] init];
        wObj.spo2 = b[i];
        wObj.hr = *((u_short *)&b[i+1]);
        wObj.ac_v_s = b[i+3];
        wObj.spo2Mark = b[i+4] & 0x80;
        wObj.hrMark = b[i+4] & 0x60;
        [tempArr addObject:wObj];
    }
    return [tempArr copy];
}

+ (VTRealObject *)parseO2RealObjectWithData:(NSData *)realData{
    u_char *b = (u_char *)realData.bytes;
    VTRealObject *rObj = [[VTRealObject alloc] init];
    rObj.spo2 = b[0];
    rObj.hr = *((u_short *)&b[1]);
    rObj.battery = b[7];
    rObj.batState = b[8];
    rObj.vector = b[9];
    rObj.pi = b[10];
    rObj.leadState = b[11];
    return rObj;
}



+ (NSArray<VTRealPPG *> *)parseO2RealPPGWithData:(NSData *)realPPG{
#pragma pack(1)
struct PrimaryDataOxi {
    int ir;
    int red;
    u_char motion;
};

struct PrimaryOxi {
    u_short data_len;
    struct PrimaryDataOxi data[300];
};
#pragma pack()
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:10];
    struct PrimaryOxi *primary = (struct PrimaryOxi *)realPPG.bytes;
    for (int i = 0; i < primary->data_len; i ++) {
        VTRealPPG *ppg = [[VTRealPPG alloc] init];
        ppg.ir = primary->data[i].ir;
        ppg.red = primary->data[i].red;
        ppg.motion = primary->data[i].motion;
        [tempArray addObject:ppg];
    }
    return [tempArray copy];
}

@end
