//
//  VTO2ReceiveCmd.m
//  VTO2Lib
//
//  Created by viatom on 2020/6/28.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "VTO2ReceiveCmd.h"
#import "VTO2PublicUtils.h"
#import "VTO2Def.h"

@implementation VTO2ReceiveCmd

+ (void)judgeCommonResponse:(NSData *)data callBack:(VTCommonAck)ack{
    u_char* tempBuf = (u_char*)data.bytes;
    if(tempBuf[0]!=0x55){
        DLog(@"<byte[0]!=0x55>:pkg header error");
        ack(NO);
    }else if (tempBuf[1] != VTAckStatusOK || tempBuf[2] != (u_char)~VTAckStatusOK) {
        DLog(@"byte[1]!= VTAckStatusOK||byte[2] != (u_char)~VTAckStatusOK");
        ack(NO);
    }else if (tempBuf[VTPkgLengthReceive-1]!=[VTO2PublicUtils calCRC8:tempBuf bufSize:VTPkgLengthReceive-1]) {
        DLog(@"CRC error");
        ack(NO);
    }else {
        ack(YES);
    }
}

+ (void)judgeGetInfoResponse:(NSData *)data callBack:(VTGetInfoAck)ack{
    if ([data length] != VTPkgLengthInfo) {
        DLog(@"GetInfoAck pkg length error");
        ack(NO, nil);
    }
    u_char* tempBuf = (u_char*)data.bytes;
    if(tempBuf[0]!=0x55){
        DLog(@"GetInfoAck header error");
        ack(NO, nil);
    }else if (tempBuf[1] != VTAckStatusOK || tempBuf[2] != (u_char)~VTAckStatusOK) {
        DLog(@"GetInfoAck response error");
        ack(NO, nil);
    }else if (tempBuf[VTPkgLengthInfo-1] != [VTO2PublicUtils calCRC8:tempBuf bufSize:VTPkgLengthInfo-1]) {
        DLog(@"CRC error");
        ack(NO, nil);
    }else{
        NSMutableString *infoStr = [NSMutableString string];
        for (int i=7; i<VTPkgLengthInfo; i++) {
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

+ (void)judgeStartReadResponse:(NSData *)data callBack:(VTStartReadAck)ack{
    u_char* tempBuf = (u_char*)data.bytes;
    if(tempBuf[0]!=0x55){
        DLog(@"Start read header error ");
        ack(NO, 0);
    }else if (tempBuf[1] != VTAckStatusOK || tempBuf[2] != (u_char)~VTAckStatusOK) {
        DLog(@"Start read response error");
        ack(NO, 0);
    }else if (tempBuf[VTPkgLengthReceive-1] != [VTO2PublicUtils calCRC8:tempBuf bufSize:VTPkgLengthReceive-1]) {
        DLog(@"CRC error");
        ack(NO, 0);
    }else{
        u_int fileSize = (tempBuf[7]&0xFF) | (tempBuf[8]&0xFF)<<8 | (tempBuf[9]&0xFF)<<16 | (tempBuf[10]&0xFF)<<24;
        ack(YES, fileSize);
    }
}

+ (void)judgeReadContentResponse:(NSData *)data callBack:(VTReadContentAck)ack{
    u_char* buf = (u_char *)data.bytes;
    if(data.length>VTPkgLengthContent+VTPkgLengthSend){
        DLog(@"ReadContentAckPkg length error");
        ack(NO, nil);
    }
    if(buf[0]!=0x55){
        DLog(@"ReadContentAckPkg header error");
        ack(NO, nil);
    }else if (buf[1] != VTAckStatusOK || buf[2] != (u_char)~VTAckStatusOK) {
        DLog(@"ReadContentAckPkg response error");
        ack(NO, nil);
    }else if (buf[data.length-1] != [VTO2PublicUtils calCRC8:buf bufSize:(int)data.length-1]) {
        DLog(@"CRC error");
        ack(NO, nil);
    }else{
        u_short length = buf[5] | buf[6]<<8;
        if (length>VTPkgLengthContent || length>data.length-VTPkgLengthSend) {
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

+ (void)judgeRealDataResponse:(NSData *)data callBack:(VTRealDataAck)ack{
    u_char *buf = (u_char *)data.bytes;
    if (data.length > VTPkgLengthReal) {
        DLog(@"RealDataAckPkg length error");
        ack(NO, nil);
    }
    if(buf[0]!=0x55){
        DLog(@"RealDataAckPkg header error");
        ack(NO, nil);
    }else if (buf[1] != VTAckStatusOK || buf[2] != (u_char)~VTAckStatusOK) {
        DLog(@"RealDataAckPkg response error");
        ack(NO, nil);
    }else if (buf[data.length-1] != [VTO2PublicUtils calCRC8:buf bufSize:(int)data.length-1]) {
        DLog(@"CRC error");
        ack(NO, nil);
    }else{
        NSData *contentData = [data subdataWithRange:NSMakeRange(7, [data length] - 8)];
        ack(YES, contentData);
        
    }
}

+ (void)judgeRealPPGResponse:(NSData *)data callBack:(VTRealPPGAck)ack{
    u_char *buf = (u_char *)data.bytes;
    unsigned int length =   *((u_short *)&buf[5]) + 8;
    if(buf[0]!=0x55){
        DLog(@"RealPPGAckPkg header error");
        ack(NO, nil);
    }else if (length != data.length){
        DLog(@"RealPPGAckPkg Length error");
        ack(NO, nil);
    }else if (buf[1] != VTAckStatusOK || buf[2] != (u_char)~VTAckStatusOK) {
        DLog(@"RealPPGAckPkg response error");
        ack(NO, nil);
    }else if (buf[data.length-1] != [VTO2PublicUtils calCRC8:buf bufSize:(int)data.length-1]) {
        DLog(@"CRC error");
        ack(NO, nil);
    }else{
        NSData *contentData = [data subdataWithRange:NSMakeRange(7, [data length] - 8)];
        ack(YES, contentData);
        
    }
}


@end
