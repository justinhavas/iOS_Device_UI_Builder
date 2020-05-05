/*
 * Class:       iPhoneCentralViewController.swift
 * Author:      Lucy Chikwetu
 * Created:     04/04/20
 * Description: This is a class for the iPhoneCentralViewController. It is the class that hosts
 *              the Bluetooth central manager and allows connection with the peripheral.
 *
 */

import UIKit
import CoreBluetooth

class iPhoneCentralViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanSwitch: UISwitch!
    @IBOutlet weak var discoverLabel: UILabel!
    
    var centralManager:CBCentralManager!
    var connectingPeripheral:CBPeripheral!
    var appCharacteristics:[String:CBCharacteristic] = [:]
    var uuidArray:[String] = []
    
    var data:String = ""
    
    var discoveredDevices:[CBPeripheral] = [CBPeripheral]()
    var establishedConnection:Bool = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self,queue: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.centralManager.stopScan()
        super.viewWillDisappear(animated)
    }
    
    /* We do not allow the iphone to autorotate */
    override var shouldAutorotate: Bool{
        return false
    }
    
    /* We only support portrait interface */
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    /* This is a function that is called when you want to start scanning */
    @IBAction func switchChanged(_ sender: Any) {
        if (scanSwitch.isOn){
            discoverLabel.text = "Scanning for peripherals"
            print("Scanning for peripherals")
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
        else{
            self.centralManager.stopScan()
            discoveredDevices = []
            self.tableView.reloadData()
            discoverLabel.text = "Switch on to start scanning"
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "testApp"){
            let testAppVC:testAppViewController = segue.destination as! testAppViewController
            testAppVC.centralManager = centralManager
            testAppVC.connectingPeripheral = connectingPeripheral
            testAppVC.appCharacteristics = appCharacteristics
            testAppVC.uuidArray = uuidArray
        }
        else if(segue.identifier == "builderApp"){
            let builderAppNavVC:UINavigationController = segue.destination as! UINavigationController
            let builderAppVC = builderAppNavVC.topViewController as! iPhoneBuilderViewController
            builderAppVC.centralManager = centralManager
            builderAppVC.connectingPeripheral = connectingPeripheral
            builderAppVC.appCharacteristics = appCharacteristics
            builderAppVC.uuidArray = uuidArray
            builderAppVC.jsonString = GlobalVariables.jsonInfo
        }
    }
    
    /*This is just a struct of global variables to be used in the popup view*/
    struct GlobalVariables{
        static var updateValues:[String:String] = [String:String]()
        static var jsonInfo:String = ""
        static var objType:[String:String] = [String:String]()
    }
}

//MARK: TableView Methods
extension iPhoneCentralViewController: UITableViewDelegate, UITableViewDataSource{
    /*
     * Here we populate our table with the number of discovered devices. We discover all devices &
     * our app will determinehow many if they comply with the app protocol
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.discoveredDevices.count)
    }
    
    /* We don't do any special thing, we pretty much just list our discovered devices */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = (discoveredDevices[indexPath.row]).name
        return cell
    }

    /* When one selects a device, start a connection with the peripheral or we cancel the current connection */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            if (cell.accessoryType == .checkmark){
                cell.accessoryType = .none
                centralManager.cancelPeripheralConnection(connectingPeripheral)
                connectingPeripheral = nil
                tableView.deselectRow(at: indexPath, animated: true)
                tableView.reloadData()
                self.centralManager.scanForPeripherals(withServices: nil, options: nil)
                return
            }
            cell.tintColor = UIColor(named: "red1")
            var i:Int = -1
            for device in discoveredDevices{
                i = i+1
                if ((device.name) == (cell.textLabel!.text)){
                    break
                }
            }
          
            if (discoveredDevices.count == 1){
                if (connectingPeripheral != nil){
                    cell.accessoryType = .none
                    centralManager.cancelPeripheralConnection(connectingPeripheral)
                    connectingPeripheral = nil
                    tableView.deselectRow(at: indexPath, animated: true)
                    tableView.reloadData()
                    self.centralManager.scanForPeripherals(withServices: nil, options: nil)
                }
                else{
                    connectingPeripheral = discoveredDevices[i]
                    connectingPeripheral.delegate = self
                    centralManager.connect( discoveredDevices[i], options: nil)
                    cell.accessoryType = .checkmark
                }
            }
            else{
                if (connectingPeripheral != nil){
                    /*Here, if there is an established connection, it's dropped and we establish a new connection*/
                    let connectedIndex:Int = discoveredDevices.firstIndex(of: connectingPeripheral)!
                    tableView.cellForRow(at: IndexPath(row: connectedIndex, section: 0))?.accessoryType = .none
                    centralManager.cancelPeripheralConnection(connectingPeripheral)
                    connectingPeripheral = discoveredDevices[i]
                    connectingPeripheral.delegate = self
                    centralManager.connect( discoveredDevices[i], options: nil)
                    cell.accessoryType = .checkmark
                } else{
                    connectingPeripheral = discoveredDevices[i]
                    connectingPeripheral.delegate = self
                    centralManager.connect( discoveredDevices[i], options: nil)
                    cell.accessoryType = .checkmark
                }
            } //else (discoveredDevices.count == 1)
        }
        establishedConnection = false
    }// func didSelectRowAt indexPath:
    
}

