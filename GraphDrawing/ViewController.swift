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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let data = [80, 77, 78, 84, 78, 79, 78, 76, 75]
        let points = self.makePointsFromData(data)
        
        self.drawLineBetweenManyPoints(points)
        
        self.drawPointsOnGraph(points)
    }
    
    func drawPointsOnGraph(points:[CGPoint]){
        for (var i = 0; i < points.count; i++) {
            let p = points[i]
            let pView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            pView.center = p
            
            pView.backgroundColor = UIColor.redColor()
            pView.layer.cornerRadius = 5
            
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
            
            let y = (data[i] * stepHeight) - (minElem! * stepHeight)
            let p2 = CGPoint(x: i * segmentWidth, y: y)
            points.append(p2)
        }

        return points
    }
    
    func makeGraphPath(points:[CGPoint]) -> UIBezierPath{
        let path = UIBezierPath()
        var lastPoint = points[0]
        for (var i = 0; i < points.count; i++){
            let aPoint = points[i]
            path.moveToPoint(lastPoint)
            path.addLineToPoint(aPoint)
            
            lastPoint = aPoint
        }
        return path
    }
    
    func drawLineBetweenManyPoints(points:[CGPoint]){
        let linePath = CGPathCreateMutable();
        let lineShape = CAShapeLayer();
        
        lineShape.lineWidth = 3;
        lineShape.lineCap = kCALineCapRound
        lineShape.lineJoin = kCALineJoinBevel
        
        lineShape.strokeColor = UIColor.blackColor().CGColor
        
        var lastPoint = points[0]
        for (var i = 0; i < points.count; i++){
            let aPoint = points[i]
            CGPathMoveToPoint(linePath, nil, lastPoint.x, lastPoint.y)
            CGPathAddLineToPoint(linePath, nil, aPoint.x, aPoint.y);
            lastPoint = aPoint
            
        }
        lineShape.path = linePath;
        
        self.graphView!.layer.addSublayer(lineShape)
    }
    
}

