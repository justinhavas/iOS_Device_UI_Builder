//
//  DetailGestureRecognizerDelegate.swift
//  UIBuilderProject
//
//  Created by Justin Havas on 4/16/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//
// This extension is used to maintain all the code relating to tapping on a view in order to edit or delete it.

import UIKit

extension DetailViewController: UIGestureRecognizerDelegate {
    // MARK: - Tapping
    
    /*
    This method adds the necessary properties to allow view to call this code when tapped.
    */
    func addTapGesture(thisView: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.clickView(_:)))
        tapGesture.delegate = self
        thisView.addGestureRecognizer(tapGesture)
    }
    
    /*
    This method creates the UIMenuController used to display the edit and delete options
    when the revognizerView is tapped.
    */
    @objc func clickView(_ sender: UITapGestureRecognizer) {
        if let recognizerView = sender.view {
            savedGestureView = recognizerView
            let menuController = UIMenuController.shared
            let edit = UIMenuItem(title: "Edit", action: #selector(self.clickedEdit(_:)))
            let delete = UIMenuItem(title: "Delete", action: #selector(self.clickedDelete(_:)))
            menuController.menuItems = [edit,delete]
            menuController.showMenu(from: recognizerView.superview!, rect: recognizerView.frame)
            recognizerView.becomeFirstResponder()
        }
    }
    
    /*
    This method runs when the edit menu item is selected and segues to the
     MenuPopupViewController.
    */
    @objc func clickedEdit(_ sender: UIMenuController) {
        if let savedView = savedGestureView {
            performSegue(withIdentifier: "toMenu", sender: savedView)
        }
        savedGestureView = nil
    }
    
    /*
    This method runs when the delete menu item is selected and deletes the view from the dropView.
    */
    @objc func clickedDelete(_ sender: UIMenuController) {
        if let savedView = savedGestureView {
            savedView.removeFromSuperview()
            builder.delete(savedView)
        }
        savedGestureView = nil
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
