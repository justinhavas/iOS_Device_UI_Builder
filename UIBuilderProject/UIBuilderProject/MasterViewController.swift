//
//  MasterViewController.swift
//  UIBuilderProject
//
//  Created by Justin Havas on 3/28/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//
// This class is used to represent the Master Table View seen on the iPad.

import UIKit

class MasterViewController: UITableViewController, UITableViewDragDelegate {

    var detailViewController: DetailViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // drag setup
        self.tableView.dragDelegate = self
        self.tableView.dragInteractionEnabled = true
        
        // Do any additional setup after loading the view.
        
        // setup splitViewController if not already
        setupSplitViewController()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
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

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            detailViewController = controller
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // showDetail segues are prevented from the selection of a tableView cell because
        // we don't want the user to reset the canvas unless they ask to.
        return identifier != "showDetail" || !(sender is UITableViewCell)
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ActionViewUtilities.uiInputs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let uiInput = ActionViewUtilities.uiInputs[indexPath.row]
        cell.textLabel!.text = uiInput[ActionViewUtilities.nameIndex]
        cell.imageView?.image = UIImage(named: uiInput[ActionViewUtilities.imageIndex])
        return cell
    }
    
    // MARK: - Drag

    /*
    This method begins a UIDragSession from the tableView and resets tha draggedView and
    alignments within the DetailViewController.
    */
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let cell = tableView.cellForRow(at: indexPath)
        guard let text = cell?.textLabel?.text else { return [] }
        let provider = NSItemProvider(object: text as NSString)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = text
        detailViewController?.draggedView = cell?.imageView
        detailViewController?.clearUpAlignments()
        return [item]
    }

}

