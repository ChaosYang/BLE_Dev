//
//  VTProPublicUtils.h
//  libCheckme
//
//  Created by 李乾 on 15/4/27.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTProTypesDef.h"

#pragma mark --- private enum ----
typedef enum : NSUInteger {
    VTProPkgLengthSend = 8,
    VTProPkgLengthReceive = 12,
    VTProPkgLengthContent = 512,
    VTProPkgLengthInfo = 8 + 256,
} VTProPkgLength;

typedef enum : u_char {
    VTProCmdStartWrite = 0x0,
    VTProCmdWriteContent = 0x01,
    VTProCmdEndWrite = 0x02,
    VTProCmdStartRead = 0x03,
    VTProCmdReadContent = 0x04,
    VTProCmdEndRead = 0x05,
    VTProCmdLangStartUpdate = 0x0A,
    VTProCmdLangUpdateData = 0x0B,
    VTProCmdLangEndUpdate = 0x0C,
    VTProCmdAppStartUpdate = 0x0D,
    VTProCmdAppUpdateData = 0x0E,
    VTProCmdAppEndUpdate = 0x0F,
    VTProCmdGetInfo = 0x14,
    VTProCmdPing = 0x15,
    VTProCmdSyncTime = 0x16,
} VTProCmd;

typedef enum : u_char {
    VTProAckStatusOK = 0x00,
    VTProAckStatusErr = 0x01,
} VTProAckStatus;

typedef enum : NSUInteger {
    VTProTimeOutMSPing = 500,
    VTProTimeOutMSGeneral = 5000,
    VTProTimeOutMSUpdate = 80000,
} VTProTimeOutMS;    /// @brief command request timeout
// --- Write temporarily in this class ----

@interface VTProPublicUtils : NSObject

+ (NSString*)makeDateFileName:(NSDateComponents*)date fileType:(VTProFileType)type;


+ (uint8_t)calCRC8:(unsigned char *)RP_ByteData bufSize:(unsigned int) Buffer_Size;



@end
