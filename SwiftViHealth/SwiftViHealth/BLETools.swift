//
//  BLETools.swift
//  SwiftViHealth
//
//  Created by Viatom on 2019/7/9.
//  Copyright © 2019年 Yang. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc public enum bleState: Int{
    case bleIsOn
    case bleIsOff
    case bleIsUnsupported
}

@objc protocol BLEToolsDelegate: NSObjectProtocol{
    @objc optional func bleCurrentState(state: bleState)
    @objc optional func periUpdateAdInfo(peri: CBPeripheral, info: NSData?)
    @objc optional func connectViaPeriTimeOut()
}

class BLETools: NSObject, CBCentralManagerDelegate {
    
    static let shared = BLETools()
    private override init() {}
    var centralManager : CBCentralManager!
    var connectedPeri : CBPeripheral!
    weak var delegate : BLEToolsDelegate?
    //TODO:检测蓝牙状态
    func openBle() {
        centralManager = CBCentralManager.init(delegate: self, queue: nil);
    }
    //TODO:获取系统蓝牙内已连接的设备信息
    func getAllSystemConnectedPeri() -> Array<CBPeripheral> {
        return centralManager.retrieveConnectedPeripherals(withServices: [CBUUID.init(string: "14839AC4-7D7E-415C-9A42-167340CF2339")])
    }
    
    func startScan(allowDuplicate: Bool) {
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:allowDuplicate])
    }
    
    func stopScan() {
        centralManager.stopScan()
        ViaPeriPool.shared.customRemoveAll()
    }
    
    func connectViaPeri(viaPeri: CBPeripheral?) {
        if viaPeri != nil {
            centralManager.connect(viaPeri!, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
            connectedPeri = viaPeri!;
            self.perform(#selector(timeOut), with: self, afterDelay: 10.0)
        }
    }
    
    @objc func timeOut() {
        NSObject.cancelPreviousPerformRequests(withTarget: self);
        if connectedPeri != nil {
            if delegate != nil && delegate!.responds(to: #selector(BLEToolsDelegate.connectViaPeriTimeOut)) {
                delegate!.connectViaPeriTimeOut!()
            }
        }
    }
    
    func disconnectViaPeri(viaPeri: CBPeripheral?) {
        if viaPeri != nil {
            centralManager.cancelPeripheralConnection(viaPeri!)
        }
    }
    
    func notifyRSSI(viaPeri: CBPeripheral?) {
        if viaPeri != nil {
            viaPeri!.readRSSI()
        }
    }
    
    //MARK:CentralManager Delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
        switch central.state {
        case .poweredOn:
            if delegate != nil && delegate!.responds(to: #selector(BLEToolsDelegate.bleCurrentState(state:))) {
                delegate!.bleCurrentState!(state: .bleIsOn)
            }
            break
        case .poweredOff:
            if delegate != nil && delegate!.responds(to: #selector(BLEToolsDelegate.bleCurrentState(state:))) {
                delegate!.bleCurrentState!(state: .bleIsOff)
            }
            break
        default:
            if delegate != nil && delegate!.responds(to: #selector(BLEToolsDelegate.bleCurrentState(state:))) {
                delegate!.bleCurrentState!(state: .bleIsUnsupported)
            }
            break
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name != nil {
            print(peripheral.name!,advertisementData["kCBAdvDataLocalName"] as Any, separator: "&")
        }
        if delegate != nil && delegate!.responds(to: #selector(BLEToolsDelegate.periUpdateAdInfo(peri:info:))) {
            delegate!.periUpdateAdInfo!(peri: peripheral, info: (advertisementData["kCBAdvDataManufacturerData"] as! NSData))
        }
        
        if peripheral.name != nil && connectedPeri == nil {
            let localName: AnyObject = advertisementData["kCBAdvDataLocalName"] as AnyObject;
            if( localName is NSNull ||
                localName.isEqual("")){
                // localName 无效
            }else{
                peripheral.setValue(localName, forKey: "name")
            }
            ViaPeriPool.shared.customAppend(peri: peripheral)
        }else if ( peripheral.name != nil &&  peripheral.name! == connectedPeri.name!){
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    
}
