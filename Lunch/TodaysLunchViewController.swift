//
//  TodaysLunchViewController.swift
//  Lunch
//
//  Created by Spencer Amann on 7/27/15.
//  Copyright (c) 2015 Spencer Amann. All rights reserved.
//

import UIKit

class TodaysLunchViewController: UIViewController {

    @IBOutlet weak var todaysLunchLabel: UILabel!
    
    var textForLunchLabel = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todaysLunchLabel.text = textForLunchLabel
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
