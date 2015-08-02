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
        var imageName: String!
    }

    @IBOutlet weak var selectedPlaceLabel: UILabel!
    @IBOutlet weak var selectedVotesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    var textForLunchLabel = ""
    var textForVotesLabel = ""
    var selectedIndex = -1
    var placesClient: GMSPlacesClient?

    let classNameKey = "Eateries"
    let placeColumnKey = "place"
    let voteColumnKey = "vote"
    let image = UIImage(contentsOfFile: "lunch.png")

    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient()

        self.mapView.zoomEnabled = true
        self.mapView.delegate = self

        placesClient?.currentPlaceWithCallback({ (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if let error = error {
                println("Pick Place error: \(error.localizedDescription)")
                return
            }

            if let placeLicklihoodList = placeLikelihoodList {
                let place = placeLicklihoodList.likelihoods.first?.place
                if let place = place {
                    var name = place.name
                    var location = place.coordinate
                    let span = MKCoordinateSpanMake(0.05, 0.05)
                    let region = MKCoordinateRegion(center: location, span: span)
                    var request = MKLocalSearchRequest()
                    request.region = MKCoordinateRegion(center: location, span: span)
                    request.naturalLanguageQuery = self.textForLunchLabel
                    var search = MKLocalSearch(request: request)
                    search.startWithCompletionHandler({ (response: MKLocalSearchResponse!, error: NSError?) -> Void in
                        if response != nil && error == nil {
                            var mapItems = response.mapItems as? [MKMapItem]
                            var annotationList = [MKPointAnnotation]()
                            for item in mapItems! {
                                println("name \(item.name)")
                                var annotation = CustomPointAnnotation()
                                annotation.coordinate = item.placemark.coordinate
                                annotation.title = item.name
                                annotation.subtitle = item.phoneNumber
                                annotation.imageName = "rsz_lunch.png"
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
        anView.image = UIImage(named:cpa.imageName)

        return anView
    }

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let phoneNumber = view.annotation.subtitle {
            var application = UIApplication.sharedApplication()
            var url = NSURL(string: "telprompt://\(phoneNumber!)")
            application.openURL(url!)
        }
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