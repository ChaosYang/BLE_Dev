//
//  VTProFileParser.m
//  BTHealth
//
//  Created by demo on 13-11-4.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "VTProFileParser.h"

#define ECG_RESULT_ARRAYS ([NSArray arrayWithObjects:@"Regular ECG Rhythm", @"High Heart Rate",@"Low Heart Rate",@"High QRS Value",@"High ST Value",@"Low ST Value",@"Irregular ECG Rhythm", @"Suspected Premature Beat",@"Unable to Analyze",nil])

#define LE_P2U16(p,u) do{u=0;u = (p)[0]|((p)[1]<<8);}while(0)

#define LE_P2U32(p,u) do{u=0;u = (p)[0]|((p)[1]<<8)|((p)[2]<<16)|((p)[3]<<24);}while(0)

#define BE_P2U16(p,u) do{u=0;u = ((p)[0]<<8)|((p)[1]);}while(0)
#define BE_P2U32(p,u) do{u=0;u = ((p)[0]<<24)|((p)[1]<<16)|((p)[2]<<8)|((p)[3]);}while(0)

#define P2U16(p,u) LE_P2U16((p),(u))
#define P2U32(p,u) LE_P2U32((p),(u))



@implementation VTProFileParser


+ (NSArray <VTProUser *>*)parseUserList_WithFileData:(NSData *)data{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    unsigned char *bytes = (unsigned char*)data.bytes;
    int dataLen = (int)data.length;   // 27*i
    for(int left = dataLen; left >= 27; left -= 27){  //一个用户占27个字节
        unsigned char *p = bytes + dataLen - left;
        
        VTProUser *aUser = [[VTProUser alloc] init];
        aUser.userID = p[0];
        
        char nameBuff[17] = {0x00};
        int i = 0 ;
        for(i=0;((char *)(p+1))[i] != '\0' && i < 16; ++i)
        {
            nameBuff[i] = ((char *)(p+1))[i];
        }
        nameBuff[i] = '\0';
        aUser.userName = [NSString stringWithUTF8String:nameBuff];  //[NSString stringWithCString:(char *)(p+1) length:16];
        aUser.iconID = p[17];
        aUser.gender = (p[18] == 0 ? VTGender_FeMale : VTGender_Male);
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[19], dtc.year);
        dtc.month = p[21];
        dtc.day = p[22];
        aUser.birthday = dtc;
        u_short w = 0,h=0;
        P2U16(&p[23], w);
        P2U16(&p[25], h);
        aUser.weight = (double)w / 10;
        aUser.height = (double)h;
        [arr addObject:aUser];
    }
    NSLog(@"UserList parse completed！！！");
    return arr;
}

+ (VTProInfo *)parseProInfoWithData:(NSData *)data{
    VTProInfo *info = [[VTProInfo alloc] init];
    NSError *err;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
    if (err) {
      return nil;
    }
    info.region = [jsonObject objectForKey:@"Region"];
    info.model = [jsonObject objectForKey:@"Model"];
    info.hardware = [jsonObject objectForKey:@"HardwareVer"];
    info.software = [jsonObject objectForKey:@"SoftwareVer"];
    info.language = [jsonObject objectForKey:@"LanguageVer"];
    info.theCurLanguage = [jsonObject objectForKey:@"CurLanguage"];
    info.sn = [jsonObject objectForKey:@"SN"];
    info.spcPVer = [jsonObject objectForKey:@"SPCPVer"];
    info.fileVer = [jsonObject objectForKey:@"FileVer"];
    info.application = [jsonObject objectForKey:@"Application"];
    return info;
}

