//
//  MainVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 22/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class MainVC: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var lblThisMonth: UILabel!
    @IBOutlet weak var lblFøtexTotalLøn: UILabel!
    @IBOutlet weak var lblFøtexTillæg: UILabel!
    @IBOutlet weak var lblFøtexTimer: UILabel!
    @IBOutlet weak var lblFøtexVagter: UILabel!
    @IBOutlet weak var lblNæsteVagt: UILabel!
    
    @IBOutlet weak var vagtTableView: UITableView!
    
    // MARK: - Variabler
    
    var managedObjectContext: NSManagedObjectContext!
    
    var shouldShow = false
    
    // MARK: - Initial Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstTime(in: self)
        
        setupNotification()
        
        setColors()
        setAttributes(for: navigationController!.navigationBar)
        initialAnimations()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // Startup Functions
    
    private func setColors() {
        lblThisMonth.textColor = UIColor.white
        lblFøtexTotalLøn.textColor = UIColor.white
        lblFøtexTillæg.textColor = UIColor.white
        lblFøtexTimer.textColor = UIColor.white
        lblFøtexVagter.textColor = UIColor.white
        lblNæsteVagt.textColor = UIColor.white
        
        self.view.backgroundColor = fotexBlue
        vagtTableView.backgroundColor = fotexBlue
    }
    
    private func setColors(for cell: UITableViewCell) {
        cell.backgroundColor = fotexBlue
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.lightText
    }
    
    private func initialAnimations() {
        self.lblFøtexTotalLøn.isHidden = true
        self.lblFøtexTotalLøn.alpha = 0.0
        
        self.lblFøtexTillæg.isHidden = true
        self.lblFøtexTillæg.alpha = 0.0
        
        self.lblFøtexTimer.isHidden = true
        self.lblFøtexTimer.alpha = 0.0
        
        self.lblFøtexVagter.isHidden = true
        self.lblFøtexVagter.alpha = 0.0
        
        self.lblNæsteVagt.isHidden = true
        self.lblNæsteVagt.alpha = 0.0
        
        self.vagtTableView.alpha = 0.0
        
        
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveLinear, animations: {
            self.lblFøtexTotalLøn.isHidden = false
            self.lblFøtexTotalLøn.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveLinear, animations: {
            self.lblFøtexTillæg.isHidden = false
            self.lblFøtexTillæg.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveLinear, animations: {
            self.lblFøtexTimer.isHidden = false
            self.lblFøtexTimer.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveLinear, animations: {
            self.lblFøtexVagter.isHidden = false
            self.lblFøtexVagter.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.6, options: .curveLinear, animations: {
            self.lblFøtexVagter.isHidden = false
            self.lblFøtexVagter.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.7, options: .layoutSubviews, animations: {
            self.vagtTableView.alpha = 1.0
            }, completion: nil)
    }
    
    // MARK: - Other Functions
    
    func setupNotification() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [UNAuthorizationOptions.alert, .sound, .badge], completionHandler: { (granted, error) in
            
            if granted == true {
                let content = UNMutableNotificationContent()
                content.title = "Eksempel"
                content.body = "Ikke lavet endnu"
                content.sound = UNNotificationSound.default()
                
                let date = Date(timeIntervalSinceNow: 7)
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                // Request
                let request = UNNotificationRequest(identifier: "eksempel", content: content, trigger: trigger)
                
                center.add(request, withCompletionHandler: nil)
                
            } else {
                
                let alertController = UIAlertController (title: "Notifikationer slået fra", message: "Gå til indstillinger for at tillade Føtex Løn at sende notifikationer", preferredStyle: .alert)
                
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                    let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                    if let url = settingsUrl {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(settingsAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }

}

// MARK: - UITableViewDataSource

extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shouldShow {
            return 4
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "monthCell")
            
            let imageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "down"), highlightedImage: #imageLiteral(resourceName: "up"))
            if shouldShow {
                imageView.isHighlighted = true
            } else {
                imageView.isHighlighted = false
            }
//            let imageView = UIImageView(image: #imageLiteral(resourceName: "down"))
            
            cell.accessoryView = imageView
            cell.textLabel?.text = "Juli"
            cell.detailTextLabel?.text = "4750,-"
        } else {
            cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "- Antal vagt"
            cell.detailTextLabel?.text = "12"
        }
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "monthCell")
            
            let imageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "down"), highlightedImage: #imageLiteral(resourceName: "up"))
            if shouldShow {
                imageView.isHighlighted = true
            } else {
                imageView.isHighlighted = false
            }
            //            let imageView = UIImageView(image: #imageLiteral(resourceName: "down"))
            
            cell.accessoryView = imageView
            cell.textLabel?.text = "Juli"
            cell.detailTextLabel?.text = "4750,-"
        case 1:
            cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            // cell = tableView.dequeueReusableCell(withIdentifier: "theCell")
            // cell = MonthCell(style: .value1, reuseIdentifier: "theCell")
            cell.textLabel?.text = "- Deraf tillæg"
            cell.detailTextLabel?.text = "700,-"
            cell.accessoryView = nil
        case 2:
            cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "- Antal timer"
            cell.detailTextLabel?.text = "64:15"
        case 3:
            cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "- Antal vagter"
            cell.detailTextLabel?.text = "15"
        default:
            cell = UITableViewCell()
        }
        
        setColors(for: cell)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MainVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            shouldShow = !shouldShow
            tableView.reloadData()
        }
    }
}


//    lazy var vagterFRC: NSFetchedResultsController<NSFetchRequestResult> = {
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
//        let entity = NSEntityDescription.entity(forEntityName: "Vagt", in: self.managedObjectContext)
//        fetchRequest.entity = entity
//
//        let sortDescriptor1 = SortDescriptor(key: "monthNumber", ascending: false)
//        let sortDescriptor2 = SortDescriptor(key: "startTime", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
//
//        fetchRequest.fetchBatchSize = 20
//
//        let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
//
//        return fetchedResultsController
//
//    }















