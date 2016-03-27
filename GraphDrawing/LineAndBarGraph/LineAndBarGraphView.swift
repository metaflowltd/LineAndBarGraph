//
//  LineAndBarGraphView.swift
//  GraphDrawing
//
//  Created by Danny Shmueli on 16/03/2016.
//  Copyright © 2016 Metaflow. All rights reserved.
//

import UIKit

class LineAndBarGraphView: UIView {
    
    var lineGraphData = [80.1, 77.3, 78.5, 84.7, 78.2, 102.9, 78.4, 76.8, 72.4]
    var barGraphData = [52, 27, 56, 68, 39, 76, 53, 42, 32]
    var dateArray = ["20/3", "21/3", "22/3", "23/3", "24/3", "25/3", "26/3", "27/3", "28/3"]
    
    var bgColor = UIColor(red: 232.0/255.0, green: 230.0/255.0, blue: 243.0/255.0, alpha: 1)
    var lineColor = UIColor(red: 88.0/255.0, green: 75.0/255.0, blue: 120.0/255.0, alpha: 1)
    
    var selectedIndexBgColor = UIColor(white: 1, alpha: 0.3)
    var lineGraphSelectedPointBgColor = UIColor.grayColor()
    
    var shouldAnimateEnterance = true
    
    /// this is multiplied by the heigth of the top graph
    /// less than 1 will make smoother graph
    var smoothValue = 0.4
    
    var useScrolling = true
    var sizeOfSegmentWhenScroll = 54.0
    
    var lineGraphValueLabelColor = UIColor.blueColor(){
        didSet{
            self.lineGraphValueLabel.textColor = lineGraphValueLabelColor
        }
    }
    var barViewSelectedFont = UIFont.boldSystemFontOfSize(12)
    var barViewUnselectedFont = UIFont.systemFontOfSize(12)
    
    var valueLabelFont = UIFont.systemFontOfSize(44)
    var valueMantissaFont = UIFont.systemFontOfSize(12)
    var valueUnitsFont = UIFont.systemFontOfSize(12)
    
    private var totalWidthOfData:Double{
        return Double(self.barGraphData.count) * sizeOfSegmentWhenScroll
    }
    
    private var scrollView: UIScrollView!
    
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

    private var hasLoadedOnce = false

