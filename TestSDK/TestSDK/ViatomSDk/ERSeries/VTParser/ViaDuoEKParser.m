//
//  DouEKParser.m
//  ViaCommunicate
//
//  Created by viatom on 2020/3/20.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "ViaDuoEKParser.h"
#import "ViaCommonParser.h"

@implementation ViaDuoEKParser



+ (ViaECGAnalysisResult)via_parserResult:(u_int)result{
    if (result == 0x00000000) {
        return ViaECGAnalysisResultRegular;
    }else if (result == 0xFFFFFFFF){
        return ViaECGAnalysisResultPoorSignal;
    }else if (result == 0xFFFFFFFE){
        return ViaECGAnalysisResultLower30s;
    }else if (result == 0xFFFFFFFD){
        return ViaECGAnalysisResultMotion;
    }else if ((result&0x00000001) == 0x00000001){
        return ViaECGAnalysisResultFastHR;
    }else if ((result&0x00000002) == 0x00000002){
        return ViaECGAnalysisResultSlowHR;
    }else{
        return ViaECGAnalysisResultRegular;
    }
    return ViaECGAnalysisResultRegular;
}

+ (void)via_parserWaveData:(NSData *)waveData callBack:(DuoEKWaveCallback)callBack{
    FileHead_t head;
    FileTail_t tail;
    [waveData getBytes:&head range:NSMakeRange(0, sizeof(head))];
    [waveData getBytes:&tail range:NSMakeRange(waveData.length - sizeof(tail), sizeof(tail))];
    NSData *pointData = [waveData subdataWithRange:NSMakeRange(sizeof(head), waveData.length - sizeof(head) - sizeof(tail))];
    NSArray *temp = [ViaCommonParser via_parserPoints:pointData];
    callBack(head,tail,temp);
}

+ (void)via_parserWaveData:(NSData *)waveData callBackHeadAndTail:(DuoEKHeadTailBack)callBack{
    FileHead_t head;
    FileTail_t tail;
    [waveData getBytes:&head range:NSMakeRange(0, sizeof(head))];
    [waveData getBytes:&tail range:NSMakeRange(waveData.length - sizeof(tail), sizeof(tail))];
    callBack(head, tail);
}

+ (RealTimeWaveform)via_parserRealTimeWaveform:(NSData *)normalData{
    RealTimeWaveform info;
    [normalData getBytes:&info length:normalData.length];
    return info;
}

+ (RealTimeData)via_parserRealData:(NSData *)normalData{
    RealTimeData info;
    [normalData getBytes:&info length:normalData.length];
    return info;
}

+ (Configuartion)via_parserER2Config:(NSData *)normalData{
    Configuartion config;
    [normalData getBytes:&config length:normalData.length];
    return config;
}

@end