+ (NSArray <VTProDlc *>*)parseDlcList_WithFileData:(NSData *)data {
    NSMutableArray *arr= [NSMutableArray arrayWithCapacity:10];
    unsigned char *bytes = (unsigned char *)data.bytes;
    int dataLen = (int)data.length;
    for(int left = dataLen; left >= 17; left -= 17) {
        u_char *p  = bytes + dataLen - left;
        //Dailycheck
        VTProDlc *dlcItem = [[VTProDlc alloc] init];
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month = p[2];
        if(dtc.month > 12)
            dtc.month = 12;
        if(dtc.month < 1)
            dtc.month = 1;
        dtc.day = p[3];
        dtc.hour = p[4];
        dtc.minute = p[5];
        dtc.second = p[6];
        dlcItem.dtcDate = dtc;
        P2U16(&p[7], dlcItem.hrValue);
        if(p[9] == 0x00)
            dlcItem.hrResult = kPassKind_Pass;
        else if(p[9]==0x01)
            dlcItem.hrResult = kPassKind_Fail;
        else
            dlcItem.hrResult = kPassKind_Others;
        dlcItem.spo2Value = p[10];
        u_char pi = p[11];
        dlcItem.pIndex = pi/10.0;
        if(p[12] == 0x00)
            dlcItem.spo2Result = kPassKind_Pass;
        else if(p[12] == 0x01)
            dlcItem.spo2Result = kPassKind_Fail;
        else
            dlcItem.spo2Result = kPassKind_Others;
        
        dlcItem.bpFlag = p[13];
        if (dlcItem.bpFlag==0) {//Re,有符号
            if (p[14]>=128) {
                dlcItem.bpValue = -((~p[14]+1)&0x7F);
            }else{
                dlcItem.bpValue = p[14];
            }
        }else{//Abs,无符号
            dlcItem.bpValue = p[14];
        }
        
        u_char vioce = p[16];
        
        if(vioce == 0)
            dlcItem.haveVoice = NO;
        else
            dlcItem.haveVoice = YES;
        
        [arr addObject:dlcItem];

    }
    
    return arr;
}




+(NSArray <VTProEcg *>*)parseEcgList_WithFileData:(NSData *)data{
    NSMutableArray *arr= [NSMutableArray arrayWithCapacity:10];
    unsigned char *bytes = (unsigned char *)data.bytes;
    int dataLen = (int)data.length;
    for(int left = dataLen; left >= 10; left -= 10) {
        u_char *p  = bytes + dataLen - left;
        //ECG
        VTProEcg *ecgItem = [[VTProEcg alloc] init];
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month = p[2];
        if(dtc.month > 12)
            dtc.month = 12;
        if(dtc.month < 1)
            dtc.month = 1;
        dtc.day = p[3];
        dtc.hour = p[4];
        dtc.minute = p[5];
        dtc.second = p[6];
        ecgItem.dtcDate = dtc;
        u_char leadKind = p[7];
        if(leadKind == 0x01)
            ecgItem.enLeadKind = LeadKindHand;
        else if(leadKind == 0x02)
            ecgItem.enLeadKind = LeadKindChest;
        else if(leadKind == 0x03)
            ecgItem.enLeadKind = LeadKindWire;
        else if(leadKind == 0x04)
            ecgItem.enLeadKind = LeadKindWire12;
        u_char resultKind = p[8];
        if(resultKind == 0x00)
            ecgItem.enPassKind = kPassKind_Pass;
        else if(resultKind==0x01)
            ecgItem.enPassKind = kPassKind_Fail;
        else
            ecgItem.enPassKind = kPassKind_Others;
        u_char vioce = p[9];
        if(vioce == 0)
            ecgItem.haveVoice = NO;
        else
            ecgItem.haveVoice = YES;
        [arr addObject:ecgItem];
        
    }
    return arr;
}

+ (NSArray <VTProSpO2 *>*)parseSPO2List_WithFileData:(NSData *)data {
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    u_char *bytes = (u_char *)data.bytes;
    int dataLen = (int)data.length;
    for(int left = dataLen;left >= 12; left -= 12) {
        u_char *p = bytes + dataLen - left;
        VTProSpO2 *item = [[VTProSpO2 alloc] init];
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month =  p[2];
        if(dtc.month < 1)
            dtc.month = 1;
        if(dtc.month > 12)
            dtc.month = 12;
        dtc.day =  p[3];
        dtc.hour =  p[4];
        dtc.minute =  p[5];
        dtc.second =  p[6];
        item.dtcDate = dtc;
        u_char spo2 = p[8];
        if (spo2 > 100) {
            spo2 = 100;
        }else if (spo2 < 0){
            spo2 = 0;
        }
        item.spo2Value =  spo2;
        item.prValue = p[9];
        u_char pi = p[10];
        item.pIndex = pi/10.0;
        u_char resultKind = p[11];
        if(resultKind == 0x00)
            item.enPassKind = kPassKind_Pass;
        else if(resultKind == 0x01)
            item.enPassKind = kPassKind_Fail;
        else
            item.enPassKind = kPassKind_Others;
        [ret addObject:item];
    }
    return ret;
}

