//
//  DragDropView.swift
//  UIBuilderProject
//
//  Created by Justin Havas on 4/16/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//
// This class is used to represent every single view being dragged and dropped onto the dropView. It allows us to add multiple views into the single one being dragged and dropped.

import UIKit

class DragDropView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    let widthRatio:CGFloat = 100/238.5
    let heightRatio:CGFloat = 34/553
    
    // these variables are made private because we wanted setting to be done through the provided methods.
    private(set) var actionView: UIView!
    private(set) var associatedLabel: UILabel!
    private(set) var name: String!
    private var initializationBox: UIImageView?
    
    var isInitialized: Bool {
        get {
            return associatedLabel.text != ""
        }
    }
    
    /*
    These properties are important to override so that the UIMenuController in
    DetailGestureRecognizerDelegate.swift will appear.
    */
    override var canBecomeFirstResponder: Bool { return true }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(DetailViewController.clickView(_:))
    }
  
    /*
    This method is basically used as an initialization method for the DragDropView class.
    Creating my own init() method proved to be difficult when also needing to initialize
    the UIView inheritance.
     
    The dropViewFrame parameter is used to resize the view based off the dropViewFrame. If
    nil, no resizing will be done. Resizing is done for every element except for UISwitch.
    This is because UISwitch is not really an API meant to be resized so weird things
    happen if you do.
    */
    func buildView(actionView:UIView,label:String,name:String,dropViewFrame:CGRect?) {
        if !(actionView is UISwitch), let dropViewF = dropViewFrame {
            // calculate size of views based off dropView, based calculations off 12.9" iPad
            let beforeX = actionView.frame.minX
            let beforeY = actionView.frame.minY
            let thisWidthRatio = dropViewF.size.width/actionView.frame.width
            let thisHeightRatio = dropViewF.size.height/actionView.frame.height
            let transform = CGAffineTransform(scaleX: thisWidthRatio * widthRatio, y: thisHeightRatio * heightRatio)
            actionView.transform = transform
            initializationBox?.transform = transform
            let frame = CGRect(x: beforeX, y: beforeY, width: actionView.frame.width, height: actionView.frame.height)
            actionView.frame = frame
            initializationBox?.frame = frame
        }
        addActionView(actionView: actionView)
        updateAssociatedLabel(label: label,name: name)
    }
    
    /*
    This method updates the actionView and adds the actionView to self.
    */
    private func addActionView(actionView:UIView) {
        self.actionView?.removeFromSuperview()
        self.initializationBox?.removeFromSuperview()
        self.actionView = actionView
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: actionView.frame.width, height: actionView.frame.height)
        self.addSubview(actionView)
    }
    
    /*
    This method updates the associatedLabel and name, and based off whether they are empty
    strings, creates the initializationBox.
    */
    func updateAssociatedLabel(label:String,name:String) {
        self.associatedLabel?.removeFromSuperview()
        associatedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 34))
        associatedLabel.text = label
        associatedLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        associatedLabel.textAlignment = .center
        associatedLabel.isHidden = false
        self.name = name
        
        if label != "" {
            
            // add associated label to self and adjust actionView and self frames.
            let myHeight = actionView.frame.height + associatedLabel.frame.height
            // UISwitch is too small to base width of entire view off of
            let width = actionView is UISwitch ? associatedLabel.frame.width : actionView.frame.width
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: width, height: myHeight)
            associatedLabel.frame = CGRect(x: 0, y: 0, width: width, height: associatedLabel.frame.height)
            actionView.frame = CGRect(x: actionView is UISwitch ? width/2-actionView.frame.width/2 : 0, y: 0 + associatedLabel.frame.height, width: actionView.frame.width, height: actionView.frame.height)
            
            // adding a subview that is already there does nothing, so no need to check
            self.addSubview(associatedLabel)
            initializationBox?.removeFromSuperview()
        } else if initializationBox == nil {
            makeInitializationBox()
        } else {
            self.addSubview(initializationBox!)
        }
    }
    
    /*
    This method creates the red initialization box signifying that this view needs a label
    and name.
    */
    private func makeInitializationBox() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        let redColor = UIColor.red
        let redLine:UIBezierPath = UIBezierPath(rect: self.frame)
        redColor.set()
        redLine.stroke()
        let redbox:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        initializationBox = UIImageView(frame: self.frame)
        initializationBox?.image = redbox
        self.addSubview(initializationBox!)
    }
    
    /*
    This method removes the label of this view.
    */
    func removeAssociatedLabel() {
        self.associatedLabel.removeFromSuperview()
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: actionView.frame.width, height: actionView.frame.height)
        actionView.frame = CGRect(x: 0, y: 0, width: actionView.frame.width, height: actionView.frame.height)
        updateAssociatedLabel(label: "",name: self.name)
    }
    /*
     function to add target to the action view of the drag drop view
     */
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        ActionViewUtilities.addTarget(self.actionView,target, action: action, for: controlEvents)
    }
    
}
