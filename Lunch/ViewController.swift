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

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: .ValueChanged)
        return refreshControl
    }()

    var eateries: [String] = []
    var votes: [Int] = []
    var tableViewSelectedIndex = -1
    var votePushSent = false

    let lunchDetailSegueIdentifier = "LunchDetailSegue"
    let logoutSegueIdentifier = "logoutSegue"
    let lunchItemCellIdentifier = "LunchItemCell"
    let emptyString = ""

    let classNameKey = "Eateries"
    let placeColumnKey = "place"
    let voteColumnKey = "vote"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lunchTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: lunchItemCellIdentifier)
        self.lunchTextField.delegate = self
        if eateries.isEmpty {
            retrievePlaces()
            updateTableView()
        }
        self.lunchTableView.addSubview(self.refreshControl)
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailView = segue.destinationViewController as? TodaysLunchViewController {
            if let eateryIndex = lunchTableView.indexPathForSelectedRow()?.row {
                detailView.textForLunchLabel = eateries[eateryIndex]
                detailView.textForVotesLabel = "\(votes[eateryIndex])"
                detailView.selectedIndex = lunchTableView.indexPathForSelectedRow()!.row as Int
            }

        }

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eateries.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = self.lunchTableView.dequeueReusableCellWithIdentifier(lunchItemCellIdentifier) as? UITableViewCell
        if cell != nil {
            cell! = UITableViewCell(style: .Subtitle, reuseIdentifier: lunchItemCellIdentifier)
        }
        cell!.textLabel?.text = self.eateries[indexPath.row]
        cell!.detailTextLabel?.text = "Votes: \(self.votes[indexPath.row])"

        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableViewSelectedIndex = indexPath.row
        self.performSegueWithIdentifier(lunchDetailSegueIdentifier, sender: lunchTableView)
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        let place = self.lunchTextField.text
        let vote = 0
        eateries.append(place)
        votes.append(vote)
        let testObject = PFObject(className: classNameKey)
        testObject[placeColumnKey] = place
        testObject[voteColumnKey] = vote
        testObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if success {
                println("Place \(place) has been saved with \(vote) votes")
            }
        }
        updateTableView()
        self.lunchTextField.text = emptyString
        let time = 60.0
        let timer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "startVoting", userInfo: nil,repeats: false)
    }

    func startVoting() {
        if !votePushSent {
            votePushSent = true
            let push = PFInstallation.query()
            push?.whereKey("deviceType", equalTo: "ios")
            PFPush.sendPushMessageToQueryInBackground(push
                , withMessage: "Start voting! \nYou have 30 minutes until voting ends")
            let time = 30.0 * 60.0
            let timer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "stopVoting", userInfo: nil, repeats: false)
        }
    }

    func stopVoting() {
        if votePushSent {
            let push = PFInstallation.query()
            push?.whereKey("deviceType", equalTo: "ios")
            PFPush.sendPushMessageToQueryInBackground(push, withMessage: "Voting has endend! \nThank you for playing Lunch!")
            votePushSent = false
        }
    }
    func retrievePlaces() {
        var query = PFQuery(className: classNameKey)
        query.whereKeyExists(placeColumnKey)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                var pfobjects = objects as! [PFObject]
                for object in pfobjects {
                    var place = object[self.placeColumnKey] as! String
                    var vote = object[self.voteColumnKey] as! Int
                    if !contains(self.eateries, place) {
                        self.eateries.append(place)
                        self.votes.append(vote)
                        self.updateTableView()
                    }
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

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {

        // DELETE
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            var query = PFQuery(className: self.classNameKey)
            query.whereKeyExists(self.placeColumnKey)
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                var pfobjects = objects as! [PFObject]
                for object in pfobjects {
                    var place = object[self.placeColumnKey] as! String
                    if place == self.eateries[index.row] {
                        pfobjects[index.row].deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            if error == nil {
                                self.eateries.removeAtIndex(index.row)
                                println("Place \(place) has been removed at index \(index.row)")
                                self.updateTableView()
                            }
                        })
                    }
                }
            })


        }
        delete.backgroundColor = UIColor.redColor()

        // VOTE
        let vote = UITableViewRowAction(style: .Normal, title: "Vote") { action, index in
            var query = PFQuery(className: self.classNameKey)
            query.whereKeyExists(self.placeColumnKey)
            query.whereKeyExists(self.voteColumnKey)
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                var pfobjects = objects as! [PFObject]
                for object in pfobjects {
                    var place = object[self.placeColumnKey] as! String
                    if place == self.eateries[indexPath.row] {
                        var voteCount = object[self.voteColumnKey] as! Int
                        voteCount++
                        object[self.voteColumnKey] = voteCount
                        object.saveInBackground()
                        self.votes[indexPath.row]++
                        self.updateTableView()
                    }
                }
            })
        }
        vote.backgroundColor = UIColor.blueColor()
        return [vote, delete]
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        self.eateries.removeAll(keepCapacity: true)
        self.votes.removeAll(keepCapacity: true)
        retrievePlaces()

        refreshControl.endRefreshing()
    }

    @IBAction func logoutButtonClick(sender: AnyObject) {
        PFUser.logOut()
        let currentUser = PFUser.currentUser()
        if currentUser == nil {
            self.performSegueWithIdentifier(logoutSegueIdentifier, sender: self)
        } else {
            println("Something went wrong logging out with user: \(currentUser)")
        }
    }

}
