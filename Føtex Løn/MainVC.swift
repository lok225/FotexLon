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
    @IBOutlet weak var lblTotalLøn: UILabel!
    @IBOutlet weak var lblUdbetaling: UILabel!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblVagter: UILabel!
    
    @IBOutlet weak var vagtTableView: UITableView!
    
    // MARK: - Variabler
    
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!
    var vagterFRC: NSFetchedResultsController<NSFetchRequestResult>!
    
    var shouldShow = false
    
    var lønPeriodeAlert: UIAlertController?
    
    var fromDetailVC = false
    
    var currentMonthIndex: Int {
        
        var tempIndex = 0
        
        guard let sections = vagterFRC.sections else {
            return tempIndex
        }
        
        let thisMonthNumber = Date().getMonthNumber(withYear: true)
        
        if sections.count == 1 {
            return 0
        }
        
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

        setupFetchedResultsController()
        
        initialAnimations()
        
        createNotifications()
        
//        let vagt = NSEntityDescription.insertNewObject(forEntityName: "Vagt", into: managedObjectContext) as! Vagt
//        vagt.startTime = Date()
//        vagt.endTime = Date()
//        vagt.pause = 30
//        vagt.monthNumber = vagt.startTime.getMonthNumber(withYear: true)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setAttributes(for: navigationController!.navigationBar)
        setMainViewColors()
        setColors(forVC: self)
        setColors(forTableView: vagtTableView)
        
        if UserDefaults.standard.bool(forKey: kFirstTime) == false {
            print("called")
            firstTime()
        }
        
        fetchObjects()
        setupMonths()
        if months.count > 0 {
            currentMonth = months[currentMonthIndex]
        }
        setupYears()
        vagtTableView.reloadData()
        setViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: - Startup Functions
    
    func firstTime() {
        let defaults = UserDefaults.standard
        let isFirstTime = defaults.bool(forKey: kFirstTime)
        
        print("firstTime: \(defaults.bool(forKey: kFirstTime))")
        print("alderIsSet: \(defaults.bool(forKey: kAlderIsSet))")
        print("lønPeriodeIsSet: \(defaults.bool(forKey: kLønperiodeIsSet))")
        
        if isFirstTime {
            let time = DispatchTime.now() + .milliseconds(800)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.presentAndGetYoungWorkerSetting()
            })
            
            defaults.set(false, forKey: kFirstTime)
            defaults.synchronize()
        } else if defaults.bool(forKey: kAlderIsSet) == false {
            presentAndGetYoungWorkerSetting()
        } else if defaults.bool(forKey: kLønperiodeIsSet) == false {
            presentAndGetLønPeriode()
        }
    }
    
    func presentAndGetLønPeriode() {
        lønPeriodeAlert = UIAlertController(title: "Lønperiode", message: "Vælg starten af din lønperiode. Spørg din chef hvis du ikke kender datoen. \nVigtigt: Kan ikke ændres senere", preferredStyle: .alert)
        var thisPicker: UIPickerView!
        lønPeriodeAlert!.addTextField(configurationHandler: { (textField) in
            let picker = UIPickerView()
            picker.dataSource = self
            picker.delegate = self
            picker.selectRow(18, inComponent: 0, animated: false)
            textField.inputView = picker
            thisPicker = self.lønPeriodeAlert!.textFields!.first!.inputView! as! UIPickerView
            textField.text = "D. 19."
        })
        let doneAction = UIAlertAction(title: "Færdig", style: .default, handler: { (action) in
            let row = thisPicker.selectedRow(inComponent: 0) + 1
            let defaults = UserDefaults.standard
            defaults.set(row, forKey: kLønPeriodeStart)
            defaults.set(true, forKey: kLønperiodeIsSet)
            defaults.synchronize()
        })
        lønPeriodeAlert!.addAction(doneAction)
        self.present(lønPeriodeAlert!, animated: true, completion: nil)
    }
    
    func presentAndGetYoungWorkerSetting() {
        let defaults = UserDefaults.standard
        
        let alertController = UIAlertController(title: "Over eller under 18", message: "Informationen bruges til at lave indtillinger for timeløn", preferredStyle: .alert)
        
        let underAction = UIAlertAction(title: "Under 18", style: .default) { (action) in
            defaults.set(true, forKey: kYoungWorker)
            defaults.set(true, forKey: kAlderIsSet)
            defaults.synchronize()
            if defaults.bool(forKey: kLønperiodeIsSet) == false {
                self.presentAndGetLønPeriode()
            }
        }
        let overAction = UIAlertAction(title: "Over 18", style: .default) { (action) in
            defaults.set(false, forKey: kYoungWorker)
            defaults.set(false, forKey: kAlderIsSet)
            defaults.synchronize()
            if defaults.bool(forKey: kLønperiodeIsSet) == false {
                self.presentAndGetLønPeriode()
            }
        }
        alertController.addAction(underAction)
        alertController.addAction(overAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func setMainViewColors() {
        
        let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
        
        if shop == .ingen {
            lblThisMonth.textColor = UIColor.black
            lblTotalLøn.textColor = UIColor.black
            lblUdbetaling.textColor = UIColor.black
            lblTimer.textColor = UIColor.black
            lblVagter.textColor = UIColor.black
        } else {
            lblThisMonth.textColor = UIColor.white
            lblTotalLøn.textColor = UIColor.white
            lblUdbetaling.textColor = UIColor.white
            lblTimer.textColor = UIColor.white
            lblVagter.textColor = UIColor.white
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
        self.lblTotalLøn.isHidden = true
        self.lblTotalLøn.alpha = 0.0
        
        self.lblUdbetaling.isHidden = true
        self.lblUdbetaling.alpha = 0.0
        
        self.lblTimer.isHidden = true
        self.lblTimer.alpha = 0.0
        
        self.lblVagter.isHidden = true
        self.lblVagter.alpha = 0.0
        
        self.vagtTableView.alpha = 0.0
        
        
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveLinear, animations: {
            self.lblTotalLøn.isHidden = false
            self.lblTotalLøn.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveLinear, animations: {
            self.lblUdbetaling.isHidden = false
            self.lblUdbetaling.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveLinear, animations: {
            self.lblTimer.isHidden = false
            self.lblTimer.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveLinear, animations: {
            self.lblVagter.isHidden = false
            self.lblVagter.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.6, options: .curveLinear, animations: {
            self.lblVagter.isHidden = false
            self.lblVagter.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.8, options: .layoutSubviews, animations: {
            self.vagtTableView.alpha = 1.0
            }, completion: nil)
        
        
    }
    
    func createNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        } else {
            // Fallback on earlier versions
        }
        
        let objects = vagterFRC.fetchedObjects as! [Vagt]
        for vagt in objects {
            vagt.createNotifications()
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case kSettingsSegue:
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.topViewController! as! SettingsVC
            vc.vagterFRC = self.vagterFRC
            vc.dataController = self.dataController
            vc.managedObjectContext = self.managedObjectContext
            
            if fromDetailVC {
                self.fromDetailVC = false
                vc.fromDetailVC = true
            }
        default:
            break
        }
    }
    
    @IBAction func dismissToMainVC(segue:UIStoryboardSegue) {}
    
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
            
            /*
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
 */
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
        
        vagt.createID()
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
            lblTotalLøn.text = getFormatted(number: month.calculateTotalLøn())
            
            let trækprocent = Double(UserDefaults.standard.integer(forKey: kTrækprocent))
            var udbetaling: String!
            if trækprocent != 0 {
                udbetaling = getFormatted(number:Int(Double(month.calculateTotalLøn()) * ((100 - trækprocent) / 100)))
            } else {
                udbetaling = getFormatted(number:Int(Double(month.calculateTotalLøn()) * 0.92))
            }
            lblUdbetaling.text = "Til udbetaling: " + udbetaling
            lblTimer.text = "Antal timer: \(getFormatted(time: month.calculateAntalMin()))"
            lblVagter.text = "Antal vagter: \(month.calculateAntalVagter())"
        } else {
            lblThisMonth.text = "Løn i denne måned"
            lblTotalLøn.text = "0,-"
            lblUdbetaling.text = "Deraf tillæg: 0,-"
            lblTimer.text = "Antal timer: \(getFormatted(time: 0))"
            lblVagter.text = "Antal vagter: 0"
        }
        
    }
    
    func setupNotification() {
        if #available(iOS 10.0, *) {
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

}

// MARK: - UITableViewDataSource

extension MainVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if years.count == 0 {
            return 1
        } else {
            return years.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if years.count == 0 {
            return 1
        } else {
            return years[section].months.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        
        setColors(forCell: cell)
        
        if years.count == 0 {
            let date = Date()
            cell.textLabel?.text = date.getYearAndMonthString()
            cell.detailTextLabel?.text = "0,- / 0,-"
            
            return cell
        }
        
        let month = years[indexPath.section].months[indexPath.row]
        
        cell.textLabel?.text = month.getMonthString() + ", " + month.getYearString()
        
        let trækprocent = Double(UserDefaults.standard.integer(forKey: kTrækprocent))
        var udbetaling: String!
        if trækprocent != 0 {
            udbetaling = getFormatted(number:Int(Double(month.calculateTotalLøn()) * ((100 - trækprocent) / 100)))
        } else {
            udbetaling = getFormatted(number:Int(Double(month.calculateTotalLøn()) * 0.92))
        }
        
        cell.detailTextLabel?.text = getFormatted(number: month.calculateTotalLøn()) + " / " + udbetaling
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let frikortInt = UserDefaults.standard.integer(forKey: kFrikort)
        
        if years.count == 0 {
            let yearString = String(Calendar.current.component(.year, from: Date()))
            let lønString = "\nLøn: 0,-"
            let feriePenge = "\nFeriepenge: 0,-"
            
            if frikortInt != 0 {
                let frikortString = "\nResterende frikort: " + getFormatted(number: frikortInt)
                return yearString + lønString + frikortString + feriePenge
            } else {
                return yearString + lønString + feriePenge
            }
        } else {
            let year = years[section]
            let lønString = "\nLøn: " + getFormatted(number: year.calculateTotalLøn())
            let feriePenge = "\nFeriepenge: " + getFormatted(number: Int(Double(year.calculateTotalLøn()) * 0.12))
            
            if frikortInt != 0 {
                let frikort = "\nResterende frikort: " + getFormatted(number: frikortInt - year.calculateTotalLøn())
                return year.getYearString() + lønString + frikort + feriePenge
            } else {
                return year.getYearString() + lønString + feriePenge
            }
        }
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

// MARK: - UIPickerView Delegate & DataSource

extension MainVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        
        let textField = lønPeriodeAlert!.textFields![0]
        textField.text = "D. \(selectedRow + 1)."
    }
}













