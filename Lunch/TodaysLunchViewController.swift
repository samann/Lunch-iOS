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

    var currentObject: PFObject?
    var selectedIndex: Int?
    var selectedAnnotation: CustomPointAnnotation?
    var placesClient = GMSPlacesClient()
    var placeName: String?
    var voteCount: Int?

    let classNameKey = "Eateries"
    let placeColumnKey = "place"
    let voteColumnKey = "vote"
    let image = UIImage(named: "PlaceIcon")

    override func viewDidLoad() {
        super.viewDidLoad()
        if let object = currentObject {
            if let votes = object[self.voteColumnKey] as? Int, place = object[self.placeColumnKey] as? String {
                self.placeName = place
                self.voteCount = votes
                self.navigationItem.title = self.placeName
                self.selectedVotesLabel.text = "Votes: \(self.voteCount!)"
            }
        }

        self.mapView.zoomEnabled = true
        self.mapView.delegate = self

        placesClient.currentPlaceWithCallback({ (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) in
            if let error = error {
                return
            }

            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    let name = place.name
                    let location = place.coordinate
                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: location, span: span)
                    let request = MKLocalSearchRequest()
                    request.region = MKCoordinateRegion(center: location, span: span)
                    request.naturalLanguageQuery = self.placeName
                    let search = MKLocalSearch(request: request)
                    search.startWithCompletionHandler({ (response: MKLocalSearchResponse!, error: NSError?) in
                        if response != nil && error == nil {
                            let mapItems = response.mapItems as? [MKMapItem]
                            var annotationList = [MKPointAnnotation]()
                            for item in mapItems! {
                                let annotation = CustomPointAnnotation()
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
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let vc = self.navigationController?.topViewController as? LunchPFTableViewController
        vc?.loadObjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }

        let reuseId = "test"

        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView.canShowCallout = true
        } else {
            annotationView.annotation = annotation
        }

        annotationView.image = self.image

        return annotationView
    }

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if view.annotation is CustomPointAnnotation {
            var alertView = UIAlertController(title: "LunchPal", message: view.annotation.title!, preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "Navigation", style: .Default, handler: { (action) in
                let placemark = MKPlacemark(coordinate: view.annotation.coordinate, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                let launchItems = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                let currentLocation = MKMapItem.mapItemForCurrentLocation()
                MKMapItem.openMapsWithItems([currentLocation, mapItem], launchOptions: launchItems)
            }))
            alertView.addAction(UIAlertAction(title: "Call", style: .Default, handler: { (action) in
                if view.annotation.subtitle != nil {
                    if let phoneNumber = view.annotation.subtitle {
                        if phoneNumber == nil {
                            return
                        }
                        let regex = Regex(stringLiteral: "^[0-9]+$")
                        let numberToCall = phoneNumber.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "+( )-"))
                        if !numberToCall.isEmpty && numberToCall.match(regex) {
                            let application = UIApplication.sharedApplication()
                            let url = NSURL(string: "tel://\(numberToCall)")
                            application.openURL(url!)
                        }
                    }
                }
            }))
            alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alertView, animated: true, completion: nil)
            selectedAnnotation = view.annotation as? CustomPointAnnotation
        }
    }

    @IBAction func voteNavBarButtonTapped(sender: AnyObject) {
        let query = PFQuery(className: self.classNameKey)
        query.whereKeyExists(self.placeColumnKey)
        query.whereKeyExists(self.voteColumnKey)
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) in
            let pfobjects = objects as! [PFObject]
            for object in pfobjects {
                let place = object[self.placeColumnKey] as! String
                if place == self.placeName {
                    var voteCount = object[self.voteColumnKey] as! Int
                    voteCount++
                    object[self.voteColumnKey] = voteCount
                    object.saveInBackground()
                    self.selectedVotesLabel.text = "Votes: \(voteCount)"
                }
            }
        })
    }
}
