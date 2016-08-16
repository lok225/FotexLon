//
//  Vagt+CoreDataClass.swift
//  Føtex Løn
//
//  Created by Martin Lok on 07/08/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import Foundation
import CoreData


public class Vagt: NSManagedObject {

    var satser = 0.0
    
    let myCalendar: Calendar = Calendar.current
    
    private let lordagSatsTid = 15 * 60
    private let hverdagSatsTid = 18 * 60
    
    // MARK: Computed Variables
    
    var vagtIMinMedPause: Int {
        
        return startTime.differenceInMins(withDate: endTime)
    }
    
    var vagtIMin: Double {
        
        return Double(vagtIMinMedPause - pause)
    }
    
    var vagtITimer: Double {
        
        return Double(vagtIMin / 60)
    }
    
    var samletLon: Double {
        
        return calculateTotalLon()
    }
    
    
    
    private func calculateTotalLon() -> Double {
        
        let defaults = UserDefaults.standard
        
        let isYoungWorker: Bool = defaults.bool(forKey: kYoungWorker)
        
        let basisLon: Double = isYoungWorker ? defaults.double(forKey: kYoungBasisLon) : defaults.double(forKey: kOldBasisLon)
        let aftenSats: Double = isYoungWorker ? defaults.double(forKey: kYoungAftensSats) : defaults.double(forKey: kOldAftensSats)
        let lordagsSats: Double = isYoungWorker ? defaults.double(forKey: kYoungLordagsSats) : defaults.double(forKey: kOldLordagsSats)
        let sondagsSats: Double = isYoungWorker ? defaults.double(forKey: kYoungSondagsSats) : defaults.double(forKey: kOldSondagsSats)
        
        let weekDayComponent = Calendar.current.component(.weekday, from: startTime)
        
        let endHour = myCalendar.component(.hour, from: endTime)
        let endMinute = myCalendar.component(.minute, from: endTime)
        
        let endTid = (endHour * 60) + endMinute
        
        let tillægDage: [Double] = [sondagsSats, aftenSats, aftenSats, aftenSats, aftenSats, aftenSats, lordagsSats]
        
        // Set satstid (Antal min hvorpå der skal tilføjes tillæg)
        var satsTid = 0.0
        
        switch weekDayComponent {
        case 2,3,4,5,6:
            if endTid > hverdagSatsTid {
                satsTid = Double(endTid - hverdagSatsTid)
            }
        case 7:
            if endTid > lordagSatsTid {
                satsTid = Double(endTid - lordagSatsTid)
                
            }
        default:
            break
        }
        
        if satsTid > vagtIMin {
            satsTid = vagtIMin
        }
        
        // Udregn satser
        
        if weekDayComponent == 1 {
            satser = vagtITimer * sondagsSats
        } else {
            satser = satsTid / 60 * tillægDage[weekDayComponent - 1]
        }
        
        // Udregn Løn
        
        let grundLon = vagtITimer * basisLon
        
        return grundLon + satser
    }
    
    func getDateIntervalString() -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateTemplate = "EEEE d/M H:mm"
        let formattedString = formatter.string(from: startTime, to: endTime)
        
        return formattedString
    }
    
    func getYearString() -> String {
        let component = myCalendar.component(.year, from: startTime)
        
        return String(component)
    }
    
    func getMonthString() -> String {
        return startTime.getMonthNumber(withYear: false).getMonthAsString()
    }
    
    
}
