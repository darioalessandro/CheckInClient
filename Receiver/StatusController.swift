//
//  StatusController.swift
//  CheckIniOS
//
//  Created by Dario Lencina on 12/22/15.
//  Copyright © 2015 BlackFireApps. All rights reserved.
//

import UIKit
import Theater
import OAuthClient

public class StatusController : UITableViewController {
    
    var rows : [[UITableViewCell]] = [[UITableViewCell]]()
    public var bluetoothRow : UITableViewCell? = nil
    public var webSocketRow : UITableViewCell? = nil
    public var connectedAs : UITableViewCell? = nil
    public var cachedLoginData : OAuthLoginData? = nil
    
    public let system : ActorSystem = ActorSystem(name:"ActorLand")
    lazy var WSConnection : ActorRef =
        self.system.actorOf(WebSocketConnection.self, name : "WebSocketConnection")
    lazy var BLEConnection : ActorRef =
        self.system.actorOf(ScannerConnection.self, name : "ScannerConnection")
    
    func showError(error : NSError, onClick : Void -> Void) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action) in
            onClick()
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func login() {
        OAuthClient.sharedInstance.login(self) { (loginData , error) in
            if let err = error {
                self.setBluetoothStatus("Disconnected")
                self.setWebSocketStatus("Not Scanning")
                self.showError(err, onClick: {self.login()})
            } else {
                self.cachedLoginData = loginData
                self.setUser(loginData!.username)
                self.connectToBackendAndStartScanning()
            }
        }
    }
    
    func connectedRows() -> [[UITableViewCell]] {
        return [[
            bluetoothRow!,
            webSocketRow!,
            connectedAs!
            ]]
    }
    
    func connectToBackendAndStartScanning() {
        let receiverId = UIDevice.currentDevice().identifierForVendor!.UUIDString
        rows = connectedRows()

        WSConnection ! WebSocketClient.Connect(url: NSURL(string: C.backendURL)!, headers: ["receiverId":receiverId, "username":"dario"], sender: nil)
        BLEConnection ! BLECentral.StartScanning(services: [C.BLE.svc], sender: WSConnection)

    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        login()
        bluetoothRow = self.tableView.dequeueReusableCellWithIdentifier("Bluetooth")
        webSocketRow = self.tableView.dequeueReusableCellWithIdentifier("WebSocket")
        connectedAs = self.tableView.dequeueReusableCellWithIdentifier("ConnectedAs")
        setBluetoothStatus("Disconnected")
        setWebSocketStatus("Not Scanning")
        setUser("-")
        WSConnection ! SetViewCtrl(ctrl: self)
        BLEConnection ! SetViewCtrl(ctrl: self)
    }
    
    public func setBluetoothStatus(status : String) {
        if let bluetoothRow = self.bluetoothRow {
            bluetoothRow.textLabel?.text = "Bluetooth Status"
            bluetoothRow.detailTextLabel?.text = status
        }
    }
    
    public func setWebSocketStatus(status : String) {
        if let webSocketRow = self.webSocketRow {
            webSocketRow.textLabel?.text = "Server Connection"
            webSocketRow.detailTextLabel?.text = status
        }
    }
    
    public func setUser(username : String) {
        if let connectedAs = self.connectedAs {
            connectedAs.textLabel?.text = "Connected as"
            connectedAs.detailTextLabel?.text = username
        }
    }
    
    public func setDevices(devices : [BLECentral.BLEPeripheralObservation]) {
        
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return rows[indexPath.section][indexPath.row]
    }
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rows.count
    }
    
    override public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0:
            return "INTERFACES STATUS"
        case 1:
            return "SESSION"
        default:
            return ""
        }
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
}