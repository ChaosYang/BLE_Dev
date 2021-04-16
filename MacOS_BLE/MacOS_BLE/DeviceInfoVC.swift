//
//  DeviceInfoVC.swift
//  MacOS_BLE
//
//  Created by viatom on 2019/11/7.
//  Copyright © 2019 viatom. All rights reserved.
//

import Cocoa

class DeviceInfoVC: NSViewController, CommunicateUtilsDelegate {
    
    var dic: [String: Any]?
    let gap: CGFloat = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        title = BLEUtils.shared.selectPeripheral.name
        getInfo()
        
    }
    // TODO: request periphral's info
    func getInfo(){
        CommunicateUtils.shared.delegate = self
        CommunicateUtils.shared.beginGetInfo()
    }
    // TODO: refresh UI with info
    func refreshUI() {
        if dic != nil {
            let labH: CGFloat = 20.0
            let labW: CGFloat = (view.frame.width - 3*gap) / 2.0
            let keys = [String](dic!.keys)
            
            for i in stride(from: 0, to: dic!.count, by: 1) {
                let key = keys[i]
                let val = dic![key]
                let lab = NSTextField.init(frame: NSRect.init(x: gap +  (CGFloat)(i % 2) * (gap + labW), y: gap + (CGFloat)(i / 2) * (gap + labH), width: labW, height: labH))
                lab.isEditable = false
                lab.isBordered = false
                lab.alignment = .left
                lab.maximumNumberOfLines = 0
                lab.stringValue = "\(key):\(String(describing: val))"
                view.addSubview(lab)
            }
    
           // rect.height = (labH + gap) * CGFloat(dic!.count) + gap
            view.window?.setContentSize(NSSize.init(width: 600.0, height:(labH + gap) * CGFloat(dic!.count) + gap))
        }
    }
    
    
    // MARK:CommunicateUtilsDelegate
    func receivedInfo(data: Data?, andResult result: ReadResult) {
        if result == .success {
            dic = InfoAck.parser(data!)
            refreshUI()
        }else {
            dic = nil
        }
    }
    
    
}