+ (NSArray <VTProBp *>*)parseNIBPList_WithFileData:(NSData *)data{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    u_char *bytes = (u_char *)data.bytes;
    int dataLen = (int)data.length;
    for(int left = dataLen;left >= 11; left -= 11)
    {
        u_char *p = bytes + dataLen - left;
        VTProBp *item = [[VTProBp alloc] init];
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month =  p[2];
        if(dtc.month < 1)
            dtc.month = 1;
        if(dtc.month > 12)
            dtc.month = 12;
        dtc.day =  p[3];
        dtc.hour =  p[4];
        dtc.minute =  p[5];
        dtc.second =  p[6];
        item.dtcDate = dtc;
        u_short data =  0;
        P2U16(&p[7], data);
        item.sysValue =  data;
        u_char result = p[9];
        item.diaValue = result;
        item.prValue = p[10];
        [ret addObject:item];
    }
    return ret;
}

+ (NSArray <VTProBg *>*)parseBloodSugerList_WithFileData:(NSData *)data {
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:10];
    u_char *bytes = (u_char *)data.bytes;
    int dataLen = (int)data.length;
    for (int left = dataLen; left >= 32; left -= 32) {
        VTProBg *item = [[VTProBg alloc] init];
        u_char *p = bytes + dataLen - left;
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month =  p[2];
        if(dtc.month < 1) { dtc.month = 1; }
        if(dtc.month > 12) { dtc.month = 12; }
        dtc.day = p[3];
        dtc.hour = p[4];
        dtc.minute = p[5];
        dtc.second = p[6];
        item.dtcDate = dtc;
        u_short data = 0;
        P2U16(&p[7], data);
        item.sugerValue = data*1.0/10.0;
        int k = 0;
        char noteChar[20+1] = {0x00};
        for (k = 0; ((char *)(p+12))[k] != '\0' && k < 20; k++) {
            noteChar[k] = ((char *)(p+12))[k];
        }
        noteChar[k] = '\0';
        item.note = [NSString stringWithUTF8String:noteChar];
        [arrM addObject:item];
    }
    return arrM;
}


+ (NSArray <VTProTm *>*)parseTempList_WithFileData:(NSData *)data{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    u_char *bytes = (u_char *)data.bytes;
    int dataLen = (int)data.length;
    for(int left = dataLen;left >= 11; left -= 11)
    {
        u_char *p = bytes + dataLen - left;
        VTProTm *item = [[VTProTm alloc] init];
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month =  p[2];
        if(dtc.month < 1)
            dtc.month = 1;
        if(dtc.month > 12)
            dtc.month = 12;
        dtc.day =  p[3];
        dtc.hour =  p[4];
        dtc.minute =  p[5];
        dtc.second =  p[6];
        item.dtcDate = dtc;
        item.measureMode = p[7];
        u_short data =  0;
        P2U16(&p[8], data);
        double value = data*1.0/10.0;
        item.tempValue =  value;
        u_char result = p[10];
        if(result == 0x00)
            item.enPassKind = kPassKind_Pass;
        else if(result == 0x01)
            item.enPassKind = kPassKind_Fail;
        else
            item.enPassKind = kPassKind_Others;
        [ret addObject:item];
    }
    return ret;
}


