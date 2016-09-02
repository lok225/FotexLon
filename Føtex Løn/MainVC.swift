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
    
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!
    var vagterFRC: NSFetchedResultsController<NSFetchRequestResult>!
    
    var shouldShow = false
    
    var currentMonthIndex: Int {
        
        var tempIndex = 0
        
        guard let sections = vagterFRC.sections else {
            return tempIndex
        }
        
        /*
        if vagterFRC.sections!.count > 1 {
            tempIndex += 1
        }
        */
        
        let thisMonthNumber = Date().getMonthNumber(withYear: true)
        
        for section in sections {
            let vagt = section.objects?[0] as! Vagt
            
            if thisMonthNumber != vagt.monthNumber {
                tempIndex += 1
            } else {
                return tempIndex
            }
        }
        
        return tempIndex
    } 
    
    var currentMonth: Month?
    var months: [Month] = []
    var years: [Year] = []
    
    // MARK: - Initial Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstTime(in: self)
        setupFetchedResultsController()
        
        initialAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setAttributes(for: navigationController!.navigationBar)
        setMainViewColors()
        setColors(forVC: self)
        setColors(forTableView: vagtTableView)
        
        fetchObjects()
        setupMonths()
        currentMonth = months[currentMonthIndex]
        setupYears()
        vagtTableView.reloadData()
        setViews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // Startup Functions
    
    private func setMainViewColors() {
        
        let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
        
        if shop == .ingen {
            lblThisMonth.textColor = UIColor.black
            lblFøtexTotalLøn.textColor = UIColor.black
            lblFøtexTillæg.textColor = UIColor.black
            lblFøtexTimer.textColor = UIColor.black
            lblFøtexVagter.textColor = UIColor.black
            lblNæsteVagt.textColor = UIColor.black
        } else {
            lblThisMonth.textColor = UIColor.white
            lblFøtexTotalLøn.textColor = UIColor.white
            lblFøtexTillæg.textColor = UIColor.white
            lblFøtexTimer.textColor = UIColor.white
            lblFøtexVagter.textColor = UIColor.white
            lblNæsteVagt.textColor = UIColor.white
        }
    }
    
    private func setupMonths() {
        months.removeAll()
        for section in vagterFRC.sections! {
            let vagt = section.objects!.first! as! Vagt
            let month = Month(fetchedRC: vagterFRC, monthNumber: vagt.monthNumber)
            months.append(month)
        }
    }
    
    private func setupYears() {
        years.removeAll()
        
        var i = -1
        
        var year = [Month]()
        
        for month in months {
            
            if months.count == 1{
                years.append(Year(months: [month]))
            } else if i == -1 {
                year.append(month)
                i += 1
            } else {
                if i == months.count - 2 && months[i].getYear() == month.getYear() {
                    year.append(month)
                    years.append(Year(months: year))
                    year.removeAll()
                } else if months[i].getYear() == month.getYear() {
                    year.append(month)
                } else if i == months.count - 2 && months[i].getYear() != month.getYear() {
                    years.append(Year(months: year))
                    years.append(Year(months: [month]))
                } else {
                    years.append(Year(months: year))
                    year.removeAll()
                    year.append(month)
                }
                i += 1
                
            }
        }
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
        
        UIView.animate(withDuration: 0.3, delay: 0.7, options: .layoutSubviews, animations: {
            self.lblNæsteVagt.isHidden = false
            self.lblNæsteVagt.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.8, options: .layoutSubviews, animations: {
            self.vagtTableView.alpha = 1.0
            }, completion: nil)
        
        
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "settingsSegue":
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.topViewController! as! SettingsVC
            vc.vagterFRC = self.vagterFRC
        default:
            break
        }
    }
    
    // MARK: - Core Data Functions
    
    func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Vagt", in: self.dataController.managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "monthNumber", ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: "startTime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        
        vagterFRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "monthNumber", cacheName: nil)
        
        fetchObjects()
    }
    
    func fetchObjects() {
        do {
            try vagterFRC.performFetch()
            
//            if vagterFRC.fetchedObjects?.count == 0 {
//                createStandardVagt()
//            } else {
//                
//                var needNew = true
//                
//                for section in vagterFRC.sections! {
//                    let vagt = section.objects!.first!
//                    if vagt.monthNumber == Date().getMonthNumber(withYear: true) {
//                        needNew = false
//                    }
//                }
//                
//                if needNew == true {
//                    createStandardVagt()
//                }
//            }
            
            var needNew = true
            
            for section in vagterFRC.sections! {
                let vagt = section.objects!.first! as! Vagt
                if vagt.monthNumber == Date().getMonthNumber(withYear: true) {
                    needNew = false
                }
            }
            
            if needNew == true {
                createStandardVagt()
            }
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    func createStandardVagt() {
        let vagt = NSEntityDescription.insertNewObject(forEntityName: "Vagt", into: managedObjectContext) as! Vagt
        vagt.startTime = Date()
        vagt.endTime = Date(timeInterval: 60, since: vagt.startTime)
        vagt.pause = 0
        vagt.monthNumber = vagt.startTime.getMonthNumber(withYear: true)
        dataController.save()
        
        do {
            try vagterFRC.performFetch()
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    // MARK: - Other Functions
    
    func setViews() {
        
        if let month = currentMonth {
            lblThisMonth.text = "Anslået løn i \(month.getMonthString().lowercased())"
            lblFøtexTotalLøn.text = getFormatted(number: month.calculateTotalLøn())
            // lblFøtexTillæg.text = "Deraf tillæg: \(month.calculateSatser()),-"
            lblFøtexTillæg.text = "Til udbetaling: \(getFormatted(number:Int(Double(month.calculateTotalLøn()) * 0.92)))"
            lblFøtexTimer.text = "Antal timer: \(getFormatted(time: month.calculateAntalMin()))"
            lblFøtexVagter.text = "Antal vagter: \(month.calculateAntalVagter())"
        } else {
            lblThisMonth.text = "Løn i denne måned"
            lblFøtexTotalLøn.text = "0,-"
            lblFøtexTillæg.text = "Deraf tillæg: 0,-"
            lblFøtexTimer.text = "Antal timer: \(getFormatted(time: 0))"
            lblFøtexVagter.text = "Antal vagter: 0"
        }
        
    }
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return years.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return years[section].months.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        let month = years[indexPath.section].months[indexPath.row]
        
        cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = month.getMonthString() + ", " + month.getYearString()
        cell.detailTextLabel?.text = getFormatted(number: month.calculateTotalLøn()) + " / " + getFormatted(number: Int(Double(month.calculateTotalLøn()) * 0.92))
        
        cell.selectionStyle = .none
        
        setColors(forCell: cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let year = years[section]
        let lønString = "\nLøn: ".lowercased() + getFormatted(number: year.calculateTotalLøn())
        let frikort = "\nResterende frikort: " + getFormatted(number: 33000 - year.calculateTotalLøn())
        let feriePenge = "\nFeriepenge: " + getFormatted(number: Int(Double(year.calculateTotalLøn()) * 0.12))
        
        return year.getYearString() + lønString + frikort + feriePenge
    }
}

// MARK: - UITableViewDelegate

extension MainVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            shouldShow = !shouldShow
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        setColors(forTableViewHeader: view as! UITableViewHeaderFooterView)
    }
    
}














