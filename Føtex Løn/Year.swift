//
//  Year.swift
//  Føtex Løn
//
//  Created by Martin Lok on 23/08/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit

class Year: NSObject {

    var months = [Month]()
    
    init(months: [Month]) {
        super.init()
        
        self.months = months
    }
    
    func calculateTotalLøn() -> Int {
        
        var løn = 0
        
        for month in months {
            løn += month.calculateTotalLøn()
        }
        
        return løn
    }
    
    func getYearString() -> String {
        
        return months.first!.getYearString()
    }
    
}
