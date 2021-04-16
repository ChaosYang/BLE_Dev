//
//  ViaCompress.h
//  DuoEK
//
//  Created by Viatom on 2019/5/7.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>

#define    COM_MAX_VAL            (127)            //压缩最大值
#define    COM_MIN_VAL            (-127)            //压缩最小值
#define    COM_EXTEND_MAX_VAL    (382)            //压缩扩展最大值
#define    COM_EXTEND_MIN_VAL    (-382)            //压缩扩展最小值

#define    COM_RET_ORIGINAL    (-128)        //需要保存原始值返回值
#define    COM_RET_POSITIVE    (127)        //需要保存扩展数为正数返回值
#define    COM_RET_NEGATIVE    (-127)        //需要保存扩展数为负数返回值

#define    UNCOM_RET_INVALI    (-32768)        //解压无需处理返回值

//signed char Compress_Initialize_ECG (short ECG_time, short ECG_RATE);
//signed char Compress_Alg_ECG(short ECG_data, unsigned char *extend_data);
//
//short unCompress_Initialize_ECG ();
//short unCompress_Alg_ECG (signed char ECG_compress_data);

NS_ASSUME_NONNULL_BEGIN

@interface ViaCompress : NSObject

+ (void)unCompressInit;

+ (short)unCompressEcg:(char)compress_data;

@end

NS_ASSUME_NONNULL_END
