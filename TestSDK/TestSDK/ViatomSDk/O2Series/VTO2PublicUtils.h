//
//  VTO2PublicUtils.h
//  libCheckme
//
//  Created by 李乾 on 15/4/27.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark --- private enum ----
typedef enum : NSUInteger {
    VTPkgLengthSend = 8,
    VTPkgLengthReceive = 12,
    VTPkgLengthContent = 512,
    VTPkgLengthInfo = 8 + 512,
    VTPkgLengthReal = 21,
    VTPkgLengthPPG = 9,
} VTPkgLength;

typedef enum : u_char {
    VTCmdStartWrite = 0x0,
    VTCmdWriteContent = 0x01,
    VTCmdEndWrite = 0x02,
    VTCmdStartRead = 0x03,
    VTCmdReadContent = 0x04,
    VTCmdEndRead = 0x05,
    VTCmdLangStartUpdate = 0x0A,
    VTCmdLangUpdateData = 0x0B,
    VTCmdLangEndUpdate = 0x0C,
    VTCmdAppStartUpdate = 0x0D,
    VTCmdAppUpdateData = 0x0E,
    VTCmdAppEndUpdate = 0x0F,
    VTCmdGetInfo = 0x14,
    VTCmdPing = 0x15,
    VTCmdSyncTime = 0x16,
    VTCmdGetRealData = 0x17,
    VTCmdSetFactory = 0x18,
    VTCmdGetPPG = 0x1C,
} VTCmd;

typedef enum : u_char {
    VTAckStatusOK = 0x00,
    VTAckStatusErr = 0x01,
} VTAckStatus;

typedef enum : NSUInteger {
    VTTimeOutMSPing = 500,
    VTTimeOutMSGeneral = 5000,
    VTTimeOutMSUpdate = 80000,
} VTTimeOutMS;    /// @brief command request timeout
// --- Write temporarily in this class ----

@interface VTO2PublicUtils : NSObject

+ (uint8_t)calCRC8:(unsigned char *)RP_ByteData bufSize:(unsigned int)Buffer_Size;



@end
