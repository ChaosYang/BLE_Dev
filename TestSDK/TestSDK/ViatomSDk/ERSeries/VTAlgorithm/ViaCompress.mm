//
//  ViaCompress.m
//  DuoEK
//
//  Created by Viatom on 2019/5/7.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import "ViaCompress.h"

//#define ECG_SAMPLE_RATE                250                        // 分析算法采用的采样率，250Hz

static char unCom_Num;
static int Last_Com_data;

//差分解压缩初始化
short unCompress_Initialize_ECG ()
{
    unCom_Num=0;
    Last_Com_data = 0;
    
    return 0;
}
//差分解压缩
short unCompress_Alg_ECG (signed char ECG_compress_data)
{
    short ECG_data = 0;
    
    //标志位
    
    switch (unCom_Num)
    {
        case 0:
            if (ECG_compress_data == COM_RET_ORIGINAL) {
                unCom_Num = 1;
                ECG_data = UNCOM_RET_INVALI;
            } else if (ECG_compress_data == COM_RET_POSITIVE){        //正
                unCom_Num = 3;
                ECG_data = UNCOM_RET_INVALI;
            } else if (ECG_compress_data == COM_RET_NEGATIVE) {        //负
                unCom_Num = 4;
                ECG_data = UNCOM_RET_INVALI;
            } else {
                ECG_data = Last_Com_data + ECG_compress_data;
                Last_Com_data = ECG_data;
            }
            break;
        case 1:            //原始数据字节低位
            Last_Com_data = (unsigned char)ECG_compress_data;
            unCom_Num = 2;
            ECG_data = UNCOM_RET_INVALI;
            break;
        case 2:            //原始数据字节高位
            ECG_data = Last_Com_data + (ECG_compress_data << 8);
            Last_Com_data = ECG_data;
            unCom_Num = 0;
            break;
        case 3:
            ECG_data = COM_MAX_VAL + (Last_Com_data + (unsigned char)ECG_compress_data);
            Last_Com_data = ECG_data;
            unCom_Num = 0;
            break;
        case 4:
            ECG_data = COM_MIN_VAL + (Last_Com_data - (unsigned char)ECG_compress_data);
            Last_Com_data = ECG_data;
            unCom_Num = 0;
            break;
        default:
            break;
    }
    return ECG_data;
}


@implementation ViaCompress

+ (void)unCompressInit{
    unCompress_Initialize_ECG();
}

+ (short)unCompressEcg:(char)compress_data{
    return unCompress_Alg_ECG(compress_data);
}

@end
