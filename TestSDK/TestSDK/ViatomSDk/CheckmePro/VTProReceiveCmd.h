//
//  VTProReceiveCmd.h
//  LibUseDemo
//
//  Created by viatom on 2020/6/15.
//  Copyright © 2020 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTProTypesDef.h"

typedef void(^VTProCommonAck)(BOOL isOk);
typedef void(^VTProGetInfoAck)(BOOL isOk, NSData * _Nullable infoData);
typedef void(^VTProStartReadAck)(BOOL isOk, u_int fileSize);
typedef void(^VTProReadContentAck)(BOOL isOk, NSData * _Nullable contentData);



NS_ASSUME_NONNULL_BEGIN

@interface VTProReceiveCmd : NSObject

/// @brief VTProCmdTypePing/VTProCmdTypeEndRead/VTProCmdTypeStartWrite/VTProCmdTypeWriting/VTProCmdTypeEndWrite/VTProCmdTypeSyncTime/
+ (void)judgeCommonResponse:(NSData *)data callBack:(VTProCommonAck)ack;

+ (void)judgeGetInfoResponse:(NSData *)data callBack:(VTProGetInfoAck)ack;

+ (void)judgeStartReadResponse:(NSData *)data callBack:(VTProStartReadAck)ack;

+ (void)judgeReadContentResponse:(NSData *)data callBack:(VTProReadContentAck)ack;

@end

NS_ASSUME_NONNULL_END
