//
//  TableViewController.swift
//  On The Map
//
//  Created by Ioannis Tornazakis on 23/4/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The delegate and datasource are set on the storyboard to the table view
        // No need to set them again in here
        
        // Add right the bar buttons
        let infoPostingButton = UIBarButtonItem(
            image: UIImage(named: "Pin"),
            style: .plain,
            target: self,
            action: #selector(TableViewController.infoPosting)
        )
        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.refresh,
            target: self,
            action: #selector(TableViewController.refreshStudents)
        )
        
        navigationItem.setRightBarButtonItems([refreshButton, infoPostingButton], animated: true)
    }

    // MARK: - Actions
    
    @IBAction func logout(_ sender: AnyObject) {
        self.segue("LoginViewController")
    }
    
    // MARK: - Table View Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.studentsInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1. Dequeue a reusable cell from the table, using the correct “reuse identifier”
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")
        
        // 2. Find the model object that corresponds to that row
        let studentForRow = self.appDelegate.studentsInfo[(indexPath as NSIndexPath).row]
        
        // 3. Set the images and labels in the cell with the data from the model object
        cell!.textLabel?.text = studentForRow.firstName + " " + studentForRow.lastName
        cell!.imageView?.image = UIImage(named: "Pin")
        
        // 4. return the cell
        return cell!
    }
    
    /// When the table row is selected, open Safari to the student's link
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let studentUrl = self.appDelegate.studentsInfo[(indexPath as NSIndexPath).row].mediaURL {
            UIApplication.shared.openURL(URL(string: studentUrl)!)
        } else {
            self.alertView("Student has not assigned a URL")
        }
    }
    
    // MARK: - Helpers
    
    func infoPosting() {
        self.segue("InformationPostingViewController")
    }
    
    func refreshStudents() {
        
        // Get the current student info
        ParseClient.getStudentData(){ result, error in
            
            if error != nil {
                
                // Disiplay an alert view "Failed to download student info"
                self.alertView(error!)
                
            } else {
                
                // Store the student's info into the appDelegate
                self.appDelegate.studentsInfo = result!
            }
        }
        
        // Reload the data
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Segues and Alerts
    
    func segue(_ nextVC: String) {
        DispatchQueue.main.async(execute: {
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: nextVC)
            self.present(nextVC, animated: true, completion: nil)
        })
    }
    
    func alertView(_ message: String) {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alertController.addAction(dismiss)
            self.present(alertController, animated: true, completion: nil)
        })
    }

}
