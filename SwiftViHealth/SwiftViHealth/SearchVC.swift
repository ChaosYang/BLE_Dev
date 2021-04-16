//
//  SearchVC.swift
//  SwiftViHealth
//
//  Created by Viatom on 2019/7/9.
//  Copyright © 2019年 Yang. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, BLEToolsDelegate{
    

    override func viewDidLoad() {
        super.viewDidLoad()
        startScan()
    }
    
    func startScan() {
        BLETools.shared.delegate = self
        BLETools.shared.openBle()
    }
   
    func bleCurrentState(state: bleState) {
        
    }
    

}
