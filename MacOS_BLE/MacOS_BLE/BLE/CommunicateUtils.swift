//
//  CommunicateUtils.swift
//  MacOS_BLE
//
//  Created by viatom on 2019/11/1.
//  Copyright © 2019 viatom. All rights reserved.
//

import Cocoa
import CoreBluetooth

private enum CMDKind {
    case prepare
    case info
    case settings
    case wave
    case factory
    case readFile
    case startRead
    case stopRead
    case writeFile
    case startWrite
    case stopWrite
}

@objc public enum ReadResult: Int {
    case success
    case timeOut
    case fail
    case notExist
}

@objc protocol CommunicateUtilsDelegate {
    @objc optional func receivedInfo(data: Data?,andResult result: ReadResult)
}


class CommunicateUtils: NSObject {
    static let shared: CommunicateUtils = {
        let instance = CommunicateUtils()
        return instance
    }()
    weak var delegate: CommunicateUtilsDelegate?
    var dataPool = Data()
    
    
    private var cmd: CMDKind!
    private var firstPkg: Bool!
    private let aPkgLength: Int = 20
     
    
    open func beginGetInfo() {
        let infoPkg = InfoPkg.init().buf!
        firstPkg = true
        cmd = .info
        self.sendData(infoPkg, delay: 3000)
    }
    
    func receiveData(_ pkgData: Data) {
        if cmd == .prepare {
            print("Untargeted data")
        }else {
            let bytes = [uint8](pkgData)
            if firstPkg && bytes[0] != 0x55 {
                return
            }else {
                firstPkg = false
                self.addDataToPool(data: pkgData)
            }
        }
    }
    
    private func addDataToPool(data: Data) {
        dataPool.append(data as Data)
        let currentLength = dataPool.count
        let bytes = [uint8](dataPool)
        let pkgLength: Int = Int(bytes[5]) + Int(bytes[6]) << 8 + 8
        print("receiveData:\(pkgLength)+\(currentLength)")
        if currentLength < pkgLength {
            return
        }else {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            dealWithData()
            clearCache()
        }
    }
    
    private func dealWithData() {
        switch cmd {
        case .info:
            let infoAck = InfoAck.init(dataPool)
            if infoAck == nil {
                delegate?.receivedInfo?(data: nil, andResult: .fail)
            }else {
                delegate?.receivedInfo?(data: infoAck!.infoData, andResult: .success)
            }
            cmd = .prepare
            break
        default:
            break
        }
    }
    
    
    private func sendData(_ buf: NSData, delay sec: Int) {
        clearCache()
        for i in stride(from: 0, to: buf.length, by: aPkgLength) {
            if i > 0 {
                sleep(200)
            }
            let range: NSRange = NSRange.init(location: i, length: min(aPkgLength, buf.length - i))
            let subData: NSData = buf.subdata(with: range) as NSData
            BLEUtils.shared.writeData(rawData: subData)
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(NSSelectorFromString("sendTimeOut"), with: nil, afterDelay: TimeInterval(sec))
    }
    
    // MARK: 超时
    private func sendTimeOut() {
        print("Communicate time out.\(String(describing: cmd))")
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    // MARK: 清空缓存重头开始
    private func clearCache() {
        dataPool.removeAll()
        firstPkg = false
    }
    
}