//MARK: Central Manager Delegate Methods
extension iPhoneCentralViewController: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch(central.state){
        case .poweredOff:
            print("Central not powered on!")
        case .poweredOn:
            print("Central powered on!")
        default:
            return
        }
    }
    
    /*
     * When we discover a peripheral, we just add it to the discovered peripherals. We do not do any special thing
     * here, no special pruning yet.
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if RSSI.intValue > -15 {
            return
        }
       
        if ((self.discoveredDevices.contains(peripheral) == false) && (peripheral.name != nil)){
            print("Discovered \(String(describing: peripheral.name)) \(String(describing: peripheral.services)) at \(RSSI)")
            discoveredDevices.append(peripheral)
            self.tableView.reloadData()
        }
    }
    
    /* When we fail to connect, we implement this.*/
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral) due to error \(String(describing: error))")
        self.cleanup()
    }
    
    /* When we connect to a peripheral, we implement this code.*/
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("\n\nPeripheral connected\n\n")
        centralManager.stopScan()
        peripheral.delegate = self as CBPeripheralDelegate
        peripheral.discoverServices(nil)
        
    }
    
    /* When you disconnect a peripheral */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let index:Int = discoveredDevices.firstIndex(of: peripheral) ?? -1
        if (index != -1){
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)){
                cell.accessoryType = .none
                if (!establishedConnection){
                    tableView.reloadData()
                }
            }
        }
       
        if (error != nil){
            print("Error on didDisconnect is \(String(describing: error))")
            discoveredDevices.remove(at: index)//--
            tableView.reloadData()
        }
        connectingPeripheral = nil
        establishedConnection = false
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
}

//MARK: Peripheral Delegate methods
extension iPhoneCentralViewController:CBPeripheralDelegate{
    /* When you discover services */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("Error discovering services \(String(describing: error))")
            self.cleanup()
        }
        else {
            for service in peripheral.services! as [CBService] {
                if (uuidToJson(service: service.uuid.uuidString) != nil){
                    let index:Int = discoveredDevices.firstIndex(of: peripheral) ?? -1
                    if (index != -1){
                        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)){
                            cell.tintColor = UIColor(named: "darkGreen1")
                        }
                    }
                    peripheral.discoverCharacteristics(nil, for: service)
                    establishedConnection = true
                }
            }
        }
    }
    
    /* This code is implemented when you discover characteristics */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error - \(String(describing: error))")
            print(error as Any)
            self.cleanup()
        }
        else {
            var characteristicsStr:[String] = [String]()
            if let characteristics = service.characteristics{
                for characteristic in characteristics{
                    characteristicsStr.append(characteristic.uuid.uuidString)
                }
                if (uuidToJson(service: service.uuid.uuidString, characteristics: characteristicsStr) != nil){
                    GlobalVariables.jsonInfo = uuidToJson(service: service.uuid.uuidString, characteristics: characteristicsStr)!
                    GlobalVariables.objType = lookupDictionary(GlobalVariables.jsonInfo)
                    
                    for characteristic in characteristics{
                        uuidArray.append(characteristic.uuid.uuidString)
                        appCharacteristics[characteristic.uuid.uuidString] = characteristic
                       
                        if (GlobalVariables.objType[characteristic.uuid.uuidString]) != nil {
                            if (GlobalVariables.objType[characteristic.uuid.uuidString]! == "output"){
                                peripheral.setNotifyValue(true, for: characteristic) //----crosscheck this
                            }
                        }
                    }
                    self.performSegue(withIdentifier: "builderApp", sender: self)
                }
            }
        }
    }
    
    /* When the peripheral updates a value, this function is implemented */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("error")
        }
        else {
            let dataString = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)
            
            if dataString == "EOM" {
                //----We don't do anything special when we get an EOM here----//
                //--peripheral.setNotifyValue(false, for: characteristic)
                //--centralManager.cancelPeripheralConnection(peripheral)
            }
            else {
                let strng:String = dataString! as String
                self.data += strng
                GlobalVariables.updateValues.updateValue((dataString as String?)!, forKey: characteristic.uuid.uuidString)
                
                for (view,tuple) in iPhoneBuilderViewController.GlobalVariables.viewMap{
                    if ((iPhoneBuilderViewController.GlobalVariables.build?.getViewType(view))! == "output"){
                        (((view as! DragDropView).actionView!) as! UILabel).text = GlobalVariables.updateValues[tuple.1]
                    }
                }
        
            }
        }
    }
    
    /* This is implemented when you update a notification state for a characteristic */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error changing notification state \(String(describing: error))")
        }
        if (appCharacteristics[characteristic.uuid.uuidString] == nil){
            return
        }
      
        if (characteristic.isNotifying) {
            print("Notification began on \(characteristic)")
        }
        else {
            print("Notification stopped on \(characteristic). Disconnecting")
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    /* Basic cleanup code */
    func cleanup() {
        switch connectingPeripheral.state {
        case .disconnected:
            print("Cleanup called, .Disconnected")
            return
        case .connected:
            if (connectingPeripheral.services != nil) {
                print("Found")
                //add any additional cleanup code here
            }
        default:
            return
        }
    }
    
}
