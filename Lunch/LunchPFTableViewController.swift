//
//  LunchPFTableViewController.swift
//  Lunch
//
//  Created by Spencer Amann on 8/13/15.
//  Copyright (c) 2015 Spencer Amann. All rights reserved.
//

import ParseUI
import Parse
import UIKit

class LunchPFTableViewController: PFQueryTableViewController {

    let classKey = "Eateries"
    let placeKey = "place"
    let voteKey = "vote"

    var newEateryName: String?

    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
    }

    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)

        self.parseClassName = "Eateries"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }

    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
    }

    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: classKey)

        query.orderByDescending(voteKey)
        return query
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("lunchPlaceCell") as! PFTableViewCell!
        if cell == nil {
            cell = PFTableViewCell(style: .Subtitle, reuseIdentifier: "lunchPlaceCell")
        }
        if let placeName = object?[placeKey] as? String {
            cell?.textLabel?.text = placeName
        }

        if let voteCount = object?[voteKey] as? Int {
            cell?.detailTextLabel?.text = "Votes: \(voteCount)"
        }

        return cell
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            self.objectAtIndexPath(indexPath)?.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success && error == nil {
                    self.loadObjects()
                    self.tableView.reloadData()
                }
            })

        }
        delete.backgroundColor = UIColor.redColor()

        // VOTE
        let vote = UITableViewRowAction(style: .Normal, title: "Vote") { action, index in
            var voteCount = self.objects?[indexPath.row][self.voteKey] as! Int
            self.objectAtIndexPath(indexPath)?.incrementKey("vote")
            self.objectAtIndexPath(indexPath)?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if success && error == nil {
                    self.loadObjects()
                    self.tableView.reloadData()
                }
            })
        }
        vote.backgroundColor = UIColor.blueColor()
        return [vote, delete]
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }

    @IBAction func addPlaceBarItemTapped(sender: UIBarButtonItem) {
        var inputTextField: UITextField?
        let eateryPrompt = UIAlertController(title: "Enter an Eatery", message: "Look up the best place to eat!", preferredStyle: UIAlertControllerStyle.Alert)
        eateryPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        eateryPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
            self.newEateryName = inputTextField?.text
            let eatery = PFObject(className: self.classKey)
            eatery[self.placeKey] = self.newEateryName
            eatery[self.voteKey] = 0
            eatery.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if success && error == nil {
                    self.loadObjects()
                    self.tableView.reloadData()
                }
            })
        }))
        eateryPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Eatery"
            inputTextField = textField
            inputTextField?.autocapitalizationType = UITextAutocapitalizationType.Words
            inputTextField?.keyboardType = UIKeyboardType.NamePhonePad
        })
        presentViewController(eateryPrompt, animated: true, completion: nil)
    }

    @IBAction func logoutBarItemTapped(sender: UIBarButtonItem) {
        PFUser.logOut()
        let currentUser = PFUser.currentUser()
        if currentUser == nil {
            self.navigationController?.popToRootViewControllerAnimated(true)
        } else {
            println("Something went wrong logging out with user: \(currentUser)")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailView = segue.destinationViewController as! TodaysLunchViewController

        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let row = Int(indexPath.row)
            detailView.currentObject = (objects?[row] as! PFObject)
            detailView.selectedIndex = row
        }
    }
}
