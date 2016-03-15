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
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var currentValueMantissaLabel: UILabel!
    
    
    let weightArray = [80.1, 77.3, 78.5, 84.7, 78.2, 79.9, 78.4, 76.8, 72.4]
    let carbArray   = [52, 27, 56, 68, 39, 76, 53, 42, 32]
    let dateArray   = ["20/3", "21/3", "22/3", "23/3", "24/3", "25/3", "26/3", "27/3", "28/3"]
    
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
        
        let pointsForGraph = self.makePointsFromDataForGraph(weightArray)
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
        
        self.selectXValueAtIndex(self.carbArray.count - 1 )
    }
    
    func drawBottomBarGraph(){
        self.bottomGraphView.backgroundColor = bgColor
        let totalWidth = Double(self.bottomGraphView.bounds.size.width)
        let totalHeight = Double(self.bottomGraphView.bounds.size.height)
        
        let segmentWidth = totalWidth / Double(self.carbArray.count)
        
        for (var i = 0; i < self.carbArray.count; i++){
            let val = carbArray[i]
            let x = Double(i) * segmentWidth
            let heightOfBar = totalHeight * Double(val) / 100.0
            let y = totalHeight - heightOfBar
           let bar = BarView(frame: CGRect(x: x, y: y, width: segmentWidth, height: heightOfBar))
            bar.setUnSelected()
            bar.setXValue("\(self.dateArray[i])")
            bar.setYValue("\(self.carbArray[i])%")
            bar.setTopLineValue(BarSegmentedValue.makeFromValue(self.carbArray[i]))
            
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
        let touchPointInGrpahView = (touches.first?.locationInView(self.graphView))!
        let containedInTopGraph =  self.areaPath?.containsPoint(touchPointInGrpahView)
        
        let touchPointInBottomGrpahView = (touches.first?.locationInView(self.bottomGraphView))!
        let containedInBottomGraph =  CGRectContainsPoint(bottomGraphView.bounds, touchPointInBottomGrpahView)
        
        if (containedInTopGraph == nil || !(containedInTopGraph!) && !containedInBottomGraph){
            return
        }
        
        var shortestDistance = CGFloat.max
        var foundPoint:CGPoint?
        for (var i = 0; i < self.points!.count; i++) {
            let p = points![i]
            let distance = abs(p.x - touchPointInGrpahView.x)
            if (distance < shortestDistance){
                shortestDistance = distance
                foundPoint = p
            }
        }
        
        let index = points!.indexOf(foundPoint!)
        
        if (index != nil){
            self.selectXValueAtIndex(index!)
        }
    }
    
    func selectXValueAtIndex(index:Int){
        for aView in self.pointViews{
            aView.setUnSelected()
        }
        self.pointViews[index].setSelected()
        
        
        for aView in self.barViews{
            aView.setUnSelected()
        }
        self.barViews[index].setSelected()
        let wieghtAtIndex = self.weightArray[index]
        
        self.currentValueLabel.text = "\(Int(wieghtAtIndex))"
        self.currentValueMantissaLabel.text = "\(getFractionPart(wieghtAtIndex))"
    }
    
    func getFractionPart(d:Double) -> String{
        var integer = 0.0
        let fraction = modf(d, &integer)
        let str = NSString(format: ".%1.0f", fraction * 10)
        return String(str)
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

