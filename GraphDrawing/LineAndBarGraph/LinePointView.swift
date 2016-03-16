//
//  LinePointView.swift
//  GraphDrawing
//
//  Created by Danny Shmueli on 15/03/2016.
//  Copyright © 2016 Metaflow. All rights reserved.
//

import UIKit

class LinePointView: UIView {

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
        self.selectedBG?.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        self.addSubview(self.selectedBG!)

        self.layer.masksToBounds = false
        self.clipsToBounds = false

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