    //MARK: - Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        self.scrollView = UIScrollView(frame: self.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        scrollView.scrollEnabled = useScrolling
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("didTap:")))
        
        self.lineGraphWrapperView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 2))
        self.lineGraphView = UIView(frame: CGRect(x: 0, y: 14, width: lineGraphWrapperView.bounds.width, height: lineGraphWrapperView.bounds.height - 14))
        
        self.lineGraphWrapperView.addSubview(self.lineGraphView)
        self.topGraphFakeBarsWrapperView = UIView(frame: self.lineGraphView.frame)
        self.lineGraphWrapperView.addSubview(self.topGraphFakeBarsWrapperView)

        self.barGraphView = UIView(frame: CGRect(x: 0, y: frame.height / 2, width: frame.width, height: frame.height / 2))
        self.bottomGraphFakeBarsWrapperView = UIView(frame: self.barGraphView.frame)
        self.bottomGraphFakeBarsWrapperView.backgroundColor = bgColor

        scrollView.addSubview(self.bottomGraphFakeBarsWrapperView)
        scrollView.addSubview(self.barGraphView)
        scrollView.addSubview(self.lineGraphWrapperView)

        let lineGraphValueLabelHeight = 57.0
        let lineGraphValueLabelY = (Double(frame.height) / 2) - (lineGraphValueLabelHeight / 2)
        
        self.lineGraphValueLabel = LineGraphValueLabel(frame: CGRect(x: 8, y: lineGraphValueLabelY, width: 96, height: 57), textColor: self.lineGraphValueLabelColor, valueFont: self.valueLabelFont, mantissaFont: self.valueMantissaFont, unitsFont: self.valueUnitsFont)
        self.addSubview(self.lineGraphValueLabel)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.scrollView.frame = self.bounds
        
        let graphWidth = useScrolling ? CGFloat(self.totalWidthOfData) : frame.width
        self.lineGraphWrapperView.frame = CGRect(x: 0, y: 0, width: graphWidth, height: frame.height / 2)
        self.lineGraphView.frame = CGRect(x: 0, y: 14, width: lineGraphWrapperView.bounds.width, height: lineGraphWrapperView.bounds.height - 14)
        
        self.topGraphFakeBarsWrapperView.frame = self.lineGraphView.frame
        
        
        self.barGraphView.frame = CGRect(x: 0, y: frame.height / 2, width: graphWidth, height: frame.height / 2)
        self.bottomGraphFakeBarsWrapperView.frame = self.barGraphView.frame
        
        let lineGraphValueLabelHeight = 57.0
        let lineGraphValueLabelY = (Double(self.frame.height) / 2) - (lineGraphValueLabelHeight / 2)

        self.lineGraphValueLabel.frame = CGRect(x: 8, y: lineGraphValueLabelY, width: 96, height: 57)

        
        if (hasLoadedOnce){
            self.cleanGraph()
            self.loadGraphFromPoints()
        }
    }
    
    //MARK: - API
    func scrollToLast(){
        self.scrollView.setContentOffset(CGPoint(x: self.totalWidthOfData-10, y: 0), animated: false)
    }
    
    func loadGraphFromPoints() {
        if (!self.validateGraphData()){
            return
        }

        self.drawTopGraph()
        
        self.drawBottomBarGraph()
        
        self.selectXValueAtIndex(self.barGraphData.count - 1 )
        
        self.hasLoadedOnce = true
        
        self.scrollView.contentSize = CGSize(width: self.totalWidthOfData, height: Double(self.bounds.height))
        
        if (self.shouldAnimateEnterance){
            let maskLayer = CAGradientLayer()
            maskLayer.anchorPoint = CGPointZero
            
            let colors = [
                UIColor(white: 0, alpha: 0).CGColor,
                UIColor(white: 0, alpha: 1).CGColor]
            maskLayer.colors = colors
            maskLayer.bounds = CGRectMake(0, 0, 0, self.layer.bounds.size.height)
            maskLayer.startPoint = CGPointMake(1, 0)
            maskLayer.endPoint = CGPointMake(0, 0)
            self.layer.mask = maskLayer
            
            let revealAnimation = CABasicAnimation(keyPath: "bounds")
            revealAnimation.fromValue = NSValue(CGRect: CGRectMake(0, 0, 0, self.layer.bounds.size.height))
            
            let target = CGRectMake(self.layer.bounds.origin.x, self.layer.bounds.origin.y, self.layer.bounds.size.width + 2000, self.layer.bounds.size.height);
            
            revealAnimation.toValue = NSValue(CGRect: target)
            revealAnimation.duration = CFTimeInterval(1.5)
            
            revealAnimation.removedOnCompletion = false
            revealAnimation.fillMode = kCAFillModeForwards
            
            revealAnimation.beginTime = CACurrentMediaTime() //+ CFTimeInterval(0.9)
            self.layer.mask?.addAnimation(revealAnimation, forKey: "revealAnimation")
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
    
    //MARK: - Touches
    @objc private func didTap(gesture:UITapGestureRecognizer){
        let touchPointInGrpahView =  gesture.locationInView(scrollView)
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

    //MARK:- Private
    func validateGraphData() -> Bool{
        if (self.lineGraphData.count == 0 ||
            self.barGraphData.count == 0 ||
            self.dateArray.count == 0){
            
            return false
        }
        if (self.lineGraphData.count != self.barGraphData.count){
            return false
        }
        if (self.lineGraphData.count != self.dateArray.count){
            return false
        }
        return true
        
    }

    
    private func cleanGraph(){
        for b in self.barViews{
            b.removeFromSuperview()
        }
        self.barViews = [BarView]()
        for b in self.bottomGraphFakeBarsViews{
            b.removeFromSuperview()
        }
        self.bottomGraphFakeBarsViews = [UIView]()
        
        for b in self.topGraphFakeBarsViews{
            b.removeFromSuperview()
        }
        self.topGraphFakeBarsViews = [UIView]()
        
        self.lineGraphView.layer.sublayers = nil

        for p in self.pointViews{
            p.removeFromSuperview()
        }
        self.pointViews = [LinePointView]()
        
        
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
        
        let totalWidth = Double(self.topGraphFakeBarsWrapperView.bounds.size.width)
        let height = Double(self.topGraphFakeBarsWrapperView.bounds.size.height)
        let segmentWidth = useScrolling ? sizeOfSegmentWhenScroll : totalWidth / Double(self.lineGraphData.count)
        
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
        
        let totalWidth = Double(self.barGraphView.bounds.size.width)
        let totalHeight = Double(self.barGraphView.bounds.size.height)
        
        let segmentWidth = useScrolling ? sizeOfSegmentWhenScroll : totalWidth / Double(self.barGraphData.count)
        
        for (var i = 0; i < self.barGraphData.count; i++){
            let val = barGraphData[i]
            let x = Double(i) * segmentWidth
            let heightOfBar = totalHeight * Double(val) * 0.9 / 100.0
            let y = totalHeight - heightOfBar - 30
            let bar = BarView(frame: CGRect(x: x, y: y, width: segmentWidth, height: heightOfBar + 30))
            bar.selectedFont = self.barViewSelectedFont
            bar.unselectedFont = self.barViewUnselectedFont
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
    
    //MARK: - UI Makers
    
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
            let p1 = self.lineGraphWrapperView.convertPoint(p, fromView: self.lineGraphView)
            let pView = LinePointView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
            pView.selectedBGColor = lineGraphSelectedPointBgColor
            pView.center = p1
            pView.setUnSelected()
            self.pointViews.append(pView)
            self.lineGraphWrapperView.addSubview(pView)
        }
    }
    
    func makePointsFromDataForGraph(data:[Double]) -> [CGPoint]{
        let totalWidth = Double(self.lineGraphView.bounds.size.width)
        let totalHeight = Double(self.lineGraphView.bounds.size.height) * smoothValue
        
        let minElem = data.minElement()
        let maxElem = data.maxElement()
        var maxDelta = maxElem! - minElem!
        if (maxDelta == 0 ){
            maxDelta = 1
        }
        let stepHeight = totalHeight / (maxDelta)
        let segmentWidth = useScrolling ? sizeOfSegmentWhenScroll : totalWidth / Double(data.count)
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
