//
//  ViewController.m
//  TestSDK
//
//  Created by viatom on 2020/3/24.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "VTBLEManager.h"



@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate, VTBLEManagerDelegate>

@property (nonatomic, strong) CBCentralManager *c1;
@property (nonatomic, strong) CBCentralManager *c2;

@property (nonatomic, strong) CBPeripheral *sd1;
@property (nonatomic, strong) CBPeripheral *sd2;

@property (nonatomic, strong) CBCharacteristic *txCharacteristic1;
@property (nonatomic, strong) CBCharacteristic *txCharacteristic2;

@property (nonatomic, strong) CBCharacteristic *rxCharacteristic1;
@property (nonatomic, strong) CBCharacteristic *rxCharacteristic2;

@property (weak, nonatomic) IBOutlet UILabel *responseLab1;
@property (weak, nonatomic) IBOutlet UILabel *responesLab2;
@property (weak, nonatomic) IBOutlet UIButton *requestBtn;

@property (nonatomic, strong) NSMutableArray *deviceArray1;
@property (nonatomic, strong) NSMutableArray *deviceArray2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    dispatch_queue_t mySerialQueue = dispatch_queue_create("com.gcd.queueCreate.mySerialQueue", DISPATCH_QUEUE_CONCURRENT);
//    _c1 = [[CBCentralManager alloc] initWithDelegate:self queue:mySerialQueue];
//    _c2 = [[CBCentralManager alloc] initWithDelegate:self queue:mySerialQueue];
    [VTBLEManager manager].delegate = self;
    [[VTBLEManager manager] scanWithNumber:1];
    _deviceArray1 = [NSMutableArray array];
    _deviceArray2 = [NSMutableArray array];
    _requestBtn.backgroundColor = [UIColor lightGrayColor];
    _requestBtn.userInteractionEnabled =NO;
}

- (IBAction)requestData:(id)sender {
//    [self readDataWithPeripheral:_sd1 andCharacteristic:_txCharacteristic1];
//    [self readDataWithPeripheral:_sd2 andCharacteristic:_txCharacteristic2];
    for (VTBLEHelper *h in [VTBLEManager manager].managerList) {
        [[VTBLEManager manager] requestDataWithVTObj:h];
    }
    _requestBtn.backgroundColor = [UIColor lightGrayColor];
    _requestBtn.userInteractionEnabled = NO;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self->_requestBtn.userInteractionEnabled = YES;
//    });
}

#pragma mark -- VTBLEManager
- (void)bleManagerRealData:(BOOL)isSuccess withDevice:(VTBLEDevice *)device withHelper:(VTRealObject *)obj{
    NSString *str = [NSString stringWithFormat:@"血氧:%hhu 心率:%hu",obj.spo2,obj.hr];
    if ([device.rawPeripheral.name isEqualToString:deviceName1]) {
        self.responseLab1.text = str;
    }else if ([device.rawPeripheral.name isEqualToString:deviceName2]){
        self.responesLab2.text = str;

    }
    
}

- (void)updateStateWithCentral:(CBCentralManager * _Nonnull)central {
    
}

- (void)findDevice:(VTBLEDevice * _Nonnull)device withCentral:(CBCentralManager * _Nonnull)central {
//    if (!_c1) _c1 = central;
//    if (![central isEqual:_c1] && !_c2) _c2 = central;
//    if ([central isEqual:_c1]) {
        if ([device.rawPeripheral.name isEqualToString:deviceName1]) {
            if (_c1) {
                return;
            }
            _c1 = central;
            [[VTBLEManager manager] connectDevice:device withCentral:central];
//            [[VTBLEManager manager] stopScan:central];
        }
//    }else if ([central isEqual:_c2]) {
        if ([device.rawPeripheral.name isEqualToString:deviceName2]) {
            if (_c2) {
                return;
            }
            _c2 = central;
            [[VTBLEManager manager] connectDevice:device withCentral:central];
//            [[VTBLEManager manager] stopScan:central];
        }
        
//    }
    
}
 
