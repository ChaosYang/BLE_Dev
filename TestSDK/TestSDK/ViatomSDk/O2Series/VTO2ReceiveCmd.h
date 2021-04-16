//
//  VTO2ReceiveCmd.h
//  VTO2Lib
//
//  Created by viatom on 2020/6/28.
//  Copyright © 2020 viatom. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^VTCommonAck)(BOOL isOk);
typedef void(^VTGetInfoAck)(BOOL isOk, NSData * _Nullable infoData);
typedef void(^VTStartReadAck)(BOOL isOk, u_int fileSize);
typedef void(^VTReadContentAck)(BOOL isOk, NSData * _Nullable contentData);
typedef void(^VTRealDataAck)(BOOL isOk, NSData * _Nullable realData);
typedef void(^VTRealPPGAck)(BOOL isOk, NSData * _Nullable realPPG);

NS_ASSUME_NONNULL_BEGIN

@interface VTO2ReceiveCmd : NSObject

+ (void)judgeCommonResponse:(NSData *)data callBack:(VTCommonAck)ack;

+ (void)judgeGetInfoResponse:(NSData *)data callBack:(VTGetInfoAck)ack;

+ (void)judgeStartReadResponse:(NSData *)data callBack:(VTStartReadAck)ack;

+ (void)judgeReadContentResponse:(NSData *)data callBack:(VTReadContentAck)ack;

+ (void)judgeRealDataResponse:(NSData *)data callBack:(VTRealDataAck)ack;

+ (void)judgeRealPPGResponse:(NSData *)data callBack:(VTRealPPGAck)ack;

@end

NS_ASSUME_NONNULL_END
