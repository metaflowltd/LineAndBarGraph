//
//  LineAndBarGraphView.swift
//  GraphDrawing
//
//  Created by Danny Shmueli on 16/03/2016.
//  Copyright © 2016 Metaflow. All rights reserved.
//

import UIKit

class LineAndBarGraphView: UIView {
    
    var bgColor = UIColor(red: 232.0/255.0, green: 230.0/255.0, blue: 243.0/255.0, alpha: 1)
    var lineColor = UIColor(red: 88.0/255.0, green: 75.0/255.0, blue: 120.0/255.0, alpha: 1)
    var selectedIndexBgColor = UIColor(white: 1, alpha: 0.3)
    
    var lineGraphData = [80.1, 77.3, 78.5, 84.7, 78.2, 102.9, 78.4, 76.8, 72.4]
    var barGraphData = [52, 27, 56, 68, 39, 76, 53, 42, 32]
    var dateArray = ["20/3", "21/3", "22/3", "23/3", "24/3", "25/3", "26/3", "27/3", "28/3"]

    private var lineGraphWrapperView: UIView!
    private var lineGraphView: UIView!
    
    private var barGraphView: UIView!
    private var lineGraphValueLabel:LineGraphValueLabel!
    
    private var areaPath: UIBezierPath?
    private var points:[CGPoint]?
    
    private var pointViews = [LinePointView]()
    private var barViews = [BarView]()

