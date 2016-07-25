//
//  ExtraFunctions.swift
//  Føtex Løn
//
//  Created by Martin Lok on 25/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import Foundation
import UIKit

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

func firstTime(inViewController vc: UIViewController) {
    let defaults = UserDefaults.standard
    let isFirstTime = defaults.bool(forKey: kFirstTime)
    
    if isFirstTime {
        presentAndGetYoungWorkerSetting(inViewController: vc)
        
        defaults.set(false, forKey: kFirstTime)
        defaults.synchronize()
    }
}

func presentAndGetYoungWorkerSetting(inViewController vc: UIViewController) {
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

extension Date {
    
    func differenceInMins(withDate date: Date) -> Int {
        let calendar = Calendar.current
        
        let components = calendar.components(.minute, from: self, to: date, options: [])
        
        return components.minute!
    }
    
}