+ (NSArray <VTProSlm *>*)parseSLMList_WithFileData:(NSData *)data {

    NSMutableArray *arr= [NSMutableArray arrayWithCapacity:10];
    unsigned char *bytes = (unsigned char *)data.bytes;
    int dataLen = (int)data.length;
    for(int left = dataLen; left >= 18; left -= 18)
    {
        u_char *p  = bytes + dataLen - left;
        //Sleep monitor item
        VTProSlm *slmItem = [[VTProSlm alloc] init];
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month = p[2];
        if(dtc.month > 12)
            dtc.month = 12;
        if(dtc.month < 1)
            dtc.month = 1;
        dtc.day = p[3];
        dtc.hour = p[4];
        dtc.minute = p[5];
        dtc.second = p[6];
        slmItem.dtcDate = dtc;
        P2U32(&p[7], slmItem.totalTime);
        P2U16(&p[11], slmItem.lowOxTime);
        P2U16(&p[13], slmItem.lowOxNumber);
        slmItem.lowestOx = p[15];
        slmItem.averageOx = p[16];
        if(p[17] == 0x00)
            slmItem.enPassKind = kPassKind_Pass;
        else if(p[17] == 0x01)
            slmItem.enPassKind = kPassKind_Fail;
        else
            slmItem.enPassKind = kPassKind_Others;
        [arr addObject:slmItem];
    }
    return arr;
}

+ (NSArray <VTProPed *>*)parsePedList_WithFileData:(NSData *)data {
#define PED_DATA2VALUE100(data) (((double)data)/100.0)
#define PED_DATA2VALUE10(data) (((double)data)/10.0)

    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    u_char *bytes = (u_char *)data.bytes;
    int dataLen = (int)data.length;
    
    for(int left = dataLen;left >= 29; left -= 29)
    {
        u_char *p = bytes + dataLen - left;
        VTProPed *item = [[VTProPed alloc] init];
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month =  p[2];
        if(dtc.month < 1)
            dtc.month = 1;
        if(dtc.month > 12)
            dtc.month = 12;
        dtc.day =  p[3];
        dtc.hour =  p[4];
        dtc.minute =  p[5];
        dtc.second =  p[6];
        item.dtcDate = dtc;
        P2U32(&p[7], item.steps);
        int length = 0;
        P2U32(&p[11], length);
        item.distance = PED_DATA2VALUE100(length);
        int speed = 0;
        P2U32(&p[15], speed);
        item.speed = PED_DATA2VALUE10(speed);
        int calorie = 0;
        P2U32(&p[19], calorie);
        item.calorie = PED_DATA2VALUE100(calorie);
        int fat = 0;
        P2U16(&p[23], fat);
        item.fat = PED_DATA2VALUE100(fat);
        P2U32(&p[25], item.totalTime);
        [ret addObject:item];
    }
    return ret;
}




+ (VTProSlmDetail *)parseSLMData_WithFileData:(NSData *)data {
    VTProSlmDetail *innerData = [[VTProSlmDetail alloc] init] ;
    unsigned char *bytes = (unsigned char*)data.bytes;
    int dataLen = (int)data.length;
    if (dataLen%2 != 0) {
        NSLog(@"Sleep data is incomplete!");
    } else {
        for(int left = dataLen; left >= 2; left -= 2){
            u_char *p = bytes + dataLen - left;
            u_char oxValue = p[0];
            [innerData.arrOxValue addObject:@(oxValue)];
            u_char pluseVal = p[1];
            [innerData.arrPrValue addObject:@(pluseVal)];
        }
    }
    return innerData;
}


