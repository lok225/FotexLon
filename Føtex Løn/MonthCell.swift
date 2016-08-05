//
//  MonthCell.swift
//  Føtex Løn
//
//  Created by Martin Lok on 29/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import QuartzCore

class MonthCell: UITableViewCell {
    
    let gradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.detailTextLabel?.frame.origin.x -= 10
        
        // Nedenstående virker ikke i landscape
        
//        self.accessoryView?.frame.size.height = (self.accessoryView?.frame.size.height)! / 3 * 2.3
//        self.accessoryView?.frame.size.width = (self.accessoryView?.frame.size.width)! / 3 * 2.3
//        
//        self.accessoryView?.frame.origin.y = (44 - (self.accessoryView?.frame.size.height)!) / 2
//        let thisX = self.accessoryView?.frame.origin.x
//        let screenWidth = super.window?.frame.size.width
//        self.accessoryView?.frame.origin.x = thisX! + ((screenWidth! - thisX!) / 4)
        
    }

}