- (void)didConnectDevice:(VTBLEHelper * _Nonnull)obj {
    DLog(@"%@连接成功", obj.device.rawPeripheral.name);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([obj.device.rawPeripheral.name isEqualToString:deviceName1]) {
            self.responseLab1.text = [NSString stringWithFormat:@"%@连接成功",deviceName1];
        }else if ([obj.device.rawPeripheral.name isEqualToString:deviceName2]){
            self.responesLab2.text = [NSString stringWithFormat:@"%@连接成功",deviceName2];
        }
        self.requestBtn.backgroundColor = [UIColor greenColor];
        self.requestBtn.userInteractionEnabled = YES;
    });
    DLog(@"success");
    //central
}

- (void)didFailedToConnectDevice:(VTBLEHelper * _Nonnull)obj {
    
}

- (void)didDisconnectDevice:(VTBLEHelper * _Nonnull)obj {
    
}

- (void)didCancelConnectDevice:(VTBLEHelper * _Nonnull)obj {
    
}

- (void)didCompletedConfig:(BOOL)success{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (success) {
//            self->_requestBtn.userInteractionEnabled = YES;
//            DLog(@"success");
//        }else{
//            self->_requestBtn.userInteractionEnabled = NO;
//            DLog(@"error");
//        }
//    });
}


#pragma mark ----

- (void)readDataWithPeripheral:(CBPeripheral *)p andCharacteristic:(CBCharacteristic *)c{
    u_char buf[8];
    memset(buf, 0, 8);
    buf[0] = 0xAA;
    buf[1] = 0x17;
    buf[2] = ~0x17;
//    buf[7] = [self CalCRC8:buf bufSize:7];
    NSData *data = [NSData dataWithBytes:buf length:8];
    if (p.state == CBPeripheralStateConnected) {
        [p writeValue:data forCharacteristic:c type:CBCharacteristicWriteWithoutResponse];
    }
}


- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    if (central.state == 5) {
        if ([central isEqual:_c1]) {
            [_c1 scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:YES]}];
        }else{
            [_c2 scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:YES]}];
        }
    }
}

/**
 * 发现外围设备
 *
 * @param central 中心设备
 * @param peripheral 外围设备
 * @param advertisementData 特征数据
 * @param RSSI 信号质量（信号强度）
 */
//发现设备     协议中的可选方法      当中心设备找到外设时 自动调用此方法 可以调多次
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if ([peripheral.name isEqualToString:deviceName1] &&
        [central isEqual:_c1]) {
        _sd1 = peripheral;
        [_c1 connectPeripheral:_sd1 options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
    }else if ([peripheral.name isEqualToString:deviceName2] &&
              [central isEqual:_c2]){
        _sd2 = peripheral;
        [_c2 connectPeripheral:_sd2 options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
    }
}

//当点击连接某个蓝牙时回调   协议中的可选方法   当中心设备连接到外设时 自动调用此方法
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([central isEqual:_c1] &&
        [peripheral isEqual:_sd1]) {
        peripheral.delegate = self;
        [peripheral discoverServices:@[self.class.uartServiceUUID, self.class.deviceInformationServiceUUID, self.class.devServiceUUID]];
        DLog(@"设备1已连接");
    }else if ([central isEqual:_c2] &&
              [peripheral isEqual:_sd2]) {
        DLog(@"设备2已连接");
        peripheral.delegate = self;
        [peripheral discoverServices:@[self.class.uartServiceUUID, self.class.deviceInformationServiceUUID, self.class.devServiceUUID]];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([central isEqual:_c1] &&
        [peripheral isEqual:_sd1]) {
        DLog(@"设备1断开连接");
    }else if ([central isEqual:_c2] &&
              [peripheral isEqual:_sd2]) {
        DLog(@"设备2断开连接");
    }
}


//***************************** 连接部分  ********************************************
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        return;
    }
    for (CBService *s in [peripheral services])
    {
        if ([s.UUID isEqual:self.class.uartServiceUUID]) {
            [peripheral discoverCharacteristics:@[self.class.txCharacteristicUUID, self.class.rxCharacteristicUUID] forService:s];
        }else if ([s.UUID isEqual:self.class.deviceInformationServiceUUID]){
            [peripheral discoverCharacteristics:@[self.class.hardwareRevisionStringUUID] forService:s];
        }else if ([s.UUID isEqual:self.class.devServiceUUID]){
            [peripheral discoverCharacteristics:@[self.class.devTxCharacteristicUUID, self.class.devRxCharacteristicUUID] forService:s];
        }
    }
    
}



- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        return;
    }
    for (CBCharacteristic *c in [service characteristics]) {
        if ([c.UUID isEqual:self.class.rxCharacteristicUUID] ||
            [c.UUID isEqual:self.class.devRxCharacteristicUUID]) {
            if([peripheral isEqual:_sd1]) {
                _rxCharacteristic1 = c;
            }else{
                _rxCharacteristic2 = c;
            }
            [peripheral setNotifyValue:YES forCharacteristic:c];
        }else if ([c.UUID isEqual:self.class.txCharacteristicUUID] ||
                  [c.UUID isEqual:self.class.devTxCharacteristicUUID]) {
            if ([peripheral isEqual:_sd1]) {
                _txCharacteristic1 = c;
            }else{
                _txCharacteristic2 = c;
            }
        }
    }
    
}
//************************************************************************************

#pragma mark - 数据传输的重要部分
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        DLog(@"%@",error.localizedDescription);
        return;
    }
    if ([peripheral isEqual:_sd1]) {
        DLog(@"设备1收到数据:%@",characteristic.value);
    }else if ([peripheral isEqual:_sd2]) {
        DLog(@"设备2收到数据:%@",characteristic.value);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
 
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        DLog(@"%@",error.localizedDescription);
        return;
    }
    
}
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        DLog(@"%@",error.localizedDescription);
        return;
    }
    
    if ([peripheral isEqual:_sd1]) {
        DLog(@"设备1写入数据成功:%@",characteristic.value);
    }else if ([peripheral isEqual:_sd2]) {
        DLog(@"设备2写入数据成功:%@",characteristic.value);
    }
    DLog(@"设备1写入数据成功");
}



+ (CBUUID *) uartServiceUUID
{
    return [CBUUID UUIDWithString:@"569a1101-b87f-490c-92cb-11ba5ea5167c"];
}

+ (CBUUID *) devServiceUUID
{
    return [CBUUID UUIDWithString:@"14839ac4-7d7e-415c-9a42-167340cf2339"];
}

+ (CBUUID *) txCharacteristicUUID   //data going to the module
{
    return [CBUUID UUIDWithString:@"569a2000-b87f-490c-92cb-11ba5ea5167c"];
}

+ (CBUUID *) devTxCharacteristicUUID   //data going to the module
{
    return [CBUUID UUIDWithString:@"8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3"];
}

+ (CBUUID *) rxCharacteristicUUID  //data coming from the module
{
    return [CBUUID UUIDWithString:@"569a2001-b87f-490c-92cb-11ba5ea5167c"];
}

+ (CBUUID *) devRxCharacteristicUUID  //data coming from the module
{
    return [CBUUID UUIDWithString:@"0734594A-A8E7-4B1A-A6B1-CD5243059A57"];
}

+ (CBUUID *) deviceInformationServiceUUID
{
    return [CBUUID UUIDWithString:@"180A"];
}

+ (CBUUID *) hardwareRevisionStringUUID
{
    return [CBUUID UUIDWithString:@"2A27"];
}