    private var topGraphFakeBarsWrapperView:UIView!
    private var topGraphFakeBarsViews = [UIView]()
    private var bottomGraphFakeBarsWrapperView:UIView!
    private var bottomGraphFakeBarsViews = [UIView]()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        self.lineGraphWrapperView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 2))
        self.lineGraphView = UIView(frame: self.lineGraphWrapperView.bounds)
        self.lineGraphWrapperView.addSubview(self.lineGraphView)
        self.topGraphFakeBarsWrapperView = UIView(frame: self.lineGraphView.bounds)
        self.lineGraphWrapperView.addSubview(self.topGraphFakeBarsWrapperView)

        self.barGraphView = UIView(frame: CGRect(x: 0, y: frame.height / 2, width: frame.width, height: frame.height / 2))
        
        self.bottomGraphFakeBarsWrapperView = UIView(frame: self.barGraphView.frame)
        self.bottomGraphFakeBarsWrapperView.backgroundColor = bgColor

        self.addSubview(self.bottomGraphFakeBarsWrapperView)
        self.addSubview(self.barGraphView)
        self.addSubview(self.lineGraphWrapperView)

        let lineGraphValueLabelHeight = 57.0
        let lineGraphValueLabelY = (Double(frame.height) / 2) - (lineGraphValueLabelHeight / 2)
        self.lineGraphValueLabel = LineGraphValueLabel(frame: CGRect(x: 8, y: lineGraphValueLabelY, width: 96, height: 57), textColor: self.lineColor)
        self.addSubview(self.lineGraphValueLabel)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func loadGraphFromPoints() {
        self.drawTopGraph()
        
        self.drawBottomBarGraph()
        
        self.selectXValueAtIndex(self.barGraphData.count - 1 )
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

        for aView in self.topGraphFakeBarsViews{
            aView.backgroundColor = UIColor.clearColor()
        }
        self.self.topGraphFakeBarsViews[index].backgroundColor = selectedIndexBgColor
        
        for aView in self.bottomGraphFakeBarsViews{
            aView.backgroundColor = UIColor.clearColor()
        }
        self.self.bottomGraphFakeBarsViews[index].backgroundColor = selectedIndexBgColor
        
        
        self.lineGraphValueLabel.setCurrentDisplayingValue(self.lineGraphData[index])
    }
    
    private func drawTopGraph(){
        let pointsForGraph = self.makePointsFromDataForGraph(lineGraphData)
        var pointsWithContainerPoints = pointsForGraph
        
        let lineGraphViewBounds = self.lineGraphView.bounds
        pointsWithContainerPoints.append(CGPointMake(lineGraphViewBounds.width, lineGraphViewBounds.height))
        pointsWithContainerPoints.append(CGPointMake(0, lineGraphViewBounds.height))
        
        let linePath = self.generateAreaPath(points: pointsForGraph, shouldClosePath: false)
        let lineLayer = CAShapeLayer()
        lineLayer.lineJoin = kCALineJoinBevel
        lineLayer.lineWidth = 2.0
        lineLayer.path = linePath.CGPath
        lineLayer.strokeColor = lineColor.CGColor
        lineLayer.fillColor = UIColor.clearColor().CGColor
        self.lineGraphView.layer.addSublayer(lineLayer)

        self.areaPath = self.generateAreaPath(points: pointsWithContainerPoints)
        let areaLayer = CAShapeLayer()
        areaLayer.lineJoin = kCALineJoinBevel
        areaLayer.fillColor = bgColor.CGColor
        areaLayer.path = areaPath!.CGPath
        self.lineGraphView.layer.addSublayer(areaLayer)
        
        var pointsWithNoStartAndEnd = pointsForGraph
        pointsWithNoStartAndEnd.removeFirst()
        pointsWithNoStartAndEnd.removeLast()
        
        self.points = pointsWithNoStartAndEnd
        
        let totalWidth = Double(self.lineGraphWrapperView.bounds.size.width)
        let height = Double(self.lineGraphWrapperView.bounds.size.height)
        let segmentWidth = totalWidth / Double(self.lineGraphData.count)
        
        for (var i = 0; i < self.lineGraphData.count; i++){
            let x = Double(i) * segmentWidth
            let bar = UIView(frame: CGRect(x: x, y: 0, width: segmentWidth, height: height))
            self.topGraphFakeBarsViews.append(bar)
            self.topGraphFakeBarsWrapperView.addSubview(bar)
        }
        let areaLayerCopy = CAShapeLayer()
        areaLayerCopy.lineJoin = kCALineJoinBevel
        areaLayerCopy.path = areaPath!.CGPath
        self.topGraphFakeBarsWrapperView.layer.mask = areaLayerCopy
        
        self.drawPointsOnGraph(self.points!)
    }
    
    private func drawBottomBarGraph(){
//        self.barGraphView.backgroundColor = bgColor
        let totalWidth = Double(self.barGraphView.bounds.size.width)
        let totalHeight = Double(self.barGraphView.bounds.size.height)
        
        let segmentWidth = totalWidth / Double(self.barGraphData.count)
        
        for (var i = 0; i < self.barGraphData.count; i++){
            let val = barGraphData[i]
            let x = Double(i) * segmentWidth
            let heightOfBar = totalHeight * Double(val) / 100.0
            let y = totalHeight - heightOfBar
            let bar = BarView(frame: CGRect(x: x, y: y, width: segmentWidth, height: heightOfBar))
            bar.setUnSelected()
            bar.setXValue("\(self.dateArray[i])")
            bar.setYValue("\(val)%")
            bar.setTopLineValue(BarSegmentedValue.makeFromValue(val))
            
            self.barViews.append(bar)
            self.barGraphView.addSubview(bar)
            
            let fakeBar = UIView(frame: CGRect(x: x, y: 0, width: segmentWidth, height: totalHeight))
            self.bottomGraphFakeBarsViews.append(fakeBar)
            self.bottomGraphFakeBarsWrapperView.addSubview(fakeBar)
        }
        
    }
    //MARK: - Touches
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selectAtTouchPoint(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selectAtTouchPoint(touches)
    }
    
    private func selectAtTouchPoint(touches: Set<UITouch>){
        let touchPointInGrpahView = (touches.first?.locationInView(self.lineGraphView))!
        let containedInTopGraph =  self.areaPath?.containsPoint(touchPointInGrpahView)
        
        let touchPointInBottomGrpahView = (touches.first?.locationInView(self.barGraphView))!
        let containedInBottomGraph =  CGRectContainsPoint(barGraphView.bounds, touchPointInBottomGrpahView)
        
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
    
    private func generateAreaPath(points points: [CGPoint], shouldClosePath:Bool = true) -> UIBezierPath {
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
            self.lineGraphWrapperView.addSubview(pView)
        }
    }
    
    func makePointsFromDataForGraph(data:[Double]) -> [CGPoint]{
        let totalWidth = Double(self.lineGraphView.bounds.size.width)
        let totalHeight = Double(self.lineGraphView.bounds.size.height)
        
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