+ (VTProEcgDetail *)parseEcg_WithFileData:(NSData *)data
{
#define ECG_DATA2MV(data)  (4033.0*data/32767.0/12.0/8.0)
#define  ECG_NORMAL_MIN_VAL (-5.0f)
#define  ECG_NORMAL_MAX_VAL (5.0f)
#define ECG_CONTENT_SAMPLE_REATE 500 //采样率
    int ECG_HEADER_LEN = 21;
    if (!data) {
        return nil;
    }
    NSLog(@"start parse ECG data");
    VTProEcgDetail *innerData = [[VTProEcgDetail alloc]  init];
    u_char *bytes  = (unsigned char *)data.bytes;
    u_char *p = bytes;
    u_short hrLength;//心率字节数
    P2U16(&p[0], hrLength);
    innerData.timeLength = hrLength/2;//每个hr两个byte
    
    u_int ECG_CONTENT_NUM = (((innerData.timeLength * ECG_CONTENT_SAMPLE_REATE)/2)+1);
    u_int totalWantBytes = ECG_CONTENT_NUM*2 + hrLength + ECG_HEADER_LEN;
    if(data.length < totalWantBytes)
    {
        return nil;
    }
    
    u_int waveLength;//心电波形字节数
    P2U32(&p[2], waveLength);
    P2U16(&p[6], innerData.hrValue);
    P2U16(&p[8], innerData.stValue);
    
    
    P2U16(&p[10], innerData.qrsValue);
    P2U16(&p[12], innerData.pvcsValue);
    P2U16(&p[14], innerData.qtcValue);
    
    u_char result = p[16];
    innerData.ecgResult = [NSString stringWithFormat:@"%d", result];
    
    //测量模式和滤波模式
    if(p[17] == 0x01)
        innerData.enLeadKind = LeadKindHand;
    else if(p[17] == 0x02)
        innerData.enLeadKind = LeadKindChest;
    else if(p[17] == 0x03)
        innerData.enLeadKind = LeadKindWire;
    else if(p[17] == 0x04)
        innerData.enLeadKind = LeadKindWire12;
    
    if (p[18]==0x00) {
        innerData.enFilterKind = kFilterKind_Normal;
    }else if (p[18]==0x01){
        innerData.enFilterKind = kFilterKind_Wide;
    }
    if (ECG_HEADER_LEN == 21) {
        P2U16(&p[19], innerData.qtValue);
        innerData.isQT = YES;
    }
    else
        innerData.isQT = NO;
    
    bytes += ECG_HEADER_LEN;
    p = bytes;//seek头大小
    
    for(int i = 0 ; i < innerData.timeLength*2;i++)
    {
        u_short hr = 0;
        P2U16(&p[i*2],hr);
        NSNumber *num = [NSNumber numberWithShort:hr];
        [innerData.arrEcgHeartRate addObject:num];
    }
    
    
    //解析波形数据
    bytes += hrLength;//seek心率数据长度
    
    for(int i=0; i < ECG_CONTENT_NUM-1; ++i)
    {
        void (^adjustEcgValue)(double *) = ^(double *pVal)
        {
            if(*pVal > ECG_NORMAL_MAX_VAL)
                *pVal = ECG_NORMAL_MAX_VAL;
            if( *pVal < ECG_NORMAL_MIN_VAL)
                *pVal = ECG_NORMAL_MIN_VAL;
        };
        
        
        
        double  ecgVal_i=0,ecgVal_i_1=0,ecgVal_Insert=0;
        //取得第i个值
        p = bytes + (i * 2);
        short ecgData = ((p[0])|(p[1]<<8)) & 0xffff;
        
        
        
        //        <36ff3cff 43ff4dff>
        ecgVal_i = ECG_DATA2MV(ecgData);
        adjustEcgValue(&ecgVal_i);
        //取得第i+1个值
        p = bytes + ((i+1) * 2);
        
        ecgData = ((p[0])|(p[1]<<8)) & 0xffff;
        //P2U16(p,ecgData );
        ecgVal_i_1 = ECG_DATA2MV(ecgData);
        adjustEcgValue(&ecgVal_i_1);
        //计算插入值
        ecgVal_Insert = (ecgVal_i + ecgVal_i_1)/2.0;
        adjustEcgValue(&ecgVal_Insert);
        
        NSNumber *ecgNum = nil;
        if (i == 0) {
            ecgNum = [NSNumber numberWithDouble:ecgVal_i];
            [innerData.arrEcgContent addObject:ecgNum];
        }
        
        ecgNum = [NSNumber numberWithDouble:ecgVal_Insert];
        [innerData.arrEcgContent addObject:ecgNum];
        
        if(i != (ECG_CONTENT_NUM-1-1))
        {
            ecgNum = [NSNumber numberWithDouble:ecgVal_i_1];
            [innerData.arrEcgContent addObject:ecgNum];
        }
    }
    return innerData;
}

