//
//  VTProSendCmd.m
//  LibUseDemo
//
//  Created by viatom on 2020/6/15.
//  Copyright © 2020 Viatom. All rights reserved.
//

#import "VTProSendCmd.h"



@implementation VTProSendCmd

+ (NSData *)startPing{
    u_char buf[VTProPkgLengthSend];
    memset(buf,0x00,VTProPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = VTProCmdPing;
    buf[2] = ~VTProCmdPing;
    buf[3] = 0;
    buf[4] = 0;
    buf[5] = 0;
    buf[6] = 0;
    buf[VTProPkgLengthSend-1] = [VTProPublicUtils calCRC8:buf bufSize:VTProPkgLengthSend-1];
    return [NSData dataWithBytes:buf length:VTProPkgLengthSend];
}

+ (NSData *)readInfoPkg{
    u_char buf[VTProPkgLengthSend];
    memset(buf, 0, VTProPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = VTProCmdGetInfo;
    buf[2] = ~VTProCmdGetInfo;
    buf[VTProPkgLengthSend-1] = [VTProPublicUtils calCRC8:buf bufSize:VTProPkgLengthSend-1];
    return [NSData dataWithBytes:buf length:VTProPkgLengthSend];
}

+ (NSData *)syncTimeWithDate:(NSDate *)date{
    char *p;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd,HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSString *str = [NSString stringWithFormat:@"{\"SetTIME\":\"%@\"}",strDate];
    NSData *data =[str dataUsingEncoding:NSUTF8StringEncoding];
    p = (char *)[data bytes];
    unsigned short temp = [data length];
    u_char buf[temp + VTProPkgLengthSend];
    memset(buf,0x00,VTProPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = VTProCmdSyncTime;
    buf[2] = ~VTProCmdSyncTime;
    buf[3] = 0;
    buf[4] = 0;
    buf[5] = (temp & 0x00FF);
    buf[6] = ((temp>>8) & 0x00FF);
    for(int i = 0;i < temp;i++) buf[i+7] = p[i];
    buf[temp + VTProPkgLengthSend-1] = [VTProPublicUtils calCRC8:buf bufSize:temp + VTProPkgLengthSend-1];
    return [NSData dataWithBytes:buf length:temp + VTProPkgLengthSend];
}

+ (NSData *)startReadFile:(NSString *)fileName{
    int bufLength = (int)(VTProPkgLengthSend + fileName.length + 1);
    u_char buf[bufLength];
    memset(buf,0x00,bufLength);
    buf[0] = 0xAA;
    buf[1] = VTProCmdStartRead;
    buf[2] = ~VTProCmdStartRead;
    buf[3] = 0;
    buf[4] = 0;
    buf[5] = bufLength - VTProPkgLengthSend;
    buf[6] = (bufLength - VTProPkgLengthSend) >> 8;
    for (int i=0; i<fileName.length; i++) {
        buf[i+7] = [fileName characterAtIndex:i];
    }
    buf[bufLength-1] = [VTProPublicUtils calCRC8:buf bufSize:bufLength-1];
    return [NSData dataWithBytes:buf length:bufLength];
}

+ (NSData *)readContentWithOffset:(u_int)pkgOffset{
    u_char buf[VTProPkgLengthSend];
    memset(buf,0x00,VTProPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = VTProCmdReadContent;
    buf[2] = ~VTProCmdReadContent;
    buf[3] = pkgOffset;
    buf[4] = pkgOffset >> 8;
    buf[5] = 0;
    buf[6] = 0;
    buf[VTProPkgLengthSend-1] = [VTProPublicUtils calCRC8:buf bufSize:VTProPkgLengthSend-1];
    return [NSData dataWithBytes:buf length:VTProPkgLengthSend];
}

+ (NSData *)endReadFile{
    u_char buf[VTProPkgLengthSend];
    memset(buf,0x00,VTProPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = VTProCmdEndRead;
    buf[2] = ~VTProCmdEndRead;
    buf[3] = 0;
    buf[4] = 0;
    buf[5] = 0;
    buf[6] = 0;
    buf[VTProPkgLengthSend-1] = [VTProPublicUtils calCRC8:buf bufSize:VTProPkgLengthSend-1];
    return [NSData dataWithBytes:buf length:VTProPkgLengthSend];
}

+ (NSData *)startWriteFile:(NSString *)fileName fileSize:(u_int)size cmd:(VTProCmd)cmd{
    int bufLength = (int)(VTProPkgLengthSend + fileName.length + 1 + 4);
    u_char buf[bufLength];
    memset(buf,0x00,bufLength);
    buf[0] = 0xAA;
    buf[1] = cmd;
    buf[2] = ~cmd;
    buf[3] = 0; //包号
    buf[4] = 0;
    buf[5] = bufLength - VTProPkgLengthSend; //数据长度
    buf[6] = (bufLength - VTProPkgLengthSend) >> 8;
    buf[7] = size;
    buf[8] = size >> 8;
    buf[9] = size >> 16;
    buf[10] = size >> 24;
    for (int i=0; i<fileName.length; i++) {
        buf[i+11] = [fileName characterAtIndex:i];
    }
    buf[bufLength-1] = [VTProPublicUtils calCRC8:buf bufSize:bufLength-1];
    return [NSData dataWithBytes:buf length:bufLength];
}

+ (NSData *)writeContentWithData:(NSData *)subData offset:(u_int)pkgOffset cmd:(VTProCmd)cmd{
    if (subData.length > VTProPkgLengthContent) {
        DLog(@"Writing data too long");
        return nil;
    }
    u_char* dataBuf = (u_char *)subData.bytes;
    int bufLenght = (int)(subData.length + VTProPkgLengthSend);
    u_char buf[bufLenght];
    buf[0] = 0xAA;
    buf[1] = cmd;
    buf[2] = ~cmd;
    buf[3] = pkgOffset;
    buf[4] = pkgOffset>>8;
    buf[5] = subData.length;
    buf[6] = subData.length>>8;
    for (int i=0; i<subData.length; i++) {
        buf[i+7] = dataBuf[i];
    }
    buf[bufLenght-1] = [VTProPublicUtils calCRC8:buf bufSize:bufLenght-1];
    return [NSData dataWithBytes:buf length:bufLenght];
}

+ (NSData *)endWriteFileWithCmd:(VTProCmd)cmd{
    u_char buf[VTProPkgLengthSend];
    memset(buf, 0, VTProPkgLengthSend);
    buf[0] = 0xAA;
    buf[1] = cmd;
    buf[2] = ~cmd;
    buf[3] = 0;
    buf[4] = 0;
    buf[5] = 0;
    buf[6] = 0;
    buf[VTProPkgLengthSend-1] = [VTProPublicUtils calCRC8:buf bufSize:VTProPkgLengthSend-1];
    return [NSData dataWithBytes:buf length:VTProPkgLengthSend];
}

@end
