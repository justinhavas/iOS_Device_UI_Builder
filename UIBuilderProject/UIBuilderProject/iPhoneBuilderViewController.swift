/*
* Class:       iPhoneCentralViewController.swift
* Authors:     Lucy Chikwetu & Lakshya Bakshi
* Created:     04/17/20
* Description: This is a class for the iphone popup view.
*              the Bluetooth central manager and allows connection with the peripheral.
*
*/

import Foundation
import UIKit
import CoreBluetooth

class iPhoneBuilderViewController : UIViewController {
    var centralManager:CBCentralManager!
    var connectingPeripheral:CBPeripheral!
    var appCharacteristics:[String:CBCharacteristic]?
    var uuidArray:[String]?
    var jsonString:String?
    var objValue:[String:Any] = [:]

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    struct GlobalVariables{
        static var viewMap : [UIView:(String,String)] = [:]
        static var build:Builder?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView()
        GlobalVariables.build = Builder(json: jsonString!)
        view.backgroundColor=UIColor(named: "lightGray0")
        
        /*
         * This viewmap maps a UIView to a tuple holding (type, UUID). Type is one of "output", "slider", or "switch".
         * The UIView CAN'T BE DOWNCAST TO A UISWITCH, UILABEL, OR UIBUTTON since its most specific type is
         * "DragDropView", a custom class Justin made. You'll need to downcast the UIView to a DragDropView and add
         * targets to the actionView property.
         */
        
        GlobalVariables.viewMap = (GlobalVariables.build?.generateTools())!
        navigationBar.title = GlobalVariables.build?.project?.name
        
        for tool in GlobalVariables.viewMap.keys { //This loop will iterate through each view. This is where we need to give each action its target.
            setupEventTargets(tool, GlobalVariables.viewMap[tool]!.0)
            view.addSubview(tool)
        }
        self.view=view
    }///---viewDidLoad()
    
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
    
    /* Here we set up targets for all our controls */
    func setupEventTargets(_ view : UIView, _ type : String) {
        if (type == "output") {
            // i don't know what happens here
        }
        else if (type == "slider") {
            (view as! DragDropView).addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)

        }
        else { // type is switch
            (view as!DragDropView).addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        }
    }
    
    /* This code is implemented when a switch is changed */
    @objc func switchChanged(_ sender: UISwitch) {
        for (view,tuple) in GlobalVariables.viewMap{
            if ((GlobalVariables.build?.getViewType(view))! == "switch"){
                if(((view as! DragDropView).actionView!) === sender){
                    objValue[tuple.1] = sender.isOn
                }
            }
        }
    }
    
    /* This code is implemented when a slider is changed */
    @objc func sliderChanged(_ sender: UISlider) {
        for (view,tuple) in GlobalVariables.viewMap{
            if ((GlobalVariables.build?.getViewType(view))! == "slider"){
                if(((view as! DragDropView).actionView!) === sender){
                    objValue[tuple.1] = sender.value
                }
            }
        }
    }
    
    /* We implement this code when we send data. We only send data when we press the refresh button. */
    @IBAction func sendData(_ sender: UIBarButtonItem) {
        for (uuid,characteristic) in appCharacteristics!{
            if let data = "\(objValue[uuid] ?? "")".data(using: .utf8){
                connectingPeripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        }
    }
}
