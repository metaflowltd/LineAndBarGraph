//
//  BarView.swift
//  GraphDrawing
//
//  Created by Danny Shmueli on 15/03/2016.
//  Copyright © 2016 Metaflow. All rights reserved.
//

import UIKit

enum BarSegmentedValue {
    case Low
    case Mediuim
    case High
    
    static func makeFromValue(value:Int) -> BarSegmentedValue{
        switch value{
        case 0...20:
            return .Low
        case 21...45:
            return .Mediuim
        case 46...100:
            return .High
        default:
            return .High
        }
    }
    
}

class BarView: UIView {

    var valueLabel: UILabel!
    var xValueLabel: UILabel!
    var topBorder: UIView!

    
    func setSelected(){
        self.valueLabel.font = UIFont.boldSystemFontOfSize(13)
        self.xValueLabel.font = UIFont.boldSystemFontOfSize(13)
        self.valueLabel.textColor = UIColor.blackColor()
        self.xValueLabel.textColor = UIColor.blackColor()
    }
    
    func setUnSelected(){
        self.valueLabel.font = UIFont.systemFontOfSize(13)
        self.xValueLabel.font = UIFont.systemFontOfSize(13)
        self.valueLabel.textColor = UIColor.grayColor()
        self.xValueLabel.textColor = UIColor.grayColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        self.xValueLabel = UILabel(frame: CGRect(x: 0, y: self.bounds.height - 18, width: self.bounds.width, height: 14))
        self.xValueLabel.textAlignment = .Center
        self.addSubview(self.xValueLabel)
        
        self.valueLabel = UILabel(frame: CGRect(x: 0, y: 4, width: self.bounds.width, height:  14))
        valueLabel.textAlignment = .Center
        self.addSubview(self.valueLabel)
        
        self.topBorder = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 1))
        self.addSubview(self.topBorder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setXValue(text:String){
        self.xValueLabel.text = text
    }
    
    func setYValue(text:String){
        self.valueLabel.text = text
    }
    
    func setTopLineValue(val:BarSegmentedValue){
        var color:UIColor?
        
        switch (val){
        case .Low:
            color = UIColor.greenColor()
        case .Mediuim:
            color = UIColor.yellowColor()
        case .High:
            color = UIColor.redColor()
            
        }
        
        self.topBorder.backgroundColor = color!
        
    }

}
