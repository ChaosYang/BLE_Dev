//
//  VTO2SendCmd.m
//  VTO2Lib
//
//  Created by viatom on 2020/6/28.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "VTO2SendCmd.h"
#import "VTO2PublicUtils.h"

@implementation VTO2SendCmd

+ (NSData *)readInfoPkg{
    u_char buf[VTPkgLengthSend];
    memset(buf, 0, VTPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = VTCmdGetInfo;
    buf[2] = ~VTCmdGetInfo;
    buf[VTPkgLengthSend-1] = [VTO2PublicUtils calCRC8:buf bufSize:VTPkgLengthSend-1];
    return [NSData dataWithBytes:buf length:VTPkgLengthSend];
}

+ (NSData *)setParamsContent:(NSString *)jsonString{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    char *p = (char *)data.bytes;
    NSInteger dataLength = data.length;
    u_char buf[dataLength + VTPkgLengthSend];
    memset(buf, 0, dataLength + VTPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = VTCmdSyncTime;
    buf[2] = ~VTCmdSyncTime;
    buf[5] = dataLength & 0xFF;
    buf[6] = (dataLength >> 8) & 0xFF;
    for (int i = 0; i < dataLength; i ++) buf[i+7] = p[i] ;
    buf[dataLength + VTPkgLengthSend - 1] = [VTO2PublicUtils calCRC8:buf bufSize:dataLength + VTPkgLengthSend - 1];
    return [NSData dataWithBytes:buf length:dataLength + VTPkgLengthSend];
}

+ (NSData *)readRealData{
    u_char buf[VTPkgLengthSend];
    memset(buf, 0, VTPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = VTCmdGetRealData;
    buf[2] = ~VTCmdGetRealData;
    buf[VTPkgLengthSend-1] = [VTO2PublicUtils calCRC8:buf bufSize:VTPkgLengthSend-1];
    return [NSData dataWithBytes:buf length:VTPkgLengthSend];
}

+ (NSData *)setFactory{
    u_char buf[VTPkgLengthSend];
    memset(buf, 0, VTPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = VTCmdSetFactory;
    buf[2] = ~VTCmdSetFactory;
    buf[VTPkgLengthSend-1] = [VTO2PublicUtils calCRC8:buf bufSize:VTPkgLengthSend-1];
    return [NSData dataWithBytes:buf length:VTPkgLengthSend];
}


+ (NSData *)startReadFile:(NSString *)fileName{
    int bufLength = (int)(VTPkgLengthSend + fileName.length + 1);
    u_char buf[bufLength];
    memset(buf,0,bufLength);
    buf[0] = 0xAA;
    buf[1] = VTCmdStartRead;
    buf[2] = ~VTCmdStartRead;
    buf[5] = bufLength - VTPkgLengthSend;
    buf[6] = (bufLength - VTPkgLengthSend) >> 8;
    for (int i=0; i<fileName.length; i++) {
        buf[i+7] = [fileName characterAtIndex:i];
    }
    buf[bufLength-1] = [VTO2PublicUtils calCRC8:buf bufSize:bufLength-1];
    return [NSData dataWithBytes:buf length:bufLength];
}

+ (NSData *)readContentWithOffset:(u_int)pkgOffset{
    u_char buf[VTPkgLengthSend];
    memset(buf,0,VTPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = VTCmdReadContent;
    buf[2] = ~VTCmdReadContent;
    buf[3] = pkgOffset;
    buf[4] = pkgOffset >> 8;
    buf[VTPkgLengthSend-1] = [VTO2PublicUtils calCRC8:buf bufSize:VTPkgLengthSend-1];
    return [NSData dataWithBytes:buf length:VTPkgLengthSend];
}

+ (NSData *)endReadFile{
    u_char buf[VTPkgLengthSend];
    memset(buf,0,VTPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = VTCmdEndRead;
    buf[2] = ~VTCmdEndRead;
    buf[VTPkgLengthSend-1] = [VTO2PublicUtils calCRC8:buf bufSize:VTPkgLengthSend-1];
    return [NSData dataWithBytes:buf length:VTPkgLengthSend];
}

+ (NSData *)readRealPPG{
    u_char buf[VTPkgLengthPPG];
    memset(buf, 0, VTPkgLengthPPG);
    buf[0] = 0xAA;
    buf[1] = VTCmdGetPPG;
    buf[2] = ~VTCmdGetPPG;
    buf[5] = 0x01;
    buf[7] = 0x00;
    buf[VTPkgLengthPPG-1] = [VTO2PublicUtils calCRC8:buf bufSize:VTPkgLengthPPG-1];
    return [NSData dataWithBytes:buf length:VTPkgLengthPPG];
}

@end
