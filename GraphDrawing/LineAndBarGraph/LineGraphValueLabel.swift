//
//  LineGraphValueLabel.swift
//  GraphDrawing
//
//  Created by Danny Shmueli on 16/03/2016.
//  Copyright © 2016 Metaflow. All rights reserved.
//

import UIKit

class LineGraphValueLabel: UIView {

    private var valueLabel: UILabel!
    private var valueMantissaLabel: UILabel!
    private var valueUnitsLabel: UILabel!
    
    func setCurrentDisplayingValue(value:Double){
        self.valueLabel.text = "\(Int(value))"
        self.valueMantissaLabel.text = "\(getFractionPart(value))"
    }
    
    func setUnitText(unitText:String){
        self.valueUnitsLabel.text = unitText
    }
    
    init(frame: CGRect, textColor:UIColor, valueFont:UIFont, mantissaFont:UIFont, unitsFont:UIFont ) {
        super.init(frame: frame)
        
        self.valueLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 74, height: 57))
        self.addSubview(self.valueLabel)
        self.valueLabel.font = valueFont
        self.valueLabel.textAlignment = .Right
        
        self.valueMantissaLabel = UILabel(frame: CGRect(x: 78, y: 8, width: 11, height: 15))
        self.addSubview(self.valueMantissaLabel)
        self.valueMantissaLabel.font = mantissaFont
        
        self.valueUnitsLabel = UILabel(frame: CGRect(x: 78, y: 24, width: 17, height: 15))
        self.addSubview(self.valueUnitsLabel)
        self.valueUnitsLabel.font = unitsFont
        self.setUnitText("KG")
        
        self.valueLabel.textColor = textColor
        self.valueMantissaLabel.textColor = textColor
        self.valueUnitsLabel.textColor = textColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getFractionPart(d:Double) -> String{
        var integer = 0.0
        let fraction = modf(d, &integer)
        let str = NSString(format: ".%1.0f", fraction * 10)
        return String(str)
    }
    
}
