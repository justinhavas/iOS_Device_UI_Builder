//
//  MenuPopupViewController.swift
//  UIBuilderProject
//
//  Created by Justin Havas on 4/11/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//
// This class is used to represent the Menu Popup View that appears when the user selects the Edit button in the UIMenuController above a view.

import UIKit

class MenuPopupViewController: UIViewController {
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var detailView: UIView!
    var currentViewNames: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        labelTextField.text = (detailView as? DragDropView)?.associatedLabel.text
        labelTextField.placeholder = "eg. Power"
        nameTextField.text = (detailView as? DragDropView)?.name
        nameTextField.placeholder = "eg. PW1"
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (sender as? UIBarButtonItem)?.description == saveButton.description, let detailViewController = segue.destination as? DetailViewController {
            let name = nameTextField.text ?? ""
            let label = labelTextField.text ?? ""
            (detailView as? DragDropView)?.updateAssociatedLabel(label: label,name: name)
            detailViewController.builder.edit(detailView, name, label)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let name = nameTextField.text ?? ""
        let label = labelTextField.text ?? ""
        let errorMessage = validateNameAndLabel(name: name, label: label)
        let value = (sender as? UIBarButtonItem)?.description != saveButton.description || errorMessage == ""
        if !value {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        return value
    }
    
    /*
    This method is used to validate the name and label input by the user.
    */
    func validateNameAndLabel(name: String,label: String) -> String {
        if name == "" || label == "" {
            return "Cannot save empty name or label."
        }
        if testWithRegex(testString: name, pattern: "^[a-zA-z0-9_-]{3}$") {
            return "Name must be 3 characters long and only contain letter, number, underscore, or dash characters."
        }
        if testWithRegex(testString: label, pattern: "^[a-zA-z0-9_-]{1,8}$") {
            return "Label must have no more than 8 characters and only contain letter, number, underscore, or dash characters."
        }
        if name != (detailView as? DragDropView)?.name && currentViewNames.contains(name) {
            return "Name must be unique."
        }
        return ""
    }

}

/*
This method creates a regex based off the provided pattern and returns whether to testString did not pass the regex.
*/
func testWithRegex(testString: String, pattern: String) -> Bool {
    let range = NSRange(location: 0, length: testString.utf16.count)
    let regex = try! NSRegularExpression(pattern: pattern)
    return regex.firstMatch(in: testString, options: [], range: range) == nil
}
