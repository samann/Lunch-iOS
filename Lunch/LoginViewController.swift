//
//  LoginViewController.swift
//  Lunch
//
//  Created by Spencer Amann on 8/1/15.
//  Copyright (c) 2015 Spencer Amann. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    let loginIdentifier = "loginSegue"
    let createAccountIdentifier = "createAccount"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let currentUser = PFUser.currentUser(), username = currentUser.username {
                self.performSegueWithIdentifier(self.loginIdentifier, sender: self)
        }
    }

    @IBAction func loginNavButtonTapped(sender: UIBarButtonItem) {
        if let username = userNameTextField.text, password = passwordTextField.text {
            if !checkForErrorsInInput(username, password: password) {
                PFUser.logInWithUsernameInBackground(username, password: password, block: { (user: PFUser?, error:NSError?) in
                    if user != nil && error == nil {
                        self.performSegueWithIdentifier(self.loginIdentifier, sender: self)
                    } else {
                        let alertView = UIAlertController(title: "Error", message: "Login Failed.\nWhoops!", preferredStyle: UIAlertControllerStyle.Alert)
                        self.presentViewController(alertView, animated: true, completion: nil)
                    }
                })
            }
        }

    }

    @IBAction func createAccountButtonTapped(sender: UIButton) {
        self.performSegueWithIdentifier(createAccountIdentifier, sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == loginIdentifier {
            let lunchTableViewController = segue.destinationViewController as! LunchPFTableViewController
            lunchTableViewController.loadObjects()
        }
    }

    func checkForErrorsInInput(username: String, password: String) -> Bool {
        var hasErrors = false
        var alertView = UIAlertController(title: "Error", message: "", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        let name = username, psswrd = password
        if name.isEmpty {
            alertView.message = "No username"
            hasErrors = true
        }
        if psswrd.isEmpty {
            alertView.message = "No password"
            hasErrors = true
        }
        if hasErrors {
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        return hasErrors
    }
}
