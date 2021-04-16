//
//  ViewController.swift
//  MacOS_BLE
//
//  Created by viatom on 2019/10/31.
//  Copyright © 2019 viatom. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ScanViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, BLEUtilsDelegate {

    @IBOutlet weak var tableView: NSTableView!
    lazy var deviceArray: NSMutableArray = {
        return NSMutableArray.init()
    }()
    lazy var nameArray: NSMutableArray = {
        return NSMutableArray.init()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    
    // TODO: Search peripheral
    @IBAction func searchDevice(_ sender: NSButton) {
        BLEUtils.shared.delegate = self as BLEUtilsDelegate
        BLEUtils.shared.openBluetooth()
    }
    
    // MARK: TableView Delegate&DataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return deviceArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let text = nameArray.object(at: row) as! String
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "mycell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        print("当前选中行:\(tableView.selectedRow)")
        let periphral: CBPeripheral = deviceArray.object(at: tableView.selectedRow) as! CBPeripheral;
        BLEUtils.shared.connectTo(periphral: periphral)
    }
    


    // MARK: BLEUtilsDelegate
    func bleCurrentState(state: CBManagerState) {
        if state == .poweredOn {
            BLEUtils.shared.startScan()
        }
    }
    
    func findPeriphral(periphral: CBPeripheral) {
        if periphral.name == nil || ((periphral.name?.range(of: "O2")) == nil) {
            return
        }
        if !nameArray.contains(periphral.name as Any) {
            nameArray.add(periphral.name as Any)
            deviceArray.add(periphral as Any)
            tableView.reloadData()
        }
    }
    
    func didConnected() {
        let story = NSStoryboard.main
        let vc = story?.instantiateController(withIdentifier: "DashboardWindow") as! NSWindowController
        BLEUtils.shared.delegate = nil
        vc.window?.orderFront(nil)
        view.window?.orderOut(self)
    }
}

