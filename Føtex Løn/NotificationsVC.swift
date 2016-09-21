//
//  NotificationsVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 22/08/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class NotificationsVC: UITableViewController {
    
    let defaults = UserDefaults.standard
    
    var vagterFRC: NSFetchedResultsController<NSFetchRequestResult>!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAccessoryTypes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var array = [Int]()
        
        var i = 0
        
        while i < tableView.numberOfRows(inSection: 0) {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0))
            if cell?.accessoryType == .checkmark {
                array.append(i)
            }
            i += 1
        }
        
        defaults.set(array, forKey: kNotifications)
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let objects = vagterFRC.fetchedObjects as! [Vagt]
        for vagt in objects {
            vagt.createNotifications()
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print(requests.count)
            for request in requests {
                print(request)
            }
        }
        
        UNUserNotificationCenter.current().getDeliveredNotifications { (requests) in
            print(requests.count)
            for request in requests {
                print(request.date)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
    }

    func updateAccessoryTypes() {
        
        let notifications = defaults.object(forKey: kNotifications) as! [Int]
        
        for noticationInt in notifications {
            tableView.cellForRow(at: IndexPath(row: noticationInt, section: 0))?.accessoryType = .checkmark
        }
    }

}
