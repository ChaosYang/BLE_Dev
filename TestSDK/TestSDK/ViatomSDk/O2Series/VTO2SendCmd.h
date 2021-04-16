//
//  VTO2SendCmd.h
//  VTO2Lib
//
//  Created by viatom on 2020/6/28.
//  Copyright © 2020 viatom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VTO2SendCmd : NSObject

+ (NSData *)readInfoPkg;

+ (NSData *)setParamsContent:(NSString *)jsonString;

+ (NSData *)readRealData;

+ (NSData *)setFactory;

+ (NSData *)startReadFile:(NSString *)fileName;

+ (NSData *)readContentWithOffset:(u_int)pkgOffset;

+ (NSData *)endReadFile;

+ (NSData *)readRealPPG;

@end

NS_ASSUME_NONNULL_END
