//
//  MonthCell.swift
//  Føtex Løn
//
//  Created by Martin Lok on 29/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit

class MonthCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.detailTextLabel?.frame.origin.x -= 10
    }

}
