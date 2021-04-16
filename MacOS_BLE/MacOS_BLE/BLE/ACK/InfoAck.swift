//
//  InfoAck.swift
//  MacOS_BLE
//
//  Created by viatom on 2019/11/8.
//  Copyright © 2019 viatom. All rights reserved.
//

import Cocoa

class InfoAck: NSObject {
    
    var infoData = Data()
    
    init?(_ buf: Data) {
        super.init()
        let bytes = [uint8](buf)
        let pkgLength: Int = Int(bytes[5]) + Int(bytes[6]) << 8 + 8
        if bytes[0] != 0x55 {
            print("Info response header error")
            return nil
        }else if bytes[1] != 0x00 || bytes[2] != 0xFF {
            print("Info response pkg error")
            return nil
        }else if bytes[pkgLength - 1] != SecretCRC.shared.calCRC8(bytes, bufSize: uint32(pkgLength-1)) {
            print("CRC error")
            return nil
        }else {
            let infoStr = NSMutableString()
            for i in stride(from: 7, to: pkgLength, by: 1) {
                if bytes[i] != 0 {
                    infoStr.appendFormat("%c", bytes[i])
                }else {
                    break
                }
            }
            infoData = infoStr.data(using: String.Encoding.utf8.rawValue)!
        }
    }
    
    class func parser(_ dicData: Data) -> [String: Any] {
        
        let dic = try? JSONSerialization.jsonObject(with: dicData, options: .mutableContainers)
        
        return dic as! [String: Any]
        
    }
}
