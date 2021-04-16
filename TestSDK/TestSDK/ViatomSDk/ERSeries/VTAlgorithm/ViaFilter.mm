//
//  ViaFilter.m
//  DuoEK
//
//  Created by Viatom on 2019/5/5.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import "ViaFilter.h"
#include <iostream>
#include <cstdio>
#include <string.h>
#include <cmath>
#include <stdlib.h>
#include "streamswtqua.h"

using namespace std;


@implementation ViaFilter
{
    StreamSwtQua streamSwtQua;
}


+ (ViaFilter *)shared{
    static ViaFilter *fliter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fliter = [[self alloc] init];
    });
    return fliter;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self resetParams];
    }
    return self;
}


- (void)resetParams{
    streamSwtQua.~StreamSwtQua();
}



- (NSArray *)sfilterPointValue:(NSArray *)ptArray{
    deque<double> outputPoints;
//    DLog(@"ptArray.count %ld",(long)ptArray.count);
    NSMutableArray *fliterArr = [NSMutableArray array];
    for (int i = 0; i < ptArray.count; i ++) {
        double ptValue = [ptArray[i] doubleValue];
        streamSwtQua.GetEcgData(ptValue, outputPoints);
        for (int j = 0; j < outputPoints.size(); j++) {
            [fliterArr addObject:[NSNumber numberWithDouble:outputPoints[j]]];
        }
    }
//    DLog(@"fliterArr.count %ld ，max:%.02f",fliterArr.count,[[fliterArr valueForKeyPath:@"@max.floatValue"] floatValue]);
    return [fliterArr copy];
}

- (NSArray *)filterPointValue:(double)ptValue{
    deque<double> outputPoints;
    NSMutableArray *fliterArr = [NSMutableArray array];
    streamSwtQua.GetEcgData(ptValue, outputPoints);
    for (int i = 0; i < outputPoints.size(); i++) {
        [fliterArr addObject:[NSNumber numberWithDouble:outputPoints[i]]];
    }
//    DLog(@"fliterArr.count %ld ，max:%.02f",fliterArr.count,[[fliterArr valueForKeyPath:@"@max.floatValue"] floatValue]);
    return [fliterArr copy];
}

- (NSArray *)offlineFilterPoints:(NSArray *)ptArray{
    deque <double> outputPoints;
    deque <double> allSig;
    deque <double> outputsize;
    NSInteger dataLen,reduLen,mulSize;
    dataLen = ptArray.count;
    mulSize = dataLen / 256;
    reduLen = dataLen - 256 * mulSize;
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:ptArray];
    NSMutableArray *fliterArr = [NSMutableArray array];
    
    if(reduLen != 0){
        for(int i = dataLen; i < (mulSize+1)*256; i++){
            [tempArr addObject:@(0)];
        }
    }
    if(reduLen == 0){
        for (int i = 0; i < 256 * mulSize; ++i){
            double ptValue = [tempArr[i] doubleValue];
            streamSwtQua.GetEcgData(ptValue, outputPoints);
            for (int j = 0; j < outputPoints.size(); ++j){
                allSig.push_back(outputPoints[j]);
            }
        }
    }else{
        for(int i = 0; i < tempArr.count; i++){
            double ptValue = [tempArr[i] doubleValue];
            streamSwtQua.GetEcgData(ptValue, outputPoints);
            for (int j = 0; j < outputPoints.size(); ++j){
                allSig.push_back(outputPoints[j]);
            }
        }
        if(reduLen < 192){
            for(int i = 0; i < 192 - reduLen; i++){
                allSig.pop_back();
            }
        }
    }
    
    for (int i = 0; i < allSig.size(); ++i) {
        [fliterArr addObject:[NSNumber numberWithDouble:allSig[i]]];
    }
    return [fliterArr copy];
}


@end
