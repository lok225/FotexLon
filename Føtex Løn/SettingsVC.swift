//
//  SettingsVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 14/08/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import UserNotifications

protocol SettingsVCDelegate: class {
    func settingsVCDidCancel(controller: VagtDetailVC)
    func settingsVCDidSave(controller: VagtDetailVC)
}

class SettingsVC: UITableViewController {
    
    @IBOutlet weak var ageSegControl: UISegmentedControl!
    @IBOutlet weak var themeSegControl: UISegmentedControl!
    @IBOutlet weak var lblGrundlon: UITextField!
    @IBOutlet weak var lblAftensats: UITextField!
    @IBOutlet weak var lblLordagssats: UITextField!
    @IBOutlet weak var lblSondagssats: UITextField!
    @IBOutlet weak var lblFrikort: UITextField!
    @IBOutlet weak var lblTrækprocent: UITextField!
    
    @IBOutlet weak var lblNotifications: UILabel!
    
    @IBOutlet weak var lblTema: UILabel!
    
    @IBOutlet weak var calendarSwitch: UISwitch!
    
    let defaults = UserDefaults.standard
    
    var appDel: AppDelegate!

    var vagterFRC: NSFetchedResultsController<NSFetchRequestResult>!
    
    var youngWorker: Bool!
    var notifications: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate! as! AppDelegate
        
        youngWorker = defaults.bool(forKey: kYoungWorker)
        
        if youngWorker == true {
            ageSegControl.selectedSegmentIndex = 0
        } else {
            ageSegControl.selectedSegmentIndex = 1
        }
        
        setLonViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setAttributes(for: navigationController!.navigationBar)
        notifications = defaults.object(forKey: kNotifications) as! [Int]
        setNotificationsView()
        setTemaView()
        calendarSwitch.isOn = defaults.bool(forKey: kAddToCalendar)
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            calendarSwitch.isEnabled = true
        case .denied:
            calendarSwitch.isOn = false
        case .notDetermined:
            break
        case .restricted:
            calendarSwitch.isOn = false
            calendarSwitch.isEnabled = false
        }
        
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "standardVCSegue":
            if let _ = sender as? Int {
                
                let vc = segue.destination as! StandardVagterVC
                
                switch sender as! Int {
                case 0:
                    vc.standardVagterInt = 0
                case 1:
                    vc.standardVagterInt = 1
                case 2:
                    vc.standardVagterInt = 2
                default:
                    break
                }
            }
        case "notificationsSegue":
            let destVC = segue.destination as! NotificationsVC
            destVC.vagterFRC = self.vagterFRC
        default:
            break
        }
        
        
    }
    
    // MARK: - Views

    func setLonViews() {
        if youngWorker == true {
            lblGrundlon.text = String(defaults.double(forKey: kYoungBasisLon)).replacingOccurrences(of: ".", with: ",") + ",-"
            lblAftensats.text = String(defaults.double(forKey: kYoungAftensSats)).replacingOccurrences(of: ".", with: ",") + ",-"
            lblLordagssats.text = String(defaults.double(forKey: kYoungLordagsSats)).replacingOccurrences(of: ".", with: ",") + ",-"
            lblSondagssats.text = String(defaults.double(forKey: kYoungSondagsSats)).replacingOccurrences(of: ".", with: ",") + ",-"
        } else {
            lblGrundlon.text = String(defaults.double(forKey: kOldBasisLon)).replacingOccurrences(of: ".", with: ",") + ",-"
            lblAftensats.text = String(defaults.double(forKey: kOldAftensSats)).replacingOccurrences(of: ".", with: ",") + ",-"
            lblLordagssats.text = String(defaults.double(forKey: kOldLordagsSats)).replacingOccurrences(of: ".", with: ",") + ",-"
            lblSondagssats.text = String(defaults.double(forKey: kOldSondagsSats)).replacingOccurrences(of: ".", with: ",") + ",-"
        }
        
        lblFrikort.text = getFormatted(number: defaults.integer(forKey: kFrikort))
    }
    
    func setNotificationsView() {
        
        var thisString = ""
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                print("authed")
                for not in self.notifications {
                    if thisString.isEmpty {
                        thisString.append(not.getNotificationsDetailString())
                        print("Nu")
                        print(not.getNotificationsDetailString())
                    } else {
                        thisString += ", \(not.getNotificationsDetailString().lowercased())"
                    }
                }
            case .denied:
                thisString = "Ingen"
            case .notDetermined:
                thisString = "Ingen"
            }
            
            self.lblNotifications.text = thisString
            self.lblNotifications.textColor = UIColor.darkGray
        }
    }
    
    func setTemaView() {
        let shop = Shop(rawValue: UserDefaults.standard.integer(forKey: kTheme))!
        
        var temaString: String!
        
        switch shop {
        case .ingen:
            temaString = "Intet"
        case .føtex:
            temaString = "Blå"
        case .fakta:
            temaString = "Rød"
        case .bio:
            temaString = "Sort & Grå"
        case .teal:
            temaString = "Teal"
        }
        
        lblTema.text = temaString
    }
    
    // MARK: - @IBActions
    
    @IBAction func reset(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Advarsel", message: "Er du sikker på du vil slette alle brugerdefinerede indstillinger", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { (action) in
            self.defaults.set([0], forKey: kNotifications)
            
            self.defaults.set(63.86, forKey: kYoungBasisLon)
            self.defaults.set(12.6, forKey: kYoungAftensSats)
            self.defaults.set(22.38, forKey: kYoungLordagsSats)
            self.defaults.set(25.3, forKey: kYoungSondagsSats)
            self.defaults.set(112.42, forKey: kOldBasisLon)
            self.defaults.set(25.2, forKey: kOldAftensSats)
            self.defaults.set(44.75, forKey: kOldLordagsSats)
            self.defaults.set(50.6, forKey: kOldSondagsSats)
            
            self.defaults.set(NSKeyedArchiver.archivedData(withRootObject: [StandardVagt]()), forKey: kStandardHverdage)
            self.defaults.set(NSKeyedArchiver.archivedData(withRootObject: [StandardVagt]()), forKey: kStandardLørdag)
            self.defaults.set(NSKeyedArchiver.archivedData(withRootObject: [StandardVagt]()), forKey: kStandardSøndag)
            
            self.defaults.synchronize()
            
            self.dismissKeyboard()
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        alert.addAction(resetAction)
        
        present(alert, animated: true, completion: nil)
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        
        self.dismissKeyboard()
        
        let grundlon = Double(lblGrundlon.text!.replacingOccurrences(of: ",-", with: ""))
        let aftensSats = Double(lblAftensats.text!.replacingOccurrences(of: ",-", with: ""))
        let lordagsSats = Double(lblLordagssats.text!.replacingOccurrences(of: ",-", with: ""))
        let sondagsSats = Double(lblSondagssats.text!.replacingOccurrences(of: ",-", with: ""))
        let frikort = Int(lblFrikort.text!.replacingOccurrences(of: ",-", with: ""))
        
        if ageSegControl.selectedSegmentIndex == 0 {
            youngWorker = true
            defaults.set(grundlon, forKey: kYoungBasisLon)
            defaults.set(aftensSats, forKey: kYoungAftensSats)
            defaults.set(lordagsSats, forKey: kYoungLordagsSats)
            defaults.set(sondagsSats, forKey: kYoungSondagsSats)
        } else {
            youngWorker = false
            defaults.set(grundlon, forKey: kOldBasisLon)
            defaults.set(aftensSats, forKey: kOldAftensSats)
            defaults.set(lordagsSats, forKey: kOldLordagsSats)
            defaults.set(sondagsSats, forKey: kOldSondagsSats)
        }
        
        defaults.set(youngWorker, forKey: kYoungWorker)
        defaults.set(calendarSwitch.isOn, forKey: kAddToCalendar)
        defaults.set(frikort, forKey: kFrikort)
        
        defaults.synchronize()
        
        appDel.setGlobalColors()
        
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func ageSegChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            youngWorker = true
        } else {
            youngWorker = false
        }
        
        setLonViews()
    }
    
    @IBAction func calendarSwitchChanged(_ sender: UISwitch) {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            break
        case .denied:
            calendarSwitch.isOn = false
            let alert = UIAlertController(title: "Mangler tilladelse", message: "Gå til indstillinger og giv appen tilladelse til at oprette kalender-events", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Annuller", style: .cancel, handler: nil)
            let settingsAction = UIAlertAction(title: "Gå til indstillinger", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            })
            alert.addAction(cancelAction)
            alert.addAction(settingsAction)
            self.present(alert, animated: true, completion: nil)
        case .notDetermined:
            break
        case .restricted:
            calendarSwitch.isOn = false
            calendarSwitch.isEnabled = false
        }
    }
}

