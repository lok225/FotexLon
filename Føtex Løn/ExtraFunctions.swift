//
//  ExtraFunctions.swift
//  Føtex Løn
//
//  Created by Martin Lok on 25/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import Foundation
import UIKit

// MARK: Global Konstanter

let kFirstTime = "firstTime"
let kYoungWorker = "youngWorker"

let youngBasisLon: Double = 63.86
let youngAftenSats: Double = 12.6
let youngLordagsSats: Double = 22.38
let youngSondagsSats: Double = 25.3

let oldBasisLon: Double = 112.42
let oldAftenSats: Double = 25.2
let oldLordagsSats: Double = 44.75
let oldSondagsSats: Double = 50.6

let mainBlue = UIColor(hue: 185/360, saturation: 0.39, brightness: 0.6, alpha: 1.0)
let cellBlue = UIColor(hue: 175/360, saturation: 0.26, brightness: 0.69, alpha: 1.0)
let fotexBlue = UIColor(red: 0.01, green: 0.18, blue: 0.35, alpha: 1.0)
let fotexBlue1 = UIColor(hue: 0.59, saturation: 0.93, brightness: 0.35, alpha: 1.0)
let fotexCellBlue = UIColor(hue: 209/360, saturation: 0.87, brightness: 0.4, alpha: 1.0)

let vagt1 = Vagt(startTime: Date(), endTime: Date(), pause: true)

var vagter: [Vagt] = [vagt1]
var months: [[Vagt]] = [vagter]

// MARK: Functions

func firstTime(in vc: UIViewController) {
    let defaults = UserDefaults.standard
    let isFirstTime = defaults.bool(forKey: kFirstTime)
    
    if isFirstTime {
        presentAndGetYoungWorkerSetting(in: vc)
        
        defaults.set(false, forKey: kFirstTime)
        defaults.synchronize()
    }
}

func presentAndGetYoungWorkerSetting(in vc: UIViewController) {
    let defaults = UserDefaults.standard
    
    let alertController = UIAlertController(title: "Over eller under 18", message: "Informationen bruges til at lave indtillinger for timeløn", preferredStyle: .alert)
    
    let underAction = UIAlertAction(title: "Under 18", style: .default) { (action) in
        defaults.set(true, forKey: kYoungWorker)
    }
    let overAction = UIAlertAction(title: "Over 18", style: .default) { (action) in
        defaults.set(false, forKey: kYoungWorker)
        
    }
    alertController.addAction(underAction)
    alertController.addAction(overAction)
    
    vc.present(alertController, animated: true, completion: nil)
}

func setAttributes(for navBar: UINavigationBar) {
    navBar.barTintColor = fotexCellBlue
    navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
}

// MARK: Extensions

extension Date {
    
    func differenceInMins(withDate date: Date) -> Int {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.minute], from: self, to: date)
        
        return components.minute!
    }
    
    func getMonthNumber(withYear: Bool) -> Double {
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        
        if components.day > 18 {
            components.month! += 1
        }
        
        if withYear {
            let monthNumber = Double(components.year!) + (Double(components.month!) / 100.0)
            
            return monthNumber
        } else {
            return Double(components.month!)
        }
    }
}


extension Double {
    
    func getMonthAsString() -> String {
        
        let monthString: String!
        
        switch self {
        case 1:
            monthString = "Januar"
        case 2:
            monthString = "Februar"
        case 3:
            monthString = "Marts"
        case 4:
            monthString = "April"
        case 5:
            monthString = "Maj"
        case 6:
            monthString = "Juni"
        case 7:
            monthString = "Juli"
        case 8:
            monthString = "August"
        case 9:
            monthString = "September"
        case 10:
            monthString = "Oktober"
        case 11:
            monthString = "November"
        case 12:
            monthString = "December"
        default:
            monthString = ""
        }
        
        return monthString
    }
}










