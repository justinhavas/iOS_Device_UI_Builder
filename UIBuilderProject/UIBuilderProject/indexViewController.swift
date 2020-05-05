//
//  indexViewController.swift
//  UIBuilderProject
//
//  Created by Mai Noku on 4/3/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//

import UIKit

class indexViewController: UIViewController {
    let deviceIsiPad = UIDevice.current.model == "iPad"
    
    @IBOutlet weak var launchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        launchButton.layer.cornerRadius = launchButton.frame.height / 4
        
        // Do any additional setup after loading the view.
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    @IBAction func launchButtonAction(_ sender: Any) {
        if (deviceIsiPad){
            performSegue(withIdentifier: "chooseProject", sender: self)
        } else{
            performSegue(withIdentifier: "iPhoneViewSegue", sender: self)
        }
    }
    
    @IBAction func unwindFromProjectMenu(segue:UIStoryboardSegue) {
        
    }
    
    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