extension SettingsVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
                    switch settings.authorizationStatus {
                    case .authorized:
                        break
                    case .denied:
                        let alert = UIAlertController(title: "Mangler tilladelse", message: "Gå til indstillinger og giv appen tilladelse til at sende notifikationer", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "Annuller", style: .cancel, handler: nil)
                        let settingsAction = UIAlertAction(title: "Gå til indstillinger", style: .default, handler: { (action) in
                            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                        })
                        alert.addAction(cancelAction)
                        alert.addAction(settingsAction)
                        self.present(alert, animated: true, completion: nil)
                    case .notDetermined:
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: { (granted, error) in
                            if granted && error == nil {
                                self.setNotificationsView()
                            }
                        })
                    }
                })
            }
        case 2:
            tableView.cellForRow(at: indexPath)!.setSelected(false, animated: true)
            
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: kStandardVagtSegue, sender: 0)
            case 1:
                performSegue(withIdentifier: kStandardVagtSegue, sender: 1)
            case 2:
                performSegue(withIdentifier: kStandardVagtSegue, sender: 2)
            default:
                break
            }
        case 3:
            let alert = UIAlertController(title: nil, message: "Er du sikker på du vil logge af?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Annuller", style: .cancel, handler: nil)
            let logOffAction = UIAlertAction(title: "Log af", style: .destructive, handler: { (action) in
                self.defaults.set(false, forKey: kIsLoggedIn)
                self.defaults.synchronize()
                
                self.dismiss(animated: false) {
                    self.appDel.showLoginScreen(animated: true)
                }
                
                
            })
            alert.addAction(cancelAction)
            alert.addAction(logOffAction)
            
            present(alert, animated: true, completion: nil)
            
        default:
            break
        }
    }
}

extension SettingsVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.tag == 40 {
            let position = textField.position(from: textField.beginningOfDocument, offset: textField.text!.characters.count - 1)!
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        } else {
            let position = textField.position(from: textField.beginningOfDocument, offset: textField.text!.characters.count - 2)!
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField.tag == 40 {
            if Int(textField.text!.replacingOccurrences(of: "%", with: ""))! > 100 {
                textField.text = String(100) + "%"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
}



