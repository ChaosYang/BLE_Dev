//
//  ViaPeriPool.swift
//  SwiftViHealth
//
//  Created by Viatom on 2019/7/10.
//  Copyright © 2019年 Yang. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViaPeriPool: NSObject {
    static let shared = ViaPeriPool()
    var periArray = Array<CBPeripheral>()
    var periNameArray = Array<String>()
    let viaPeriArray: Array = ["O2 ","O2BAND ","SleepO2 ","O2Ring ","WearO2 ","SleepU ","DuoEK ","Pulsebit "]
    
    func customAppend(peri: CBPeripheral) {
        if self.isViaPeri(peri: peri) {
            if !periNameArray.contains(peri.name!) {
                periArray.append(peri)
                periNameArray.append(peri.name!)
            }
        }
    }
    
    func customRemoveAll() {
        periArray.removeAll()
        periNameArray.removeAll()
    }
    
    func isViaPeri(peri: CBPeripheral) -> Bool {
        if peri.name != nil {
            for element in viaPeriArray {
                if peri.name!.hasPrefix(element) {return true}
            }
        }
        return false
    }
    
}
