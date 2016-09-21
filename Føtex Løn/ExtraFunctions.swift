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

// UserDefaults

let kFirstTime = "firstTime"
let kYoungWorker = "youngWorker"
let kVagtDetailSegue = "vagtDetailSegue"
let kNotifications = "notifications"
let kTheme = "theme"
let kIsLoggedIn = "loggedIn"
let kAddToCalendar = "addToCalendar"
let kFrikort = "frikort"

// Segues

let kStandardVagtSegue = "standardVCSegue"
let kNotificationsSegue = "notificationsSegue"

// Cells

let kStandardFilledCell = "standardFilledVagtcell"
let kStandardEmptyCell = "standardEmptyVagtcell"

// Løn

let kYoungBasisLon = "youngBasisLon"
let kYoungAftensSats = "youngAftenSats"
let kYoungLordagsSats = "youngLordagsSats"
let kYoungSondagsSats = "youngSondagsSats"
let kOldBasisLon = "oldBasisLon"
let kOldAftensSats = "oldAftenSats"
let kOldLordagsSats = "oldLordagsSats"
let kOldSondagsSats = "oldSondagsSats"

let kStandardHverdage = "standardHverdage"
let kStandardLørdag = "standardLørdag"
let kStandardSøndag = "standardSøndag"

let youngBasisLon: Double = 63.86
let youngAftenSats: Double = 12.6
let youngLordagsSats: Double = 22.38
let youngSondagsSats: Double = 25.3

let oldBasisLon: Double = 112.42
let oldAftenSats: Double = 25.2
let oldLordagsSats: Double = 44.75
let oldSondagsSats: Double = 50.6

// Enum

enum Shop: Int {
    case teal = 0
    case føtex = 1
    case fakta = 2
    case bio = 3
    case ingen = 4
}

// MARK: Farver

let defaultTint = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)

// Føtex
let fotexBlue = UIColor(red: 0.01, green: 0.18, blue: 0.35, alpha: 1.0)
let fotexCellBlue = UIColor(hue: 209/360, saturation: 0.87, brightness: 0.4, alpha: 1.0)
let highlightedCellBlue2 = UIColor(hue: 0.57, saturation: 0.69, brightness: 0.42, alpha: 1.0)

// Fakta
let faktaDardRed = UIColor(red: 0.59, green: 0.1, blue: 0.2, alpha: 1.0)
let faktaRed = UIColor(red: 0.71, green: 0.09, blue: 0.16, alpha: 1.0)

// Bio
let bioDark = UIColor.black
let bioLighter = UIColor.darkGray

// teal
let darkteal = UIColor(hue: 172/360, saturation: 0.68, brightness: 0.43, alpha: 1.0)
let teal = UIColor(red: 0.06, green: 0.47, blue: 0.42, alpha: 1.0)
let lightTeal = UIColor(red: 0.08, green: 0.58, blue: 0.53, alpha: 1.0)

var mainColor: UIColor {
    let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
    
    switch shop {
    case .ingen:
        return UIColor.white
    case .føtex:
        return fotexBlue
    case .fakta:
        return faktaRed
    case .bio:
        return bioLighter
    case .teal:
        return teal
    }
}

var secondaryColor: UIColor {
    let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
    
    switch shop {
    case .ingen:
        return UIColor.white
    case .føtex:
        return fotexCellBlue
    case .fakta:
        return faktaDardRed
    case .bio:
        return bioDark
    case .teal:
        return darkteal
    }
}

var customTintColor: UIColor {
    let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
    
    switch shop {
    case .ingen:
        return defaultTint
    case .føtex:
        return fotexBlue
    case .fakta:
        return faktaRed
    case .bio:
        return bioLighter
    case .teal:
        return darkteal
    }
}

var customBarTintColor: UIColor {
    let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
    
    switch shop {
    case .ingen:
        return UIColor.gray
    case .føtex:
        return fotexCellBlue
    case .fakta:
        return faktaDardRed
    case .bio:
        return bioDark
    case .teal:
        return darkteal
    }
}

