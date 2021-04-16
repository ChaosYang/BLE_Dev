//
//  ViaBLEStruct.h
//  DuoEK
//
//  Created by Viatom on 2019/4/10.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#ifndef ViaBLEStruct_h
#define ViaBLEStruct_h

#pragma pack (1)
#pragma mark --- Request Struct
#pragma mark --- common
typedef struct{
    u_char device_type;
    u_char fw_version[3];
}StartFirmwareUpdate;

typedef struct{
    unsigned addr_offset;
    u_char *fw_data;
}FirmwareUpdate;

typedef struct{
    u_char device_type; //设备类型,chekme产品ID高位
    u_char lang_version; //语言包版本
    u_int  size; //大小
}StartLanguageUpdate;

typedef struct{
    unsigned addr_offset; //地址偏移
    u_char *lang_data; //固件数据
}LanguageUpdate;

typedef struct {
    u_char len; //SN长度(小于18)  e.g. 10
    u_char serial_num[18]; //SN号
}SN;

typedef struct{
    u_char burn_flag; //烧录标记    e.g. bit0:SN  bit1:硬件版本  bit2:Branch Code
    u_char hw_version; //硬件版本    ‘A’-‘Z’
    u_char branch_code[8]; //Branch编码
    SN sn;
}FactoryConfig;

typedef struct{
    u_short year;
    u_char month;
    u_char day;
    u_char hour;
    u_char minute;
    u_char second;
}DeviceTime;

typedef struct{
    u_char file_name[16]; //支持15个字符长度文件名
    u_int file_offset; //文件偏移,用于断点续传
 }FileReadStart;

typedef struct{
    unsigned addr_offset;   
}FileRead;

typedef struct{
    unsigned addr_offset;
}FileWrite;

#pragma mark --- ECG

typedef struct{
    u_char rate;            //数据发送频率（Hz）
}SendRate;

/******ER1******/
typedef struct{
    u_char vibeSw;  // 配置开关  
    u_char hrTarget1;     //  下限
    u_char hrTarget2;  // 上限

}ConfiguartionER1;

/******ER2******/
typedef struct{
    u_char ecgSwitch;  // 配置开关  bit0: 心跳声
    u_char vector;     // 加速度值
    u_char motion_count;  // 加速度检测次数
    u_short motion_windows;  // 加速度检测窗口
}Configuartion;


typedef struct{
    u_short sampling_num;        //采样点数
    short wave_data[300];        //原始数据
}RealTimeWaveform;

typedef struct{
    u_short hr;                    //当前主机实时心率 bpm
    u_char sys_flag;                // bit0:R波标记(主机缓存有R波标记200ms)  bit1-2:电池状态(0:正常使用 1:充电中 2:充满 3:低电量)  bit3:导联状态(0:OFF  1:ON) bit7:测量状态 (0:空闲 1:测量中)
    u_char percent;                 //电池状态 e.g.    100:100%
    u_int record_time;            //已记录时长    单位:second
    u_char run_status;             //  运行状态
    u_char reserved[11];            //预留
}DeviceRunParameters;

typedef struct{
    u_char rRemark; // bit0:R波标记(主机缓存有R波标记200ms)
    u_char signalWeak; // 信号差标记  主机算法重新初始化
    u_char signalPoor; // 信号弱标记
    u_char batteryStatus; // bit 6-7:电池状态(0:正常使用 1:充电中 2:充满 3:低电量)
}flagBit;

typedef struct{
    u_char currentStatus;  // 本次运行状态  0x0 空闲待机(导联脱落) 0x1 测量准备（主机丢弃前段波形阶段）  0x2记录中 0x3分析存储中 0x4 已存储成功(满时间测量结束后一直停留此状态  直至回到空闲状态) 0x5 少于30s  0x6 
    u_char latestStatus;    // 上一次运行状态  同 上
}RunStatusBit;


typedef struct{
    DeviceRunParameters run_para;
    RealTimeWaveform waveform;        //同0x01指令RealTimeWaveform 结构体
}RealTimeData;
/**************/

#pragma mark --- Receive Struct

typedef struct{
    u_char hw_version; //硬件版本    e.g. ‘A’ : A版
    u_int  fw_version; //固件版本    e.g. 0x010100 : V1.1.0
    u_int  bl_version; //引导版本    e.g. 0x010100 : V1.1.0
    u_char branch_code[8]; //Branch编码 e.g. “40020000” : Ezcardio Plus
    u_char reserved0[3]; //预留
    u_short device_type; //设备类型    e.g. 0x8611: 血压计
    u_short protocol_version; //协议版本    e.g.0x0100:V1.0
    u_char cur_time[7]; //时间    e.g.0xE1070301090000:2017-03-01 09:00:00
    u_short protocol_data_max_len; //通信协议支持的最大数据长度
    u_char reserved1[4]; //预留
    SN sn;
    u_char reserved2[1]; //预留
}DeviceInfo;

typedef struct{
    u_char state; //电池状态 e.g.   0:正常使用 1:充电中 2:充满 3:低电量
    u_char percent; //电池状态 e.g.    电池电量百分比
    u_short voltage; //电池电压(mV)    e.g.    3950 : 3.95V
 }BatteryInfo;

typedef struct{
    short temp; //温度*100    e.g. 2410:24.1摄氏度
 }Temperature;

typedef struct{
    u_char str[16];
}FileName;

typedef struct{
    u_char file_num;
    FileName fileName[255];
}FileList;

typedef struct{
    u_int file_size; //文件大小
}FileStartReadReturn;

typedef struct{
    u_char *file_data; //文件内容
}FileData;

typedef struct{
    u_char file_name[16]; //支持14个字符长度文件名
    u_int file_offset; //文件偏移,支持续写改写
    u_int file_size; //文件大小
}FileWriteStartReturn;

typedef struct{
    u_short user_num; //用户数量
    u_char *user_ID[30]; //用户唯一ID
}UserList;

#pragma mark --- ECG

typedef struct{
    u_char file_version;        //文件版本 e.g.  0x01 :  V1
    u_char reserved[9];        //预留
}FileHead_t;

/************* ER1 ****************/

typedef struct{
    u_char hr;
    u_char motion;
    u_char vibration;
}PointData_t;

typedef struct{
    u_int recoring_time;
    u_char reserved[12];
    u_int magic;
}FileTail_t_V;


/************* ER2 ****************/

typedef struct{
    u_int recording_time;        //测量时间 e.g. 3600 :  3600s
    u_short data_crc;        //文件头部+原始波形和校验
    u_char reserved[10];                //预留
    u_int magic;            //文件标志 固定值为0xA55A0438
}FileTail_t;

typedef struct{
    u_char file_version;        //文件版本 e.g.  0x01 :  V1
    u_char reserved0[9];        // 预留
    u_int recording_time;        //同波形文件recording_time
    u_char reserved1[66];        //预留
}AnalysisTotalResult;

typedef struct{
    u_int  result;            //诊断结果，见诊断结果表[诊断结果表
    u_short hr;                //心率 单位：bpm
    u_short qrs;                //QRS 单位：ms
    u_short pvcs;            //PVC个数
    u_short qtc;                //QTc 单位：ms
    u_char reserved[20];    //预留
}AnalysisResult;



#pragma pack()

#endif /* ViaBLEStruct_h */
