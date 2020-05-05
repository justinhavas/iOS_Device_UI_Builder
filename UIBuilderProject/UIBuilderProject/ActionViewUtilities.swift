//
//  ActionViewFactory.swift
//  UIBuilderProject
//
//  Created by Justin Havas on 4/23/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//
// This class is used to centralize the types and methods pertaining to actionViews in the iPad.

import UIKit

class ActionViewUtilities {

    static let sliderString = "Slider"
    static let switchString = "Switch"
    static let labelString = "Label"
    static let uiInputs: [[String]] = [[sliderString,"slider.jpg"],[switchString,"switch.jpg"],[labelString,"label.jpg"]]
    static let nameIndex = 0
    static let imageIndex = 1

    /*
    This method returns the string pertaining to a given actionView.
    */
    static func getStringFromView(view: UIView?) -> String? {
        if (view as? DragDropView)?.actionView is UISlider {
            return sliderString
        } else if (view as? DragDropView)?.actionView is UISwitch {
            return switchString
        } else if (view as? DragDropView)?.actionView is UILabel {
            return labelString
        }
        return nil
    }
    
    /*
    This method returns the actionView pertaining to a given string.
    */
    static func getActionViewFromString(string: String) -> UIView {
        switch string {
        case sliderString:
            return UISlider()
        case switchString:
            return UISwitch()
        case labelString:
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 34))
            label.text = "Label"
            label.font = UIFont.systemFont(ofSize: 16, weight: .thin)
            label.textColor = UIColor(named: "themeColor")
            label.textAlignment = .center
            label.isHidden = false
            return label
        default:
            return UIImageView(image: UIImage(named: string))
        }
    }
    
    /*
    This method returns a new actionView of the same type as the given actionView.
    */
    static func getViewFromActionView(actionView: UIView) -> UIView? {
        if actionView is UISlider {
            return getActionViewFromString(string: sliderString)
        } else if actionView is UISwitch {
            return getActionViewFromString(string: switchString)
        } else if actionView is UILabel {
            return getActionViewFromString(string: labelString)
        }
        return nil
    }
    
    /*
    This method sets the addTarget attribute of an actionView if it is possible.
    */
    static func addTarget(_ actionView: UIView, _ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        if actionView is UILabel {
            return
        }
        if actionView is UISlider {
            (actionView as! UISlider).addTarget(target, action: action, for: controlEvents)
        }
        if actionView is UISwitch {
            (actionView as! UISwitch).addTarget(target, action: action, for: controlEvents)
        }
        return
    }
}
