//
//  AddBeaconController.swift
//  CheckIniOS
//
//  Created by Dario Lencina on 3/16/16.
//  Copyright © 2016 BlackFireApps. All rights reserved.
//

import UIKit
import CoreBluetooth
import Theater

class AddBeaconActor : ViewCtrlActor<AddBeaconController> {
    
    required init(context : ActorSystem, ref : ActorRef) {
        super.init(context: context, ref: ref)
    }
    
    lazy var central : ActorRef = self.context.actorOf(BLECentral.self, name:"BLECentral2")
    
    override func preStart() {
        super.preStart()
        self.central ! BLECentral.AddListener(sender: this)
        self.central ! BLECentral.StartScanning(services: [], sender: self.this)
    }

    override func receiveWithCtrl(ctrl: AddBeaconController) -> Receive {
        
        return {[unowned self](msg : Actor.Message) in
            switch(msg) {
                case let m as BLECentral.DevicesObservationUpdate:
                    let devices = m.devices.filter { (identifier, observations) in
                        if let observation = observations.first,
                            let rawName = observation.advertisementData[CBAdvertisementDataLocalNameKey],
                            let name = rawName as? String {
                            return name  == "Beacon"
                        } else {
                            return false
                        }
                    }
                    
                    ^{ctrl.setDevices(devices)}
                
                default: break
                
            }
        }
    }
}

class AddBeaconController: UITableViewController, UIAlertViewDelegate {
    
    var system : ActorSystem?
    
    var beacon : ActorRef?

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beacon  = self.system!.actorOf(AddBeaconActor.self, name:"AddBeaconActor")        
        beacon! ! SetViewCtrl(ctrl: self)
    }
    
    var devices : [(String , [BLECentral.BLEPeripheralObservation])]?
    
    func setDevices(array : [(String , [BLECentral.BLEPeripheralObservation])]) {
        self.devices = array
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let devices = self.devices {
            return devices.count 
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tedcruzsucks", forIndexPath: indexPath)
        if let titleLabelView = cell.viewWithTag(666),
           let titleLabel = titleLabelView as? UILabel,
            let devices = devices {
                let values = devices[indexPath.row]
                let observation = values.1.first
                titleLabel.text = observation!.peripheral.name
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alertView = UIAlertController(title: "Select Beacon name", message: nil, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action) in
            //TODO enroll beacon
            if let textFields = alertView.textFields,
                let first = textFields.first,
                let beaconName = first.text,
                let devicesMaterialized = self.devices,
                let observation = devicesMaterialized[indexPath.row].1.first {                
                    CreateBeacon().createBeacon(observation, name: beaconName, result: { (dict, error) in
                        print("error \(error)")
                    })
            }
        }))
        alertView.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        alertView.addTextFieldWithConfigurationHandler {(text) in }
        
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}
