//
//  ProjectMenuTableViewController.swift
//  UIBuilderProject
//
//  Created by Justin Havas on 4/16/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//
// This class is used to represent the Project Menu Table View that appears when the "Let's Go" button is clicked on the iPad. This tableView contains all the projects created and saved on this particular device.

import UIKit

var projects : ProjectCollection = ProjectCollection()

class ProjectMenuTableViewController: UITableViewController {
    var selectedProject : build = build()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.leftBarButtonItem = editButtonItem
        self.loadInitialData()
        self.tableView.reloadData()
        // loading from disk of projects
    }
    
    /**
     load data from JSON if possible, otherwise use the default construction and save that to JSON
     */
    func loadInitialData() {
        if let tempCollection = ProjectCollection.load() {
            projects = tempCollection
        } else {
            let _ = ProjectCollection.save(projects)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return projects.projectArr.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = projects.projectArr[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProject = projects.projectArr[indexPath.row]
        performSegue(withIdentifier: "iPadViewSegue", sender: nil)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            projects.delete(projects.projectArr[indexPath.row])
            let _ = ProjectCollection.save(projects)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard let splitViewController = segue.destination as? UISplitViewController else { return }
        guard let navigationController = splitViewController.viewControllers.last as? UINavigationController else { return }
        guard let detailController = navigationController.children[0] as? DetailViewController else { return }
        detailController.project = selectedProject
    }
    
    @IBAction func unwindFromAddProject(segue:UIStoryboardSegue) {
        let _ = ProjectCollection.save(projects)
        self.tableView.reloadData()
    }

}
