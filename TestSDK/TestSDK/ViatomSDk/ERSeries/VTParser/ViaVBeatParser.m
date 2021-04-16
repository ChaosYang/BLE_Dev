//
//  ViaVBeatParser.m
//  ViaCommunicate
//
//  Created by viatom on 2020/3/20.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "ViaVBeatParser.h"

@implementation ViaVBeatParser


+ (void)via_parserVBeatWaveData:(NSData *)waveData callBack:(VBeatWaveCallback)callBack{
    FileHead_t head;
    FileTail_t_V tail;
    VBeatResults *results = [[VBeatResults alloc] init];
    [waveData getBytes:&head range:NSMakeRange(0, sizeof(head))];
    [waveData getBytes:&tail range:NSMakeRange(waveData.length - sizeof(tail), sizeof(tail))];
    NSData *pointData = [waveData subdataWithRange:NSMakeRange(sizeof(FileHead_t), waveData.length - sizeof(FileHead_t) - sizeof(FileTail_t_V))];
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < pointData.length; i+= sizeof(PointData_t)) {
        PointData_t point;
        [pointData getBytes:&point range:NSMakeRange(i, sizeof(PointData_t))];
        VBeatPoint *vbp = [[VBeatPoint alloc] initWithPointStrcut:point];
        [results resultsFromPoint:point];
        [temp addObject:vbp];
    }
    results.avgHR = round(results.hrTotal*1.0/results.hrNumber);
    callBack(head,tail,results,[temp copy]);
}

+ (ConfiguartionER1)via_parserER1Config:(NSData *)normalData{
    ConfiguartionER1 config;
    [normalData getBytes:&config length:normalData.length];
    return config;
}

+ (void)via_parserWaveData:(NSData *)waveData callBackHeadAndTail:(VBeatHeadTailBack)callBack{
    FileHead_t head;
    FileTail_t_V tail;
    [waveData getBytes:&head range:NSMakeRange(0, sizeof(head))];
    [waveData getBytes:&tail range:NSMakeRange(waveData.length - sizeof(tail), sizeof(tail))];
    callBack(head, tail);
}

@end
