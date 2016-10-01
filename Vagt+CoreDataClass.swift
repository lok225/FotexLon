//
//  Vagt+CoreDataClass.swift
//  Føtex Løn
//
//  Created by Martin Lok on 07/08/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import Foundation
import CoreData
import UserNotifications
import EventKit

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
        
        let endTid = (endHour * 60) + endMinute - pause
        
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
    
    // MARK: - Initial functions
    
    func createID() {
        let id = UUID()
        
        self.id = id.uuidString
    }
    
    // MARK: - Calendar Functions
    
    func createCalendarEvent() {
        
        if EKEventStore.authorizationStatus(for: .event) == .authorized {
            let eventStore = EKEventStore()
            
            eventStore.requestAccess(to: .event) { (granted, error) in
                if granted && error == nil {
                    let event = EKEvent(eventStore: eventStore)
                    event.title = "Arbejde - Vagt"
                    event.startDate = self.startTime
                    event.endDate = self.endTime
                    event.notes = self.note
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    
                    do {
                        try eventStore.save(event, span: .thisEvent, commit: true)
                    } catch {
                        print(error)
                    }
                    
                    self.eventID = event.eventIdentifier
                }
            }
        }
    }
    
    func updateCalendarEvent() {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            guard granted && error == nil else {
                return
            }
        
            let event = eventStore.event(withIdentifier: self.eventID!)!
            event.startDate = self.startTime
            event.endDate = self.endTime
            event.notes = self.note
            
            do {
                try eventStore.save(event, span: .thisEvent, commit: true)
            } catch {
                print(error)
            }
        }
    }
    
    func deleteCalendarEvent() {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            guard granted && error == nil else {
                return
            }
            
            let event = eventStore.event(withIdentifier: self.eventID!)!
            
            do {
                try eventStore.remove(event, span: .thisEvent, commit: true)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Notifications
    
    func createNotifications() {
        
        guard startTime.compare(Date()) == .orderedDescending else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                
                guard granted && error == nil else {
                    return
                }
                
                for notificationInt in UserDefaults.standard.object(forKey: kNotifications) as! [Int] {
                    let content = UNMutableNotificationContent()
                    content.sound = UNNotificationSound.default()
                    
                    var date: Date!
                    switch notificationInt {
                    case 0:
                        content.title = "Vagt begynder nu"
                        content.body = "Din vagt kl. \(self.getTimeIntervalString()) begynder nu"
                        date = Date(timeInterval: 0, since: self.startTime)
                    case 1:
                        content.title = "Arbejde om 5 min"
                        content.body = "Din vagt kl. \(self.getTimeIntervalString()) begynder om 5 minutter"
                        date = Date(timeInterval: -300, since: self.startTime)
                    case 2:
                        content.title = "Arbejde om 15 min"
                        content.body = "Din vagt kl. \(self.getTimeIntervalString()) begynder nu 15 minutter"
                        date = Date(timeInterval: -900, since: self.startTime)
                    case 3:
                        content.title = "Arbejde om 30 min"
                        content.body = "Din vagt kl. \(self.getTimeIntervalString()) begynder om 30 minutter"
                        date = Date(timeInterval: -1800, since: self.startTime)
                    case 4:
                        content.title = "Arbejde om 1 time"
                        content.body = "Din vagt kl. \(self.getTimeIntervalString()) begynder om 1 time"
                        date = Date(timeInterval: -3600, since: self.startTime)
                    case 5:
                        content.title = "Arbejde om 2 timer"
                        content.body = "Din vagt kl. \(self.getTimeIntervalString()) begynder om 2 timer"
                        date = Date(timeInterval: -7200, since: self.startTime)
                    case 6:
                        content.title = "Arbejde imorgen"
                        content.body = "Din vagt kl. \(self.getTimeIntervalString())"
                        date = Date(timeInterval: -86400, since: self.startTime)
                    default:
                        break
                    }
                    
                    let formatter = DateFormatter()
                    formatter.dateStyle = .full
                    formatter.timeStyle = .medium
                    
                    var comps: DateComponents!
                    comps = Calendar.current.dateComponents(in: TimeZone.current, from: date)
                    let comps1 = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    if content.title == "Arbejde imorgen" {
                        comps.hour = 20
                        comps.minute = 0
                    }
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: comps1, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: self.id + String(notificationInt), content: content, trigger: trigger)
                    
                    center.add(request, withCompletionHandler: { (error) in
                        if let _ = error {
                            print("Error: \(error!.localizedDescription)")
                        }
                    })
                }
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func deleteNotifications() {
        
        guard startTime.compare(Date()) == .orderedDescending else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                
                guard granted && error == nil else {
                    return
                }
                
                // TODO: Laver måske fejl, men crasher ikke
                guard self.id != nil else {
                    return
                }
                
                var IDs = [String]()
                
                for notificationInt in UserDefaults.standard.object(forKey: kNotifications) as! [Int] {
                    let id = self.id + String(notificationInt)
                    IDs.append(id)
                }
                center.removePendingNotificationRequests(withIdentifiers: IDs)
            }
        }
    }
    
    func updateNotifications() {
        deleteNotifications()
        createNotifications()
    }
    
    // MARK: - Get Strings
    
    /// Bruges til notifikationer
    ///
    /// - returns: Returnerer en string udelukkende med start- og sluttidspunktet, som f.eks. '16.00-20-15'
    func getTimeIntervalString() -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateTemplate = "H:mm"
        
        return formatter.string(from: startTime, to: endTime)
    }
    
    /// Bruges ved vagt-cell
    ///
    /// - returns: Returnerer en string med startdato + start- og sluttidspunktet, som f.eks. 'Onsdag 24/8 16.00-20.15'
    func getDateIntervalString() -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateTemplate = "EEEE d/M H:mm"
        let formattedString = formatter.string(from: startTime, to: endTime)
        
        return formattedString
    }
    
    /// - returns: Returnerer vagtens år som string
    func getYearString() -> String {
        let component = myCalendar.component(.year, from: startTime)
        
        return String(component)
    }
    
    /// - returns: Returnerer vagtens måned som string
    func getMonthString() -> String {
        return startTime.getMonthNumber(withYear: false).getMonthAsString()
    }
    
    
}
