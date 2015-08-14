//
//  CreateAccountViewController.swift
//  Lunch
//
//  Created by Spencer Amann on 8/1/15.
//  Copyright (c) 2015 Spencer Amann. All rights reserved.
//

import UIKit
import Parse

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmedPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createAccountButtonClick(sender: AnyObject) {
        let user = PFUser()

        var noErrors = checkInputForErrors(userNameTextField.text ?? "", password: passwordTextField.text ?? "",
                                        email: emailTextField.text ?? "", confirmedPassword: confirmedPasswordTextField.text ?? "")
        if noErrors {
            user.username = userNameTextField.text
            user.password = passwordTextField.text
            user.email = emailTextField.text
            
            user.signUpInBackgroundWithBlock { (succes: Bool, error:NSError?) in
                if error == nil {
                   self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }

    func checkInputForErrors(username: String, password: String, email: String, confirmedPassword: String) -> Bool {
        let alertView = UIAlertController(title: "Error", message: "", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        var hasNoErrors = true
        if username == "" {
            alertView.message = "No username"
            hasNoErrors = false
        } else if email == "" {
            alertView.message = "No email"
            hasNoErrors = false
        } else if password != confirmedPassword {
            alertView.message = "Passwords don't match"
            hasNoErrors = false
        } else if password == "" {
            alertView.message = "No password"
            hasNoErrors = false
        }
        if !hasNoErrors {
            presentViewController(alertView, animated: true, completion: nil)
        }
        return hasNoErrors
    }
}
