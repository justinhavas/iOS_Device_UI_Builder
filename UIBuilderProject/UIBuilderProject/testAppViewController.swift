/*
* Class:       testAppViewController.swift
* Author:      Lucy Chikwetu
* Created:     04/14/20
* Description: This class was written at first as a proof of concept and testing for Bluetooth.
*              We ended up creating other methods to do other things, but we put effort in this and decided to leave
*              the coded here.
*
*/

import UIKit
import CoreBluetooth

class testAppViewController: UIViewController {

    @IBOutlet weak var obj1: UISwitch!
    @IBOutlet weak var obj2: UISlider!
    @IBOutlet weak var obj3: UILabel!
    @IBOutlet weak var sendReceive: UIButton!
    
    var centralManager:CBCentralManager!
    var connectingPeripheral:CBPeripheral!
    var appCharacteristics:[String:CBCharacteristic]?
    var objects:[String:AnyObject] = [:]
    var objectNames:[String:String] = [:]
    var objValue:[String:Any] = [:]
    var uuidArray:[String]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let numPairs:Int = (appCharacteristics!).count
        if numPairs > 0{
            for i in 1...numPairs{
                let j = i-1
                var objName:String = "obj"
                objName = objName + "\(i)"
                ///---print(objName)
                objectNames[uuidArray![j]] = objName
                if (iPhoneCentralViewController.GlobalVariables.objType[uuidArray![j]] == "switch"){
                    ///---print("1 \(uuidArray![j]) + \(objName)")
                    objects[uuidArray![j]] = value(forKey: objName) as! UISwitch
                    (objects[uuidArray![j]])?.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
                }
                else if (iPhoneCentralViewController.GlobalVariables.objType[uuidArray![j]] == "slider"){
                    ///---print("2 \(uuidArray![j]) + \(objName)")
                    objects[uuidArray![j]] = value(forKey: objName) as! UISlider
                    (objects[uuidArray![j]])?.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
                }
                else if(iPhoneCentralViewController.GlobalVariables.objType[uuidArray![j]] == "output"){
                    ///---print("3 \(uuidArray![j]) + \(objName)")
                    objects[uuidArray![j]] = value(forKey: objName) as! UILabel
                }
            }
        }
        sendReceive.addTarget(self, action: #selector(sendData(_:)), for: .touchUpInside)
        
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
    
    /* This code is implemented when a switch is changed */
    @objc func switchChanged(_ sender: UISwitch) {
        sendReceive.backgroundColor = UIColor.systemTeal
        for (uuid,_) in appCharacteristics!{
            if (objects[uuid] === sender){
                objValue[uuid] = sender.isOn
            }
        }
    }
    
    /* This code is implemented when a slider is changed */
    @objc func sliderChanged(_ sender: UISlider) {
        sendReceive.backgroundColor = UIColor.systemTeal
        for (uuid,_) in appCharacteristics!{
            if (objects[uuid] === sender){
                objValue[uuid] = sender.value
            }
        }
    }
    
    /* This function is called when sending data */
    @objc func sendData(_ sender: UIButton){
        sendReceive.backgroundColor = UIColor.systemGreen
        for (uuid,characteristic) in appCharacteristics!{
            if let data = "\(objValue[uuid] ?? "")".data(using: .utf8){
                connectingPeripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
            if (iPhoneCentralViewController.GlobalVariables.objType[uuid] == "output"){
                (value(forKey: objectNames[uuid]!) as! UILabel).text = iPhoneCentralViewController.GlobalVariables.updateValues[uuid]
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }*/
    

}
