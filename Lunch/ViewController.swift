//
//  ViewController.swift
//  Lunch
//
//  Created by Spencer Amann on 7/27/15.
//  Copyright (c) 2015 Spencer Amann. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var lunchTableView: UITableView!
    @IBOutlet weak var lunchTextField: UITextField!

    var lunchChoice: Int!
    var items: [String] = []
    let lunchItemCellIdentifier = "LunchItemCell"
    let emptyString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lunchTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: lunchItemCellIdentifier)
        self.lunchTextField.delegate = self
        if items.isEmpty {
            retrievePlaces()
            updateTableView()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = self.lunchTableView.dequeueReusableCellWithIdentifier(lunchItemCellIdentifier) as! UITableViewCell

        cell.textLabel?.text = self.items[indexPath.row]

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: add stuff here man
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        let place = self.lunchTextField.text
        items.append(place)
        let testObject = PFObject(className: "Eateries")
        testObject["place"] = place
        testObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if success {
                println("Place \(place) has been saved")
            }
        }
        updateTableView()
        self.lunchTextField.text = emptyString
    }

    func retrievePlaces() {
        var query = PFQuery(className: "Eateries")
        query.whereKeyExists("place")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                var pfobjects = objects as! [PFObject]
                for object in pfobjects {
                    var place = object["place"] as! String
                    self.items.append(place)
                    self.updateTableView()
                }
            } else {
                println("Error: \(error!)")
            }
        }
    }

    func updateTableView() {
        var indexSet = NSIndexSet(index: 0)
        self.lunchTableView.beginUpdates()
        self.lunchTableView.reloadSections(indexSet, withRowAnimation: .Fade)
        self.lunchTableView.endUpdates()
    }
}