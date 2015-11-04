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
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The delegate and datasource are set on the storyboard to the table view
        // No need to set them again in here
        
        // Add right the bar buttons
        let infoPostingButton = UIBarButtonItem(image: UIImage(named: "Pin"), style: .Plain, target: self,
            action: "infoPosting"
        )
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self,
            action: "refreshStudents"
        )
        navigationItem.setRightBarButtonItems([refreshButton, infoPostingButton], animated: true)
    }

    // MARK: - Actions
    
    @IBAction func logout(sender: AnyObject) {
        self.segue("LoginViewController")
    }
    
    // MARK: - Table View Delegate

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.studentsInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 1. Dequeue a reusable cell from the table, using the correct “reuse identifier”
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell")
        
        // 2. Find the model object that corresponds to that row
        let studentForRow = self.appDelegate.studentsInfo[indexPath.row]
        
        // 3. Set the images and labels in the cell with the data from the model object
        cell!.textLabel?.text = studentForRow.firstName + " " + studentForRow.lastName
        cell!.imageView?.image = UIImage(named: "Pin")
        
        // 4. return the cell
        return cell!
    }
    
    /// When the table row is selected, open Safari to the student's link
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let studentUrl = self.appDelegate.studentsInfo[indexPath.row].mediaURL {
            UIApplication.sharedApplication().openURL(NSURL(string: studentUrl)!)
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
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Segues and Alerts
    
    func segue(nextVC: String) {
        dispatch_async(dispatch_get_main_queue(), {
            // Grab storyboard
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            // Get the destination controller from the storyboard id
            let nextVC = storyboard.instantiateViewControllerWithIdentifier(nextVC)
            // Go to the destination controller
            self.presentViewController(nextVC, animated: true, completion: nil)
        })
    }
    
    func alertView(message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .Alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            alertController.addAction(dismiss)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }

}
