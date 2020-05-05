//
//  AddProjectViewController.swift
//  UIBuilderProject
//
//  Created by Justin Havas on 4/16/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//
// This class is used to represent the Add Project View that appears when the user wishes to create a new project on the iPad.

import UIKit

class AddProjectViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameTextField.placeholder = "eg. myProject"
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard let projectMenu = segue.destination as? ProjectMenuTableViewController else { return }
        if (sender as? UIBarButtonItem)?.description == saveButton.description {
            let newProj = build(nameTextField.text ?? "", [[:]])
            projects.update(newProj)
            projectMenu.tableView.reloadData()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let name = nameTextField.text ?? ""
        let value = (sender as? UIBarButtonItem)?.description != saveButton.description || (!testWithRegex(testString: name, pattern: "^[a-zA-z0-9_-]{1,10}$") && !projects.getAllProjectNames().contains(name))
        if !value {
            let alert = UIAlertController(title: "Error", message: "Project Name must be unique, have no more than 10 characters, and only contain letter, number, underscore, or dash characters.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        return value
    }


}
