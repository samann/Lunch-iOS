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
import GoogleMaps

class TodaysLunchViewController: UIViewController, MKMapViewDelegate {

    class CustomPointAnnotation: MKPointAnnotation {
    }

    @IBOutlet weak var selectedVotesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    var textForLunchLabel = ""
    var textForVotesLabel = ""
    var selectedIndex: Int?
    var placesClient = GMSPlacesClient()

    let classNameKey = "Eateries"
    let placeColumnKey = "place"
    let voteColumnKey = "vote"
    let image = UIImage(named: "PlaceIcon")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = textForLunchLabel

        self.mapView.zoomEnabled = true
        self.mapView.delegate = self

        placesClient.currentPlaceWithCallback({ (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) in
            if let error = error {
                println("Pick Place error: \(error.localizedDescription)")
                return
            }

            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    var name = place.name
                    var location = place.coordinate
                    let span = MKCoordinateSpanMake(0.05, 0.05)
                    let region = MKCoordinateRegion(center: location, span: span)
                    var request = MKLocalSearchRequest()
                    request.region = MKCoordinateRegion(center: location, span: span)
                    request.naturalLanguageQuery = self.textForLunchLabel
                    var search = MKLocalSearch(request: request)
                    search.startWithCompletionHandler({ (response: MKLocalSearchResponse!, error: NSError?) in
                        if response != nil && error == nil {
                            var mapItems = response.mapItems as? [MKMapItem]
                            var annotationList = [MKPointAnnotation]()
                            for item in mapItems! {
                                println("name \(item.name)")
                                var annotation = CustomPointAnnotation()
                                annotation.coordinate = item.placemark.coordinate
                                annotation.title = item.name
                                annotation.subtitle = item.phoneNumber
                                annotationList.append(annotation)
                                self.mapView.addAnnotation(annotation)
                            }
                            self.mapView.showAnnotations(
                            annotationList, animated: true)
                        }

                    })
                }
            }
        })
    }

    override func viewDidLayoutSubviews() {

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        selectedPlaceLabel.text = textForLunchLabel
        selectedVotesLabel.text = "Votes: " + textForVotesLabel
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let vc = self.navigationController?.topViewController as? ViewController
        vc?.votes[selectedIndex!] = textForVotesLabel.toInt()!
        vc?.updateTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }

        let reuseId = "test"

        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView.canShowCallout = true
        }
        else {
            anView.annotation = annotation
        }

        let cpa = annotation as! CustomPointAnnotation
        anView.image = self.image

        return anView
    }

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if view.annotation is CustomPointAnnotation {
            if let phoneNumber = view.annotation.subtitle {
                let regex = Regex(stringLiteral: "[0-9]*")
                if !phoneNumber.isEmpty && phoneNumber.match(regex) {
                    var application = UIApplication.sharedApplication()
                    var url = NSURL(string: "telprompt://\(phoneNumber!)")
                    application.openURL(url!)
                }
            }
        }
    }

    @IBAction func voteNavBarButtonClick(sender: AnyObject) {
        var query = PFQuery(className: self.classNameKey)
        query.whereKeyExists(self.placeColumnKey)
        query.whereKeyExists(self.voteColumnKey)
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) in
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