var customTabBarTintColor: UIColor {
    let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
    
    switch shop {
    case .ingen:
        return UIColor.black
    case .føtex:
        return fotexBlue
    case .fakta:
        return faktaRed
    case .bio:
        return bioDark
    case .teal:
        return teal
    }
}

var textColor: UIColor {
    let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
    
    switch shop {
    case .ingen:
        return UIColor.black
    case .føtex:
        return UIColor.white
    case .fakta:
        return UIColor.white
    case .bio:
        return UIColor.white
    case .teal:
        return UIColor.white
    }
}

var detailTextColor: UIColor {
    let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
    
    switch shop {
    case .ingen:
        return UIColor.lightGray
    case .føtex:
        return UIColor.lightText
    case .fakta:
        return UIColor.lightText
    case .bio:
        return UIColor.lightText
    case .teal:
        return UIColor.lightText
    }
}

var highlightedCellColor: UIColor {
    let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
    
    switch shop {
    case .ingen:
        return UIColor.lightGray
    case .føtex:
        return highlightedCellBlue2
    case .fakta:
        return UIColor.lightText
    case .bio:
        return UIColor.lightText
    case .teal:
        return UIColor.lightText
    }
}

// Data Model

var vagter: [Vagt] = []
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

// MARK: - Global Colors

// Ved ændring af farver skal disse konfigureres samt mainView og headerTitle i MainVC

func setAttributes(for navBar: UINavigationBar) {
    
    navBar.barTintColor = customBarTintColor
    navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
}

func setColors(forVagtDetailVC vc: VagtDetailVC) {
    
    vc.view.tintColor = customTintColor
}

func setColors(forVC vc: UIViewController) {
    
    vc.view.backgroundColor = mainColor
    vc.view.tintColor = customTintColor
}

func setColors(forTableView tableView: UITableView) {
    
    tableView.backgroundColor = mainColor
}

func setColors(forCell cell: UITableViewCell) {
    
    cell.backgroundColor = mainColor
    cell.textLabel?.textColor = textColor
    cell.detailTextLabel?.textColor = detailTextColor
    
    let cellView = UIView()
    cellView.backgroundColor = highlightedCellColor
    cell.selectedBackgroundView = cellView
}

func setColors(forTableViewHeader header: UITableViewHeaderFooterView) {

    header.textLabel?.textColor = textColor
    header.alpha = 0.85
}

func setColors(forTabBar tabBar: UITabBar) {
    
    tabBar.tintColor = customTabBarTintColor
}

func getLocationString() -> String {
    
    let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
    
    switch shop {
    case .ingen:
        return "Ingen"
    case .føtex:
        return "Føtex"
    case .fakta:
        return "Fakta"
    case .bio:
        return "Biografen"
    default:
        return ""
    }
}

// MARK: - Formatting

func getFormatted(time timeWorked: Int) -> String {
    
    let hoursWorked = timeWorked / 60
    let minutesWorked = timeWorked % 60
    
    let totalTime = String(format: "%01d:%02d", hoursWorked, minutesWorked)
    
    return totalTime
}

func getFormatted(number: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    
    return formatter.string(from: NSNumber(value: number))! + ",-"
}

// MARK: Extensions

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Date {
    
    func differenceInMins(withDate date: Date) -> Int {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.minute], from: self, to: date)
        
        return components.minute!
    }
    
    func getMonthNumber(withYear: Bool) -> Double {
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        
        if components.day! > 18 {
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

extension Int {
    
    func getNotificationsDetailString() -> String {
        
        switch self {
        case 0:
            return "Ved vagtens start"
        case 1:
            return "5 min før"
        case 2:
            return "15 min før"
        case 3:
            return "30 min før"
        case 4:
            return "1 time før"
        case 5:
            return "2 timer før"
        case 6:
            return "Dagen før"
        default:
            return "Intet"
        }
    }
    
}








