//
//  LinePointView.swift
//  GraphDrawing
//
//  Created by Danny Shmueli on 15/03/2016.
//  Copyright © 2016 Metaflow. All rights reserved.
//

import UIKit

class LinePointView: UIView {

    
    var selectedBGColor = UIColor(white: 0.3, alpha: 0.5)

    var selectedBG:UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setSelected(){
        self.selectedBG = UIView()
        self.selectedBG!.frame = CGRectInset(self.bounds, -9, -9)
        self.selectedBG!.layer.cornerRadius = self.selectedBG!.frame.width / 2
        self.selectedBG?.backgroundColor = self.selectedBGColor
        self.addSubview(self.selectedBG!)

        self.layer.masksToBounds = false
        self.clipsToBounds = false

        let inner = LinePointView(frame: self.bounds);
        inner.setUnSelected()
        inner.center = CGPoint(x: self.selectedBG!.bounds.width / 2, y: self.selectedBG!.bounds.height / 2)
        
        self.selectedBG?.addSubview(inner)
    }
    
    
    func setUnSelected(){
        self.selectedBG?.removeFromSuperview()
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = frame.width / 2
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
}
