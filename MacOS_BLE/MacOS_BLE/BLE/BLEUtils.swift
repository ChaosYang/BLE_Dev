//
//  BLEUtils.swift
//  MacOS_BLE
//
//  Created by viatom on 2019/10/31.
//  Copyright © 2019 viatom. All rights reserved.
//

import Cocoa
import CoreBluetooth


@objc protocol BLEUtilsDelegate{
    @objc optional func bleCurrentState(state :CBManagerState)
    @objc optional func findPeriphral(periphral :CBPeripheral)
    @objc optional func updatingPeriphral()
    @objc optional func didConnected()
}

class BLEUtils: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    static let shared: BLEUtils = {
        let instance = BLEUtils()
        return instance
    }()
    
    weak var delegate: BLEUtilsDelegate?
    var macCentralManager: CBCentralManager!
    var selectPeripheral: CBPeripheral!
    var rxCharacteristic: CBCharacteristic!
    var txCharacteristic: CBCharacteristic!
    
    let serviceArray: Array = [BLEUtils.uartServiceUUID(),
                               BLEUtils.devServiceUUID(),
                               BLEUtils.heartRateServiceUUID()]  // 胎心仪
    
    // MARK: 设备服务
    static func uartServiceUUID() -> CBUUID {
        return CBUUID.init(string: "569a1101-b87f-490c-92cb-11ba5ea5167c")
    }
    static func devServiceUUID() -> CBUUID {
        return CBUUID.init(string: "14839ac4-7d7e-415c-9a42-167340cf2339")
    }
    static func heartRateServiceUUID() -> CBUUID {
        return CBUUID.init(string: "180D")
    }
    // MARK: 设备特征
    static func readCharacteristicUUID() -> CBUUID {
        return CBUUID.init(string: "569a2000-b87f-490c-92cb-11ba5ea5167c")
    }
    static func writeCharacteristicUUID() -> CBUUID {
        return CBUUID.init(string: "569a2001-b87f-490c-92cb-11ba5ea5167c")
    }
    static func devReadCharacteristicUUID() -> CBUUID {
        return CBUUID.init(string: "0734594A-A8E7-4B1A-A6B1-CD5243059A57")
    }
    static func devWriteCharacteristicUUID() -> CBUUID {
        return CBUUID.init(string: "8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3")
    }
    
    // TODO: 获取蓝牙状态
    open func openBluetooth(){
        macCentralManager = CBCentralManager.init(delegate: self, queue: nil)
    }
    // MARK: 根据UUID获取所有已连接的指定外设
    open func getAllConnectedPeriphral() -> [CBPeripheral] {
        let uuid = CBUUID.value(forUndefinedKey: "14839AC4-7D7E-415C-9A42-167340CF2339")
        let arr = macCentralManager.retrieveConnectedPeripherals(withServices: uuid as! [CBUUID])
        return arr
    }
    // TODO: 开始扫描
    open func startScan(){
        macCentralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    // TODO: 停止扫描
    open func stopScan(){
        macCentralManager.stopScan()
    }
    // TODO: 指定外设连接
    open func connectTo(periphral : CBPeripheral){
        macCentralManager.connect(periphral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
    }
    // TODO: 断开指定外设
    open func disConnectTo(periphral : CBPeripheral?){
        macCentralManager.cancelPeripheralConnection(periphral ?? selectPeripheral)
    }
    
    open func writeData(rawData: NSData){
        if selectPeripheral.state == .connected {
            selectPeripheral.writeValue(rawData as Data, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
    // MARK: CBCentralManagerDelegate
    // MARK: 发现蓝牙
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let localName: String? = advertisementData["kCBAdvDataLocalName"] as? String
        if localName != peripheral.name {
            peripheral.setValue(localName, forKey: "name")
        }
        delegate?.findPeriphral?(periphral: peripheral)
    }
    
    // MARK: 监听蓝牙状态变化
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.bleCurrentState?(state: central.state)
    }
    // MARK: 已经连接到外设
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let name: String = peripheral.name ?? ""
        if name.hasSuffix("Updater") {
            delegate?.updatingPeriphral?()
        }else{
            selectPeripheral = peripheral
            peripheral.delegate = self as CBPeripheralDelegate
            peripheral.discoverServices(serviceArray)
        }
    }
    // MARK: 连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    // MARK: 与外设失去连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    
    // MARK: CBPeripheralDelegate
    // MARK: 监听外设RSSI
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
    }
    // MARK: 发现外设的所有服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("Error discovering services:\(error!.localizedDescription)")
            return
        }
        for service in peripheral.services! {
            if service.uuid.isEqual(BLEUtils.uartServiceUUID()) {
                peripheral.discoverCharacteristics([BLEUtils.writeCharacteristicUUID(),BLEUtils.readCharacteristicUUID()], for: service)
            } else if service.uuid.isEqual(BLEUtils.devServiceUUID()) {
                peripheral.discoverCharacteristics([BLEUtils.devWriteCharacteristicUUID(),BLEUtils.devReadCharacteristicUUID()], for: service)
            } else if service.uuid.isEqual(BLEUtils.heartRateServiceUUID()) {
                
            }
        }
        
        
    }
    // MARK: 发现某个服务下的特征值
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering characteristics:\(error!.localizedDescription)")
            return
        }
        if rxCharacteristic == nil || txCharacteristic == nil {
            for c in service.characteristics! {
                if c.uuid.isEqual(BLEUtils.readCharacteristicUUID()) ||
                   c.uuid.isEqual(BLEUtils.devReadCharacteristicUUID()) {
                    rxCharacteristic = c
                    peripheral.setNotifyValue(true, for: c)
                } else if c.uuid.isEqual(BLEUtils.writeCharacteristicUUID()) ||
                          c.uuid.isEqual(BLEUtils.devWriteCharacteristicUUID()) {
                    txCharacteristic = c
                }
            }
        }else {
            delegate?.didConnected?()
        }
    }
    // MARK: 接受数据的重要部分
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error receiving notification for characteristic \(characteristic): \(error!.localizedDescription)")
            return
        }
        if characteristic == rxCharacteristic {
            CommunicateUtils.shared.receiveData(characteristic.value!)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error update notification for characteristic \(characteristic): \(error!.localizedDescription)")
            return
        }
    }
    
}


