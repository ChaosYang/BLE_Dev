//
//  ViaBLE.h
//  DuoEK
//
//  Created by Viatom on 2019/4/9.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViaHeader.h"


NS_ASSUME_NONNULL_BEGIN


@interface ViaBLE : NSObject

#pragma mark --- Request information from via's device.

/**
 cmd ---    echo
 @param echoData --- data
 */
+ (void)via_echoWithData:(NSData *)echoData ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Get device's information from via's device.
 */
+ (void)via_getDeviceInfoAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Device Reset
 */
+ (void)via_deviceResetAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Restore factory
 */
+ (void)via_restoreFactoryAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Product reset
 */
+ (void)via_productReset:(AckDataCmd)handle;

/**
 cmd ---    Get battery information from via's device
 */
+ (void)via_getBatteryAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Prepare to update via's device firmware
 @param firmware --- struct StartFirmwareUpdate
 */
+ (void)via_startFirmwareUpdate:(StartFirmwareUpdate)firmware ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Updating via's device firmware
 @param firmware --- struct FirmwareUpdate
 */
+ (void)via_firmwareUpdate:(FirmwareUpdate)firmware ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    End updating via's device firmware
 */
+ (void)via_endFirmwareUpdateAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Prepare to update via's device language
 @param language --- struct StartLanguageUpdate
 */
+ (void)via_startLanguageUpdate:(StartLanguageUpdate)language ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Updating via's device language
 @param language --- struct LanguageUpdate
 */
+ (void)via_languageUpdate:(LanguageUpdate)language ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    End updating via's device language
 */
+ (void)via_endLanguageUpdateAckDataCmd:(AckDataCmd)handle;


/**
 cmd ---    Set factory configuration of via's device.
 @param config --- struct FactoryConfig
 */
+ (void)via_factoryConfig:(FactoryConfig)config ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Encrypt flash of via's device.
 */
+ (void)via_encryptAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Set time via's device.
 @param time --- struct DeviceTime
 */
+ (void)via_syncDeviceTime:(DeviceTime)time ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Get temperature from via's device.
 */
+ (void)via_getDeviceTempAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Get fileList from via's device.
 */
+ (void)via_getFileListAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Prepare to download file from via's device.
 @param read --- struct FileReadStart
 */
+ (void)via_startReadFile:(FileReadStart)read ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Download file from via's device.
 @param read --- struct FileRead
 */
+ (void)via_readFile:(FileRead)read ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    End download.
 */
+ (void)via_endReadFileAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Prepare to write data to via's device.
 */
+ (void)via_startWriteFileAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    writing data to via's device.
 @param write --- struct FileWrite
 */
+ (void)via_writeFile:(FileWrite)write ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    End writing.
 */
+ (void)via_endWriteFileAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Delete file by file's name from via's device.
 @param fileName --- file's name
 */
+ (void)via_deleteFileByName:(NSString *)fileName ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Get user's list from via's device.
 */
+ (void)via_getUserListAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Bring via's device into dfu model.
 */
+ (void)via_enterDfuModelAckDataCmd:(AckDataCmd)handle;


/**
 cmd ---    Get real-time wave
 @param rate Hz
 */
+ (void)via_getRealTimeWaveform:(SendRate)rate ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Get real-time data contains real-time wave
 @param rate Hz
 */
+ (void)via_getRealData:(SendRate)rate ackDataCmd:(AckDataCmd)handle;


+ (void)via_setER1Config:(ConfiguartionER1)config ackDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Get er2's configuartion
 */
+ (void)via_getER2ConfigAckDataCmd:(AckDataCmd)handle;

/**
 cmd ---    Set er2's configuartion
 */
+ (void)via_setER2Config:(Configuartion)config ackDataCmd:(AckDataCmd)handle;




@end


NS_ASSUME_NONNULL_END
