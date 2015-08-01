//
//  TodaysLunchViewController.swift
//  Lunch
//
//  Created by Spencer Amann on 7/27/15.
//  Copyright (c) 2015 Spencer Amann. All rights reserved.
//

import UIKit
import Parse
import MapKit

class TodaysLunchViewController: UIViewController {

    @IBOutlet weak var selectedPlaceLabel: UILabel!
    @IBOutlet weak var selectedVotesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    var textForLunchLabel = ""
    var textForVotesLabel = ""
    var selectedIndex = -1

    let classNameKey = "Eateries"
    let placeColumnKey = "place"
    let voteColumnKey = "vote"

    override func viewDidLoad() {
        super.viewDidLoad()


        var address = textForLunchLabel
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]?, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                let location = placemark.location
                let cordinates = placemark.location.coordinate
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: cordinates, span: span)
                self.mapView.setRegion(region, animated: true)

                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
            }
        })
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        selectedPlaceLabel.text = textForLunchLabel
        selectedVotesLabel.text = "Votes: " + textForVotesLabel
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let vc = self.navigationController?.topViewController as? ViewController
        vc?.votes[selectedIndex] = textForVotesLabel.toInt()!
        vc?.updateTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }



    @IBAction func voteNavBarButtonClick(sender: AnyObject) {
        var query = PFQuery(className: self.classNameKey)
        query.whereKeyExists(self.placeColumnKey)
        query.whereKeyExists(self.voteColumnKey)
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
            var pfobjects = objects as! [PFObject]
            for object in pfobjects {
                var place = object[self.placeColumnKey] as! String
                if place == self.textForLunchLabel {
                    var voteCount = object[self.voteColumnKey] as! Int
                    voteCount++
                    object[self.voteColumnKey] = voteCount
                    object.saveInBackground()
                    self.textForVotesLabel = "\(voteCount)"
                    self.selectedVotesLabel.text = "Votes: " + self.textForVotesLabel
                }
            }
        })

    }
}
