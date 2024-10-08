//
//  ViaCRCCheck.h
//  ViaCommunicate
//
//  Created by viatom on 2020/3/20.
//  Copyright © 2020 viatom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViaCRCCheck : NSObject

+ (uint8_t)calCRC8:(u_char *)RP_ByteData bufSize:(u_int)Buffer_Size;

+(char)crc8_maxin_checkWithChars:(u_char *)chars length:(int)len;

@end

NS_ASSUME_NONNULL_END
