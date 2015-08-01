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

    let loginIdentifier = "loginAfterCreateAccount"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createAccountButtonClick(sender: AnyObject) {
        let user = PFUser()

        var noErrors = checkkInputForErrors(userNameTextField.text ?? "", password: passwordTextField.text ?? "",
                                        email: emailTextField.text ?? "", confirmedPassword: confirmedPasswordTextField.text ?? "")
        if noErrors {
            user.username = userNameTextField.text
            user.password = passwordTextField.text
            user.email = emailTextField.text
            
            user.signUpInBackgroundWithBlock { (succes: Bool, error:NSError?) -> Void in
                if error == nil {
                    self.performSegueWithIdentifier(self.loginIdentifier, sender: self)
                } else {
                    var alert = UIAlertView(title: "Error", message: "There was a problem", delegate: nil, cancelButtonTitle: "Whoops")
                    alert.show()
                }
            }
        }
    }

    func checkkInputForErrors(username: String, password: String, email: String, confirmedPassword: String) -> Bool {
        var alert = UIAlertView()
        var noErrors = true
        if username == "" {
            alert = UIAlertView(title: "Error", message: "No username", delegate: nil, cancelButtonTitle: "Whoops")
            noErrors = false
        } else if email == "" {
            alert = UIAlertView(title: "Error", message: "No email", delegate: nil, cancelButtonTitle: "Whoops")
            noErrors = false
        } else if password != confirmedPassword {
            alert = UIAlertView(title: "Error", message: "Passwords don't match", delegate: nil, cancelButtonTitle: "Whoops")
            noErrors = false
        } else if password == "" {
            alert = UIAlertView(title: "Error", message: "No password", delegate: nil, cancelButtonTitle: "Whoops")
            noErrors = false
        }
        if !noErrors {
            alert.show()
        }
        return noErrors
    }
}
