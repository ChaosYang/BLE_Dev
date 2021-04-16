//
//  ViaBLEMarco.h
//  DuoEK
//
//  Created by Viatom on 2019/4/9.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#ifndef ViaBLEMarco_h
#define ViaBLEMarco_h

#define ViaBLE_Header 0xA5



/*
 Pkg.Type 表
 */
//#define ViaBLE_Type_Request 0x00
//#define ViaBLE_Type_Normal 0x01
//#define ViaBLE_Type_NotFound 0xE0
//#define ViaBLE_Type_OpenFailed 0xE1
//#define ViaBLE_Type_ReadFailed 0xE2
//#define ViaBLE_Type_WriteFailed 0xE3
//#define ViaBLE_Type_FormatError 0xFC
//#define ViaBLE_Type_FormatUnsupport 0xFD
//#define ViaBLE_Type_CommonError 0xFF
//#define ViaBLE_Type_DeviceOccupied 0xFB
typedef enum : u_char{
    VT_Type_Request = 0x00,
    VT_Type_Normal = 0x01,
    VT_Type_NotFound = 0xE0,
    VT_Type_OpenFailed = 0xE1,
    VT_Type_ReadFailed = 0xE2,
    VT_Type_WriteFailed = 0xE3,
    VT_Type_ReadFileListFailed = 0xF1,
    VT_Type_FormatError = 0xFC,
    VT_Type_FormatUnsupport = 0xFD,
    VT_Type_CommonError = 0xFF,
    VT_Type_DeviceOccupied = 0xFF,
    VT_Type_LosePKG = 0xCC, // app自定义
} VTType;

/*
 Universal command(0xE0-0xFF)
 */
//#define ViaBLE_CMD_Echo 0xE0  // 回显
//#define ViaBLE_CMD_GetDeviceInfo 0xE1  //获取设备信息
//#define ViaBLE_CMD_Reset 0xE2   // 复位
//#define ViaBLE_CMD_Restore 0xE3  //恢复出厂
//#define ViaBLE_CMD_GetBattery 0xE4  // 获取电池状态
//#define ViaBLE_CMD_UpdateFirmware 0xE5 // 开始固件升级
//#define ViaBLE_CMD_UpdateFirmwareData 0xE6  // 发送固件升级数据
//#define ViaBLE_CMD_UpdateFirmwareEnd 0xE7   //固件升级结束
//#define ViaBLE_CMD_UpdateLanguage 0xE8  // 开始升级语言包
//#define ViaBLE_CMD_UpdateLanguageIng 0xE8  // 升级语言包
//#define ViaBLE_CMD_UpdateLanguageEnd 0xE9  // 结束升级语言包
//#define ViaBLE_CMD_RestoreInfo 0xEA  // 烧录出厂信息
//#define ViaBLE_CMD_Encrypt 0xEB  // 加密Flash
//#define ViaBLE_CMD_SyncTime 0xEC  // 同步时间
//#define ViaBLE_CMD_GetDeviceTemp 0xED  // 获取设备温度
//#define ViaBLE_CMD_ProductReset 0xEE   // 恢复生产出厂
//#define ViaBLE_CMD_GetFileList 0xF1  // 获取文件列表
//#define ViaBLE_CMD_StartRead 0xF2    //读文件开始
//#define ViaBLE_CMD_ReadFile 0xF3   //读文件数据
//#define ViaBLE_CMD_EndRead 0xF4  //读文件结束
//#define ViaBLE_CMD_StartWrite 0xF5  //
//#define ViaBLE_CMD_WriteData 0xF6   // 写入数据
//#define ViaBLE_CMD_EndWrite 0xF7
//#define ViaBLE_CMD_DeleteFile 0xF8  //删除文件
//#define ViaBLE_CMD_GetUserList 0xF9 // 获取用户列表
//#define ViaBLE_CMD_EnterDFU 0xFA // 进入DFU升级模式
typedef enum : u_char{
    VT_CMD_Echo = 0xE0,  // 回显
    VT_CMD_GetDeviceInfo = 0xE1,  //获取设备信息
    VT_CMD_Reset = 0xE2,   // 复位
    VT_CMD_Restore = 0xE3,  //恢复出厂
    VT_CMD_GetBattery = 0xE4,  // 获取电池状态
    VT_CMD_UpdateFirmware = 0xE5, // 开始固件升级
    VT_CMD_UpdateFirmwareData = 0xE6,  // 发送固件升级数据
    VT_CMD_UpdateFirmwareEnd = 0xE7,   //固件升级结束
    VT_CMD_UpdateLanguage = 0xE8,  // 开始升级语言包
    VT_CMD_UpdateLanguageIng = 0xE8,  // 升级语言包
    VT_CMD_UpdateLanguageEnd = 0xE9,  // 结束升级语言包
    VT_CMD_RestoreInfo = 0xEA,  // 烧录出厂信息
    VT_CMD_Encrypt = 0xEB,  // 加密Flash
    VT_CMD_SyncTime = 0xEC,  // 同步时间
    VT_CMD_GetDeviceTemp = 0xED,  // 获取设备温度
    VT_CMD_ProductReset = 0xEE,   // 恢复生产出厂
    VT_CMD_GetFileList = 0xF1,  // 获取文件列表
    VT_CMD_StartRead = 0xF2,    //读文件开始
    VT_CMD_ReadFile = 0xF3,   //读文件数据
    VT_CMD_EndRead = 0xF4,  //读文件结束
    VT_CMD_StartWrite = 0xF5,  //
    VT_CMD_WriteData = 0xF6,  // 写入数据
    VT_CMD_EndWrite = 0xF7,
    VT_CMD_DeleteFile = 0xF8,  //删除文件
    VT_CMD_GetUserList = 0xF9, // 获取用户列表
    VT_CMD_EnterDFU = 0xFA, // 进入DFU升级模式
} VTCmd;

