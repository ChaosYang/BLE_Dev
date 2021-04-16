//
//  VTProReceiveCmd.m
//  LibUseDemo
//
//  Created by viatom on 2020/6/15.
//  Copyright © 2020 Viatom. All rights reserved.
//

#import "VTProReceiveCmd.h"
#import "VTProPublicUtils.h"

@implementation VTProReceiveCmd

+ (void)judgeCommonResponse:(NSData *)data callBack:(VTProCommonAck)ack{
    u_char* tempBuf = (u_char*)data.bytes;
    if(tempBuf[0]!=0x55){
        DLog(@"<byte[0]!=0x55>:pkg header error");
        ack(NO);
    }else if (tempBuf[1] != VTProAckStatusOK || tempBuf[2] != (u_char)~VTProAckStatusOK) {
        DLog(@"byte[1]!= VTProAckStatusOK||byte[2] != (u_char)~VTProAckStatusOK");
        ack(NO);
    }else if (tempBuf[VTProPkgLengthReceive-1]!=[VTProPublicUtils calCRC8:tempBuf bufSize:VTProPkgLengthReceive-1]) {
        DLog(@"CRC error");
        ack(NO);
    }else {
        ack(YES);
    }
}

+ (void)judgeGetInfoResponse:(NSData *)data callBack:(VTProGetInfoAck)ack{
    if ([data length] != VTProPkgLengthInfo) {
        DLog(@"GetInfoAck pkg length error");
        ack(NO, nil);
    }
    u_char* tempBuf = (u_char*)data.bytes;
    if(tempBuf[0]!=0x55){
        DLog(@"GetInfoAck header error");
        ack(NO, nil);
    }else if (tempBuf[1] != VTProAckStatusOK || tempBuf[2] != (u_char)~VTProAckStatusOK) {
        DLog(@"GetInfoAck response error");
        ack(NO, nil);
    }else if (tempBuf[VTProPkgLengthInfo-1] != [VTProPublicUtils calCRC8:tempBuf bufSize:VTProPkgLengthInfo-1]) {
        DLog(@"CRC error");
        ack(NO, nil);
    }else{
        NSMutableString *infoStr = [NSMutableString string];
        for (int i=7; i<VTProPkgLengthInfo - VTProPkgLengthSend; i++) {
            if (tempBuf[i] != 0) {
                [infoStr appendFormat:@"%c",tempBuf[i]];
            }else{
                break;
            }
        }
        NSData *infoData = [infoStr dataUsingEncoding:NSUTF8StringEncoding];
        ack(YES, infoData);
    }
}

+ (void)judgeStartReadResponse:(NSData *)data callBack:(VTProStartReadAck)ack{
    u_char* tempBuf = (u_char*)data.bytes;
    if(tempBuf[0]!=0x55){
        DLog(@"Start read header error ");
        ack(NO, 0);
    }else if (tempBuf[1] != VTProAckStatusOK || tempBuf[2] != (u_char)~VTProAckStatusOK) {
        DLog(@"Start read response error");
        ack(NO, 0);
    }else if (tempBuf[VTProPkgLengthReceive-1] != [VTProPublicUtils calCRC8:tempBuf bufSize:VTProPkgLengthReceive-1]) {
        DLog(@"CRC error");
        ack(NO, 0);
    }else{
        u_int fileSize = (tempBuf[7]&0xFF) | (tempBuf[8]&0xFF)<<8 | (tempBuf[9]&0xFF)<<16 | (tempBuf[10]&0xFF)<<24;
        ack(YES, fileSize);
    }
}

+ (void)judgeReadContentResponse:(NSData *)data callBack:(VTProReadContentAck)ack{
    u_char* buf = (u_char *)data.bytes;
    if(data.length>VTProPkgLengthContent+VTProPkgLengthSend){
        DLog(@"ReadContentAckPkg length error");
        ack(NO, nil);
    }
    if(buf[0]!=0x55){
        DLog(@"ReadContentAckPkg header error");
        ack(NO, nil);
    }else if (buf[1] != VTProAckStatusOK || buf[2] != (u_char)~VTProAckStatusOK) {
        DLog(@"ReadContentAckPkg response error");
        ack(NO, nil);
    }else if (buf[data.length-1] != [VTProPublicUtils calCRC8:buf bufSize:(int)data.length-1]) {
        DLog(@"CRC error");
        ack(NO, nil);
    }else{
        u_short length = buf[5] | buf[6]<<8;
        if (length>VTProPkgLengthContent || length>data.length-VTProPkgLengthSend) {
            DLog(@"ReadContentAckPkg length error");
            ack(NO, nil);
        }else{
            u_char tempBuf[length];
            for (int i = 0; i < length; i++) {
                tempBuf[i] = buf[7+i];
            }
            NSData *contentData = [[NSData alloc]initWithBytes:tempBuf length:length];
            ack(YES, contentData);
        }
    }
}

@end
