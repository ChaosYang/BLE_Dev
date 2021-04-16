//
//  VTProSendCmd.h
//  LibUseDemo
//
//  Created by viatom on 2020/6/15.
//  Copyright © 2020 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTProTypesDef.h"
#import "VTProPublicUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface VTProSendCmd : NSObject

+ (NSData *)startPing;

+ (NSData *)readInfoPkg;

+ (NSData *)syncTimeWithDate:(NSDate *)date;

+ (NSData *)startReadFile:(NSString *)fileName;

+ (NSData *)readContentWithOffset:(u_int)pkgOffset;

+ (NSData *)endReadFile;

+ (NSData *)startWriteFile:(NSString *)fileName fileSize:(u_int)size cmd:(VTProCmd)cmd;

+ (NSData *)writeContentWithData:(NSData *)subData offset:(u_int)pkgOffset cmd:(VTProCmd)cmd;

+ (NSData *)endWriteFileWithCmd:(VTProCmd)cmd;


@end

NS_ASSUME_NONNULL_END
