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
    
    var areaPath: UIBezierPath?
    var points:[CGPoint]?
    var pointViews = [UIView]()
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let data = [80, 77, 78, 84, 78, 79, 78, 76, 75]
        
        self.points = self.makePointsFromData(data)
        var pointsWithContainerPoints = points!
        
        pointsWithContainerPoints.append(CGPointMake(self.graphView.bounds.width, self.graphView.bounds.height))
        pointsWithContainerPoints.append(CGPointMake(0, self.graphView.bounds.height))
        
        self.areaPath = self.generateAreaPath(points: pointsWithContainerPoints)
        let areaLayer = CAShapeLayer()
        areaLayer.lineJoin = kCALineJoinBevel
        areaLayer.fillColor = UIColor.blueColor().CGColor
        areaLayer.lineWidth = 1.0
        areaLayer.path = areaPath!.CGPath
        areaLayer.strokeColor = UIColor.grayColor().CGColor
        self.graphView.layer.addSublayer(areaLayer)
        
        self.drawPointsOnGraph(points!)
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
        }
        
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

