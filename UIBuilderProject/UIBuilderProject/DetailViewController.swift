//
//  DetailViewController.swift
//  UIBuilderProject
//
//  Created by Justin Havas on 3/28/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//
// This class is used to represent the Detail Canvas View seen on the iPad.

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var saveProjectButton: UIBarButtonItem!
    var project:build?
    var dropView: UIView?
    var draggedView: UIView?
    var savedGestureView: UIView?
    var alignments: (x: CGFloat?,y: CGFloat?)
    var lines: [UIView] = []
    var builder: Builder!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup splitViewController if not already
        setupSplitViewController()
        
        // drop setup
        dropView = getDropView()
        let dropInteraction = UIDropInteraction(delegate: self)
        dropView?.addInteraction(dropInteraction)
        
        // initialize builder
        builder = Builder(project!.name)
        if project!.chars.count != 0 && project!.chars[0].count > 0 {
            builder = Builder(from:project!)
            for tempView in builder.toolMap.keys {
                tempView.addInteraction(UIDragInteraction(delegate: self))
                tempView.isUserInteractionEnabled = true
                self.addTapGesture(thisView: tempView)
                dropView?.addSubview(tempView)
            }
        }
        // initialize save project button
        saveProjectButton.target = self
        saveProjectButton.action = #selector(clickedSave)
    }
    
    /*
    This method is copied from SceneDelegate.swift in order to initialize
    the splitViewController.
    */
    func setupSplitViewController() {
        if splitViewController?.preferredDisplayMode != UISplitViewController.DisplayMode.allVisible {
            if let splitView = splitViewController {
                if let navigationController = splitView.viewControllers.last as? UINavigationController {
                    navigationController.topViewController?.navigationItem.leftBarButtonItem = splitView.displayModeButtonItem
                    navigationController.topViewController?.navigationItem.leftItemsSupplementBackButton = true
                    splitView.preferredDisplayMode = .allVisible
                }
            }
        }
    }
    
    /*
    This method finds us the dropView initialized through the storyboard.
    */
    func getDropView() -> UIView? {
        for obj in view.subviews {
            // only other view is an ImageView
            if obj as? UIImageView == nil {
                return obj
            }
        }
        return nil
    }
    
    /*
    This method is called when the saveProjectButton is selected and checks whether the
    project can be saved. If so, it will return the UUIDs needed to replicate this project
    in the iPhone.
    */
    @objc func clickedSave() {
        for subview in dropView!.subviews {
            if !(subview as! DragDropView).isInitialized {
                let alert = UIAlertController(title: "Error", message: "Cannot save until all items on the screen have been initialized.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
        }
        let uuids = builder.save()
        projects.update(builder.project!)
        let message = buildMessage(uuids: uuids)
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    /*
    This method builds the uuids string to be displayed in the success save message.
    */
    func buildMessage(uuids:[String:String]) -> String {
        var output = ""
        for key in uuids.keys.sorted() {
            let value = uuids[key] ?? ""
            output = output + key + ": " + value + "\n"
        }
        return output
    }

    @IBAction func unwindToDetail(segue:UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.destination as? UINavigationController else { return }
        guard let popupMenu = navController.children[0] as? MenuPopupViewController else { return }
        popupMenu.detailView = (sender as! UIView)
        popupMenu.currentViewNames = dropView?.subviews.map({($0 as? DragDropView)?.name ?? ""})
    }
        
}

