//
//  iPadDropView.swift
//  UIBuilderProject
//
//  Created by Justin Havas on 4/17/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//
// This class is used to represent the dropView that dragged views can be placed onto. This class is primarly used to notify when an orientation change has occurred an update the subviews to be resized.

import UIKit

class iPadDropView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    /*
    This property allows us to track when the orientation has changed.
    */
    override var bounds: CGRect {
        didSet {
            updateSubViewsWithOrientation()
        }
    }
    
    /*
    This method iterates through each subview and resizes it.
    */
    func updateSubViewsWithOrientation() {
        for subview in self.subviews {
            subview.removeFromSuperview()
            let dragdropview = subview as? DragDropView
            let nilOrActionView = ActionViewUtilities.getViewFromActionView(actionView: (dragdropview?.actionView)!)
            if let actionView = nilOrActionView {
                let associatedLabel = dragdropview?.associatedLabel.text ?? ""
                let name = dragdropview?.name ?? ""
                dragdropview?.buildView(actionView: actionView, label: associatedLabel,name: name, dropViewFrame: self.frame)
                self.addSubview(dragdropview!)
            }
        }
    }

}
