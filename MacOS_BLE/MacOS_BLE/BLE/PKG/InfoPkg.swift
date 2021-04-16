//
//  InfoAck.swift
//  MacOS_BLE
//
//  Created by viatom on 2019/11/5.
//  Copyright © 2019 viatom. All rights reserved.
//

import Cocoa

class InfoPkg: NSObject {
    var buf: NSData!
    override init() {
        super.init()
        var byteArr = [uint8](repeating: 0, count: 8)
        byteArr[0] = 0xAA
        byteArr[1] = 0x14
        byteArr[2] = ~0x14
        byteArr[7] = SecretCRC.shared.calCRC8(byteArr, bufSize: 7)
        buf = NSData(bytes: byteArr, length: byteArr.count)
    }
}