//const unsigned char Table_CRC8[256]={      /*CRC8 ±í*/
//    0x00, 0x07, 0x0E, 0x09, 0x1C, 0x1B, 0x12, 0x15,
//    0x38, 0x3F, 0x36, 0x31, 0x24, 0x23, 0x2A, 0x2D,
//    0x70, 0x77, 0x7E, 0x79, 0x6C, 0x6B, 0x62, 0x65,
//    0x48, 0x4F, 0x46, 0x41, 0x54, 0x53, 0x5A, 0x5D,
//    0xE0, 0xE7, 0xEE, 0xE9, 0xFC, 0xFB, 0xF2, 0xF5,
//    0xD8, 0xDF, 0xD6, 0xD1, 0xC4, 0xC3, 0xCA, 0xCD,
//    0x90, 0x97, 0x9E, 0x99, 0x8C, 0x8B, 0x82, 0x85,
//    0xA8, 0xAF, 0xA6, 0xA1, 0xB4, 0xB3, 0xBA, 0xBD,
//    0xC7, 0xC0, 0xC9, 0xCE, 0xDB, 0xDC, 0xD5, 0xD2,
//    0xFF, 0xF8, 0xF1, 0xF6, 0xE3, 0xE4, 0xED, 0xEA,
//    0xB7, 0xB0, 0xB9, 0xBE, 0xAB, 0xAC, 0xA5, 0xA2,
//    0x8F, 0x88, 0x81, 0x86, 0x93, 0x94, 0x9D, 0x9A,
//    0x27, 0x20, 0x29, 0x2E, 0x3B, 0x3C, 0x35, 0x32,
//    0x1F, 0x18, 0x11, 0x16, 0x03, 0x04, 0x0D, 0x0A,
//    0x57, 0x50, 0x59, 0x5E, 0x4B, 0x4C, 0x45, 0x42,
//    0x6F, 0x68, 0x61, 0x66, 0x73, 0x74, 0x7D, 0x7A,
//    0x89, 0x8E, 0x87, 0x80, 0x95, 0x92, 0x9B, 0x9C,
//    0xB1, 0xB6, 0xBF, 0xB8, 0xAD, 0xAA, 0xA3, 0xA4,
//    0xF9, 0xFE, 0xF7, 0xF0, 0xE5, 0xE2, 0xEB, 0xEC,
//    0xC1, 0xC6, 0xCF, 0xC8, 0xDD, 0xDA, 0xD3, 0xD4,
//    0x69, 0x6E, 0x67, 0x60, 0x75, 0x72, 0x7B, 0x7C,
//    0x51, 0x56, 0x5F, 0x58, 0x4D, 0x4A, 0x43, 0x44,
//    0x19, 0x1E, 0x17, 0x10, 0x05, 0x02, 0x0B, 0x0C,
//    0x21, 0x26, 0x2F, 0x28, 0x3D, 0x3A, 0x33, 0x34,
//    0x4E, 0x49, 0x40, 0x47, 0x52, 0x55, 0x5C, 0x5B,
//    0x76, 0x71, 0x78, 0x7F, 0x6A, 0x6D, 0x64, 0x63,
//    0x3E, 0x39, 0x30, 0x37, 0x22, 0x25, 0x2C, 0x2B,
//    0x06, 0x01, 0x08, 0x0F, 0x1A, 0x1D, 0x14, 0x13,
//    0xAE, 0xA9, 0xA0, 0xA7, 0xB2, 0xB5, 0xBC, 0xBB,
//    0x96, 0x91, 0x98, 0x9F, 0x8A, 0x8D, 0x84, 0x83,
//    0xDE, 0xD9, 0xD0, 0xD7, 0xC2, 0xC5, 0xCC, 0xCB,
//    0xE6, 0xE1, 0xE8, 0xEF, 0xFA, 0xFD, 0xF4, 0xF3
//};
//
//- (uint8_t)CalCRC8:(u_char *)RP_ByteData bufSize:(u_int)Buffer_Size
//{
//    uint8_t x,R_CRC_Data;
//    uint32_t i;
//
//    R_CRC_Data=0;
//    for(i=0;i<Buffer_Size;i++)
//    {
//        x = R_CRC_Data ^ (*RP_ByteData);
//        R_CRC_Data = Table_CRC8[x];
//        RP_ByteData++;
//    }
//    return R_CRC_Data;
//}


@end
