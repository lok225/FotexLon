//
//  StandardVagt.swift
//  Føtex Løn
//
//  Created by Martin Lok on 24/08/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit

class StandardVagt: NSObject, NSCoding {


    
    let kStandardStartTime = "standardStartTime"
    let kStandardEndTime = "standardEndTime"
    let kStandardPause = "standardPause"
    
    var startTime: Date!
    var endTime: Date!
    var pause: Int!
    
    init(startTime: Date, endTime: Date, pause: Int) {
        self.startTime = startTime
        self.endTime = endTime
        self.pause = pause
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        startTime = aDecoder.decodeObject(forKey: kStandardStartTime) as! Date
        endTime = aDecoder.decodeObject(forKey: kStandardEndTime) as! Date
        pause = aDecoder.decodeObject(forKey: kStandardPause) as! Int
        super.init()
    }
    
    // MARK: Coder
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(startTime, forKey: kStandardStartTime)
        aCoder.encode(endTime, forKey: kStandardEndTime)
        aCoder.encode(startTime, forKey: kStandardPause)
    }
    
    /// Bruges til notifikationer
    ///
    /// - returns: Returnerer en string udelukkende med start- og sluttidspunktet, som f.eks. '16.00-20-15'
    func getTimeIntervalString() -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateTemplate = "H:mm"
        
        return formatter.string(from: startTime, to: endTime)
    }
}
