//
//  ViewController.swift
//  GraphDrawing
//
//  Created by Danny Shmueli on 13/03/2016.
//  Copyright © 2016 Metaflow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var bottomGraphView: UIView!
    @IBOutlet weak var currentDataLabel: UILabel!
    
    
    let weightData = [80, 77, 78, 84, 78, 79, 78, 76, 75]
    let carbData   = [52, 27, 56, 68, 39, 76, 53, 42, 32]
    
    var areaPath: UIBezierPath?
    var points:[CGPoint]?
    var pointViews = [UIView]()
    var barViews = [UIView]()
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let bgColor = UIColor.blueColor()
        
        self.points = self.makePointsFromData(weightData)
        var pointsWithContainerPoints = points!
        
        pointsWithContainerPoints.append(CGPointMake(self.graphView.bounds.width, self.graphView.bounds.height))
        pointsWithContainerPoints.append(CGPointMake(0, self.graphView.bounds.height))
        
        self.areaPath = self.generateAreaPath(points: pointsWithContainerPoints)
        let areaLayer = CAShapeLayer()
        areaLayer.lineJoin = kCALineJoinBevel
        areaLayer.fillColor = bgColor.CGColor
        areaLayer.lineWidth = 1.0
        areaLayer.path = areaPath!.CGPath
        areaLayer.strokeColor = UIColor.grayColor().CGColor
        self.graphView.layer.addSublayer(areaLayer)
        
        self.drawPointsOnGraph(points!)
        
        
        
        
        
        
        self.bottomGraphView.backgroundColor = bgColor
        
        let totalWidth = Int(self.bottomGraphView.bounds.size.width)
        let totalHeight = Int(self.bottomGraphView.bounds.size.height)
//        let topPadding = 8
        
        let segmentWidth = totalWidth / (self.carbData.count)
        
        for (var i = 0; i < self.carbData.count; i++){
            let val = carbData[i]
            let x = i * segmentWidth
            let heightOfBar = totalHeight * val / 100
            let y = totalHeight - heightOfBar
           let bar = UIView(frame: CGRect(x: x, y: y, width: segmentWidth, height: heightOfBar))
            bar.backgroundColor = UIColor.grayColor()
            let dateLabel = UILabel(frame: CGRect(x: 0, y: bar.bounds.height - 40, width: bar.bounds.width, height: 40))
            dateLabel.text = "\(i)"
            dateLabel.textAlignment = .Center
            bar.addSubview(dateLabel)
            self.barViews.append(bar)
            self.bottomGraphView.addSubview(bar)
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selectAtTouchPoint(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selectAtTouchPoint(touches)
    }
    
    func selectAtTouchPoint(touches: Set<UITouch>){
        let touchPoint = (touches.first?.locationInView(self.graphView))!
        let contains = self.areaPath?.containsPoint(touchPoint)
        if (contains == nil || !(contains!)){
            return
        }
        
        var shortestDistance = CGFloat.max
        var foundPoint:CGPoint?
        for (var i = 0; i < self.points!.count; i++) {
            let p = points![i]
            let distance = abs(p.x - touchPoint.x)
            if (distance < shortestDistance){
                shortestDistance = distance
                foundPoint = p
            }
        }
        
        let index = points!.indexOf(foundPoint!)
        
        if (index != nil){
            for aView in self.pointViews{
                aView.backgroundColor = UIColor.redColor()
            }
            let selectedView = self.pointViews[index!]
            selectedView.backgroundColor = UIColor.yellowColor()
            
            for aView in self.barViews{
                aView.backgroundColor = UIColor.grayColor()
            }
            let selectedBarView = self.barViews[index!]
            selectedBarView.backgroundColor = UIColor.yellowColor()
        }
        self.currentDataLabel.text = "\(self.weightData[index!])"
        
    }
    
    func generateAreaPath(points points: [CGPoint]) -> UIBezierPath {
        let progressline = UIBezierPath()
        progressline.lineWidth = 1.0
        progressline.lineCapStyle = .Round
        progressline.lineJoinStyle = .Round
        if let p = points.first {
            progressline.moveToPoint(p)
        }
        
        for i in 1..<points.count {
            let p = points[i]
            progressline.addLineToPoint(p)
        }
        
        progressline.closePath()
        
        return progressline
    }
    
    func drawPointsOnGraph(points:[CGPoint]){
        for (var i = 0; i < points.count; i++) {
            let p = points[i]
            let pView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            pView.center = p
            
            pView.backgroundColor = UIColor.redColor()
            pView.layer.cornerRadius = 5
            self.pointViews.append(pView)
            self.graphView.addSubview(pView)
        }
    }
    
    func makePointsFromData(data:[Int]) -> [CGPoint]{
        let totalWidth = Int(self.graphView.bounds.size.width)
        let totalHeight = Int(self.graphView.bounds.size.height)
        
        let minElem = data.minElement()
        let maxElem = data.maxElement()
        let maxDelta = maxElem! - minElem!
        let stepHeight = totalHeight / (maxDelta)
        let segmentWidth = totalWidth / (data.count - 1)
        var points = [CGPoint]()
        for (var i = 0; i < data.count; i++){
            let y = (maxElem! - data[i]) * stepHeight
            let p2 = CGPoint(x: i * segmentWidth, y: y)
            points.append(p2)
        }
        return points
    }
    
}