#define originalValueTo_mV(a)   ((a*4033.0)/(32767.0*12))*1.05    //把原始数据转换成mV
+ (VTProMiniObject *)parseMiniDataWithBuff:(NSData *)buff andType:(u_char)type{
    VTProMiniObject *pkg = [[VTProMiniObject alloc] init];
    u_char *p = (u_char *)buff.bytes;
    if (type == 0x01 || type == 0x05) {
        u_char *p_ECG_Dis = &p[4];
        for (int i = 0; i < 10; i += 2) {
            short data = (p_ECG_Dis[i] & 0xFF) + ((p_ECG_Dis[i+1] & 0xFF) << 8);    //原始数据
            float value = originalValueTo_mV(data);   //转换成mV
            [pkg.ecgArray addObject:@(value)];
        }
        u_short HR = 0;
        u_short QRS = 0;
        u_short ST = 0;
        u_short PVC = 0;
        P2U16(&p[14], HR);
        P2U16(&p[16], QRS);
        P2U16(&p[18], ST);
        P2U16(&p[20], PVC);
        pkg.hrValue = HR;
        pkg.qrsValue = QRS;
        pkg.stValue = ST;
        pkg.pvcValue = PVC;
        
        if (type == 0x01) {   // 只有心电
            u_char other = p[24];
            if (other == 0xF1) {
                pkg.battery = p[25];
            }
            if (p[26] == 0xF3) {
                pkg.pkgNum = p[28];
            }
        } else {  //既有心电又有血氧
            u_char *p_OXI_Dis = &p[25];
            for (int i = 0; i < 10; i += 2) {
                int data = p_OXI_Dis[i] & 0xFF + ((p_OXI_Dis[i+1]&0xFF) << 8);
//                data = data * 3 / 5 + 110;   //新老数据转换
                [pkg.spo2Array addObject:@(data)];
            }
            pkg.spo2Value = p[37];
            u_short oxi_pr = 0;
            P2U16(&p[35], oxi_pr);
            pkg.spo2PRValue = oxi_pr;
            pkg.spo2PIValue = p[38];
            pkg.ecgRIdentifier = p[22];
            pkg.spo2Identifier = p[39];
            if (p[41] == 0xF1) {
                pkg.battery = p[42];
            }
            if (p[43] == 0xF3) {
                pkg.pkgNum = p[45];
            }
        }
    } else if (type == 0x02) {    //只有血氧
        u_char *p_OXI_Dis = &p[4];
        for (int i = 0; i < 10; i += 2) {
            int data = p_OXI_Dis[i] & 0xFF + ((p_OXI_Dis[i+1]&0xFF) << 8);
            [pkg.spo2Array addObject:@(data)];
        }
        pkg.spo2Value = p[16];
        u_short oxi_pr = 0;
        P2U16(&p[14], oxi_pr);
        pkg.spo2PRValue = oxi_pr;
        pkg.spo2PIValue = p[17];
        if (p[20] == 0xF1) {
            pkg.battery = p[21];
        }
        if (p[22] == 0xF3) {
            pkg.pkgNum = p[24];
        }
    }

    return pkg;
}


+ (NSString *)parseECG_innerData_ecgResultDescribWith:(NSString *)ecgResultDescrib
{
    NSArray *ecgResults = [ECG_RESULT_ARRAYS copy];
    u_char result = [ecgResultDescrib intValue];
    NSString *str = @"";
    if(result==0xFF)
        str = ecgResults[7];
    else if(result==0)
        str = ecgResults[0];
    else{
        for (int i=0; i<9; i++) {
            //第一条前面不加回车
            NSString *tempStr = (result&(1<<i)) == 0 ? @"" : ( str.length<1 ? ecgResults[i+1] : [NSString stringWithFormat:@"\r\n%@",ecgResults[i+1]]);
            str = [str stringByAppendingString:tempStr];
        }
    }
    return str;
}


@end
