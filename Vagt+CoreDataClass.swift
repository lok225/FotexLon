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
        
        return Double(vagtIMinMedPause - pauseTime)
    }
    
    var vagtITimer: Double {
        
        return Double(vagtIMin / 60)
    }
    
    var pauseTime: Int {
        
        guard pause == true else {
            return 0
        }
        
        // TODO: Tilføj andre tidspunkter med pauser
        if vagtIMinMedPause >= 240 {
            return 30
        } else {
            return 0
        }
    }
    
    var samletLon: Double {
        
        return calculateTotalLon()
    }
    
    
    
    private func calculateTotalLon() -> Double {
        let isYoungWorker: Bool = UserDefaults.standard.bool(forKey: kYoungWorker)
        
        let basisLon: Double = isYoungWorker ? youngBasisLon : oldBasisLon
        let aftenSats: Double = isYoungWorker ? youngAftenSats : oldAftenSats
        let lordagsSats: Double = isYoungWorker ? youngLordagsSats : oldLordagsSats
        let sondagsSats: Double = isYoungWorker ? youngSondagsSats : oldSondagsSats
        
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
        print(grundLon)
        
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
