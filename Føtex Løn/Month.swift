//
//  Month.swift
//  Føtex Løn
//
//  Created by Martin Lok on 03/08/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import CoreData

class Month: NSObject {

//    var fetchedRC: NSFetchedResultsController<NSFetchRequestResult>!
    var monthNumber: Double!
    
    var thisMonthIndex: Int!
    var months: [[Vagt]]!
    
//    init(fetchedRC: NSFetchedResultsController<NSFetchRequestResult>, monthNumber: Double) {
//        super.init()
//        
//        self.fetchedRC = fetchedRC
//        self.monthNumber = monthNumber
//        setThisMonthIndex()
//    }
    
    init(months: [[Vagt]], monthNumber: Double) {
        super.init()
        self.months = months
        self.monthNumber = monthNumber
    }
    
    
    func setThisMonthIndex() {
        
        guard let sections = months else {
            return
        }
        
        let thisMonthNumber = Date().getMonthNumber(withYear: true)
        thisMonthIndex = 0
        
        for section in sections {
            let vagt = section[0]
            
            if thisMonthNumber != vagt.monthNumber {
                thisMonthIndex! += 1
            } else {
                break
            }
        }
    }
    
    func calculateTotalLøn() -> Double {
        
        var løn = 0.0
        
        for vagt in months[thisMonthIndex] {
            let vagtLøn = vagt.samletLon
            løn += vagtLøn
        }
        
        return løn
    }
    
    func calculateAntalTimer() -> Double {
        var tid = 0.0
        
        for vagt in months[thisMonthIndex] {
            let vagtTid = vagt.vagtITimer
            tid += vagtTid
        }
        
        return tid
    }
    
    func calculateSatser() -> Double {
        var satser = 0.0
        
        for vagt in months[thisMonthIndex] {
            let vagtSats = vagt.satser
            satser += vagtSats
        }
        
        return satser
    }
    
    func calculateAntalVagter() -> Int {
        
        return months[thisMonthIndex].count
    }
    
    
//    func setThisMonthIndex() {
//        
//        guard let sections = fetchedRC.sections else {
//            return
//        }
//        
//        let thisMonthNumber = Date().getMonthNumber(withYear: true)
//        thisMonthIndex = 0
//        
//        for section in sections {
//            let vagt = section.objects?[0] as! Vagt
//            
//            if thisMonthNumber != vagt.monthNumber {
//                thisMonthIndex! += 1
//            } else {
//                break
//            }
//        }
//    }
//    
//    func calculateTotalLøn() -> Double {
//        
//        var løn = 0.0
//        
//        for vagt in fetchedRC.sections![thisMonthIndex].objects as! [Vagt] {
//            let vagtLøn = vagt.samletLon
//            løn += vagtLøn
//        }
//        
//        return løn
//    }
//    
//    func calculateAntalTimer() -> Double {
//        var tid = 0.0
//        
//        for vagt in fetchedRC.sections![thisMonthIndex].objects as! [Vagt] {
//            let vagtTid = vagt.vagtITimer
//            tid += vagtTid
//        }
//        
//        return tid
//    }
//    
//    func calculateSatser() -> Double {
//        var satser = 0.0
//        
//        for vagt in fetchedRC.sections![thisMonthIndex].objects as! [Vagt] {
//            let vagtSats = vagt.satser
//            satser += vagtSats
//        }
//        
//        return satser
//    }
//    
//    func calculateAntalVagter() -> Int {
//        
//        return fetchedRC.sections!.count
//    }
}















