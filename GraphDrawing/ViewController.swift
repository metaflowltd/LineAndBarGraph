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
    
    
    let weightData = [80.1, 77.3, 78.5, 84.7, 78.2, 79.9, 78.4, 76.8, 72.4]
    let carbData   = [52, 27, 56, 68, 39, 76, 53, 42, 32]
    
    let bgColor = UIColor(red: 232.0/255.0, green: 230.0/255.0, blue: 243.0/255.0, alpha: 1)
    let lineColor = UIColor(red: 88.0/255.0, green: 75.0/255.0, blue: 120.0/255.0, alpha: 1)
    
    var areaPath: UIBezierPath?
    var points:[CGPoint]?
    var halfPoints:[CGPoint]?
    
    var pointViews = [LinePointView]()
    var barViews = [BarView]()
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let pointsForGraph = self.makePointsFromDataForGraph(weightData)
        var pointsWithContainerPoints = pointsForGraph
        
        pointsWithContainerPoints.append(CGPointMake(self.graphView.bounds.width, self.graphView.bounds.height))
        pointsWithContainerPoints.append(CGPointMake(0, self.graphView.bounds.height))
        
        let linePath = self.generateAreaPath(points: pointsForGraph, shouldClosePath: false)
        let lineLayer = CAShapeLayer()
        lineLayer.lineJoin = kCALineJoinBevel
        lineLayer.lineWidth = 1.0
        lineLayer.path = linePath.CGPath
        lineLayer.strokeColor = lineColor.CGColor
        lineLayer.fillColor = UIColor.clearColor().CGColor
        self.graphView.layer.addSublayer(lineLayer)
        
        self.areaPath = self.generateAreaPath(points: pointsWithContainerPoints)
        let areaLayer = CAShapeLayer()
        areaLayer.lineJoin = kCALineJoinBevel
        areaLayer.fillColor = bgColor.CGColor
        areaLayer.path = areaPath!.CGPath
        self.graphView.layer.addSublayer(areaLayer)
        
        var pointsWithNoStartAndEnd = pointsForGraph
        pointsWithNoStartAndEnd.removeFirst()
        pointsWithNoStartAndEnd.removeLast()
        
        self.points = pointsWithNoStartAndEnd
        
        self.drawPointsOnGraph(pointsWithNoStartAndEnd)
        
        
        self.drawBottomBarGraph()
    }
    
    func drawBottomBarGraph(){
        self.bottomGraphView.backgroundColor = bgColor
        
        let totalWidth = Int(self.bottomGraphView.bounds.size.width)
        let totalHeight = Int(self.bottomGraphView.bounds.size.height)
        
        let segmentWidth = totalWidth / (self.carbData.count)
        
        for (var i = 0; i < self.carbData.count; i++){
            let val = carbData[i]
            let x = i * segmentWidth
            let heightOfBar = totalHeight * val / 100
            let y = totalHeight - heightOfBar
           let bar = BarView(frame: CGRect(x: x, y: y, width: segmentWidth, height: heightOfBar))
            bar.setUnSelected()
            bar.setXValue("\(i)")
            bar.setYValue("\(self.carbData[i])%")
            bar.setTopLineValue(BarSegmentedValue.makeFromValue(self.carbData[i]))
            
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
        let contains =  self.areaPath?.containsPoint(touchPoint)
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
                aView.setUnSelected()
            }
            self.pointViews[index!].setSelected()

            
            for aView in self.barViews{
                aView.setUnSelected()
            }
            self.barViews[index!].setSelected()
            
        }
        self.currentDataLabel.text = "\(self.weightData[index!])"
        
    }
    
    func generateAreaPath(points points: [CGPoint], shouldClosePath:Bool = true) -> UIBezierPath {
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
        if (shouldClosePath){
            progressline.closePath()
        }
        
        return progressline
    }
    
    func drawPointsOnGraph(points:[CGPoint]){
       
        for (var i = 0; i < points.count; i++) {
            let p = points[i]
            let pView = LinePointView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
            pView.center = p
            pView.setUnSelected()
            self.pointViews.append(pView)
            self.graphView.addSubview(pView)
        }
    }
    
    func makePointsFromDataForGraph(data:[Double]) -> [CGPoint]{
        let totalWidth = Double(self.graphView.bounds.size.width)
        let totalHeight = Double(self.graphView.bounds.size.height)
        
        let minElem = data.minElement()
        let maxElem = data.maxElement()
        let maxDelta = maxElem! - minElem!
        let stepHeight = totalHeight / (maxDelta)
        let segmentWidth = totalWidth / Double(data.count)
        var points = [CGPoint]()
//        self.halfPoints = [CGPoint]()
        let firstPoint = CGPoint(x: 0, y: (maxElem! - data[0] - 0.3) * stepHeight )
        points.append(firstPoint)
        for (var i = 0; i < data.count; i++){
            let y = (maxElem! - data[i]) * stepHeight
            
            let p2 = CGPoint(x: Double(i) * segmentWidth + (segmentWidth / 2) , y: y)
            points.append(p2)
        }
        
        let lastPoint = CGPoint(x: totalWidth, y: (maxElem! - data.last! - 0.2) * stepHeight )
        points.append(lastPoint)
        
        return points
    }
    
}

