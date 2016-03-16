//
//  ViewController.swift
//  GraphDrawing
//
//  Created by Danny Shmueli on 13/03/2016.
//  Copyright © 2016 Metaflow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var graphWrapperView: UIView!
    
    
    let weightArray = [80.1, 77.3, 78.5, 84.7, 78.2, 79.9, 78.4, 76.8, 72.4, 74.9]
    let carbArray   = [52, 27, 56, 68, 39, 76, 53, 42, 32, 53]
    let dateArray   = ["20/3", "21/3", "22/3", "23/3", "24/3", "25/3", "26/3", "27/3", "28/3", "29/3"]
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let graphView = LineAndBarGraphView(frame: self.graphWrapperView.bounds)
        graphView.lineGraphData = weightArray
        graphView.barGraphData = carbArray
        graphView.dateArray = dateArray
        
        graphView.loadGraphFromPoints()
        self.graphWrapperView.addSubview(graphView)
    }
    
}