/*
 Private command(0x00-0xDF)
 */

/***************血压计*******************/
//#define ViaBLE_AirBP_GetConfig 0x00  //获取配置参数
//#define ViaBLE_AirBP_Zero 0x01  //校零
//#define ViaBLE_AirBP_Slope 0x02 //校准
//#define ViaBLE_AirBP_StopPressure 0x03 // 设置停止打气压力值
//#define ViaBLE_AirBP_StartMeasure 0x04 // 启动测量
//#define ViaBLE_AirBP_StopMeasure 0x05  // 停止测量
//#define ViaBLE_AirBP_RunStatus 0x06   //当前运行状态 (提示信息,当算法运行状态切换时发送)
//#define ViaBLE_AirBP_MeasureResults 0x07  //测量结果(测量结束时主机主动发送)
//#define ViaBLE_AirBP_MeasureWork 0x08   // 工程启动测量(工程模式)
typedef enum :u_char{
    VTAirBP_CMD_GetConfig = 0x00,  //获取配置参数
    VTAirBP_CMD_Zero = 0x01,  //校零
    VTAirBP_CMD_Slope = 0x02, //校准
    VTAirBP_CMD_StopPressure = 0x03, // 设置停止打气压力值
    VTAirBP_CMD_StartMeasure = 0x04, // 启动测量
    VTAirBP_CMD_StopMeasure = 0x05,  // 停止测量
    VTAirBP_CMD_RunStatus = 0x06,   //当前运行状态 (提示信息,当算法运行状态切换时发送)
    VTAirBP_CMD_MeasureResults = 0x07,  //测量结果(测量结束时主机主动发送)
    VTAirBP_CMD_MeasureWork = 0x08,   // 工程启动测量(工程模式)
}VTAirBPCmd;

/***************心电产品*******************/
//#define ViaBLE_ECG_GetConfig 0x00
//#define ViaBLE_ECG_GetRealWave 0x01  //获取实时波形
//#define ViaBLE_ECG_GetRunStatus 0x02  // 获取设备运行状态
//#define ViaBLE_ECG_GetRealData 0x03  // 获取实时数据  包含实时波形
//#define ViaBLE_ECG_SetConfig 0x04   // 设置参数
typedef enum :u_char{
     VTECG_Cmd_GetConfig = 0x00,
     VTECG_Cmd_GetRealWave = 0x01,  //获取实时波形
     VTECG_Cmd_GetRunStatus = 0x02,  // 获取设备运行状态
     VTECG_Cmd_GetRealData = 0x03,  // 获取实时数据  包含实时波形
     VTECG_Cmd_SetConfig = 0x04,   // 设置参数
}VTECGCmd;

/***************Ezcardio心电帖*******************/
//#define ViaBLE_Ezcardio_SetWiFiConfig 0x03  //设置WiFi底座配置
typedef enum :u_char{
    VTEzcardio_CMD_SetWiFiConfig = 0x03,  //设置WiFi底座配置
}VTEzcardioCmd;

/***************BP2/BP2A*******************/
typedef enum :u_char{
    VTBP2_CMD_GetConfig = 0x00,   //获取配置参数
    VTBP2_CMD__Zero = 0x01,   //校零
    VTBP2_CMD__Slope = 0x02,   //校准(校斜率,必须先校零)
    VTBP2_CMD_SetConfig = 0x0B,
    VTBP2_CMD_GetRealPressure = 0x05,   //获取实时压
    VTBP2_CMD_GetRealStatus = 0x06,   //获取实时运行状态
    VTBP2_CMD_GetRealWave = 0x07,   //获取实时波形
    VTBP2_CMD_GetRealData = 0x08,  //获取实时数据
    VTBP2_CMD_ChangeRunStatus = 0x09,   //切换运行状态
    VTBP2_CMD_StartMeasure = 0x0A,   //启动血压测试
}VTBP2Cmd;
/***************蓝牙Dongle*******************/


#endif /* ViaBLEMarco_h */
