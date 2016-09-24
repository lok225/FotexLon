//
//  VagtDetailVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 28/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import EventKit

protocol VagtDetailVCDelegate: class {
    func vagtDetailVCDidCancel(controller: VagtDetailVC)
    func vagtDetailVC(controller: VagtDetailVC, didFinishEditingVagt vagt: Vagt)
    func vagtDetailVC(controller: VagtDetailVC, didFinishAddingVagt vagt: Vagt)
}

class VagtDetailVC: UITableViewController {

    // MARK: - @IBOutlets
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    
    @IBOutlet weak var timesSegControl: UISegmentedControl!
    
    @IBOutlet weak var txtPause: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    
    // MARK: - Variabler
    
    let defaults = UserDefaults.standard
    
    var standardHverdag = [StandardVagt]()
    var standardLørdag = [StandardVagt]()
    var standardSøndag = [StandardVagt]()
    
    weak var delegate: VagtDetailVCDelegate?
    
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!
    
    var vagtToEdit: Vagt?
    
    var startDatePickerHidden = true
    var endDatePickerHidden = true
    
    var calendar: Calendar!
    
    var currentStartTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStandardVagter()
        
        setAttributes(for: navigationController!.navigationBar)
        setColors(forVagtDetailVC: self)
        
        self.calendar = Calendar.current
        
        if let _ = vagtToEdit {
            hideStartPicker(true)
            title = "Ændre Vagt"
        } else {
            hideStartPicker(false)
        }
        
        lblStartDate.text = formatDate(date: startTimePicker.date)
        lblEndDate.text = formatDate(date: endTimePicker.date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let vagt = vagtToEdit {
            startTimePicker.date = vagt.startTime
            endTimePicker.date = vagt.endTime
            txtPause.text = String(vagt.pause) + " min"
            if let note = vagt.note {
                noteTextField.text = note
            }
            currentStartTime = vagt.startTime
        } else {
            setInitialDates()
            txtPause.text = "30 min"
            noteTextField.text = nil
        }
        
        setupSegControl()
        
        lblStartDate.text = formatDate(date: startTimePicker.date)
        lblEndDate.text = formatDate(date: endTimePicker.date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vagterVC = segue.destination as! VagterVC
        vagterVC.dismissed = true
    }

    // MARK: - @IBActions
    
    @IBAction func doneBtnPressed(_ sender: UIBarButtonItem) {
        
        self.dismissKeyboard()
        
        if let vagt = vagtToEdit {
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(describing: vagt.startTime)])
            
            vagt.startTime = startTimePicker.date
            vagt.endTime = endTimePicker.date
            vagt.pause = Int(txtPause.text!.replacingOccurrences(of: " min", with: ""))!
            vagt.monthNumber = vagt.startTime.getMonthNumber(withYear: true)
            vagt.updateNotifications()
            
            if let text = noteTextField.text {
                vagt.note = text
            }
            
            if let _ = vagt.eventID {
                vagt.updateCalendarEvent()
            }
            
            dataController.save()
            
            delegate?.vagtDetailVC(controller: self, didFinishEditingVagt: vagt)
            
        } else {
            
            guard shouldCreateDate() == true else {
                
                let alert = UIAlertController(title: "Ugyldig Dato", message: "Sluttiden skal være efter efter starttiden", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            let vagt = NSEntityDescription.insertNewObject(forEntityName: "Vagt", into: managedObjectContext) as! Vagt
            vagt.startTime = startTimePicker.date
            vagt.endTime = endTimePicker.date
            vagt.pause = Int(txtPause.text!.replacingOccurrences(of: " min", with: ""))!
            vagt.monthNumber = vagt.startTime.getMonthNumber(withYear: true)
            vagt.createID()
            vagt.createNotifications()
            vagt.createCalendarEvent()
            
            if let text = noteTextField.text {
                vagt.note = text
            }
            
            dataController.save()
            
            delegate?.vagtDetailVC(controller: self, didFinishAddingVagt: vagt)
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        self.dismissKeyboard()
        delegate?.vagtDetailVCDidCancel(controller: self)
    }

    @IBAction func startTimePickerChanged(_ sender: UIDatePicker) {
        
        let startDate = startTimePicker.date
        let endDate = endTimePicker.date
        let dateInterval = startDate.differenceInMins(withDate: endDate)
        
        var startComps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
        let endComps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endDate)
        
        if dateInterval <= 0 {
            endTimePicker.date = Date(timeInterval: 10800, since: startDate)
        } else {
            startComps.hour = endComps.hour
            startComps.minute = endComps.minute
            let date = calendar.date(from: startComps)!
            endTimePicker.date = date
        }
        
        updateDateLabels()
        
        setupSegControl()
    }
    
    @IBAction func endTimePickerChanged(_ sender: UIDatePicker) {
        lblEndDate.text = formatDate(date: sender.date)
    }
    
    @IBAction func timeSegControlChanged(_ sender: UISegmentedControl) {
        
        if sender.titleForSegment(at: 0) == "Setup standard vagter" {
            let alert = UIAlertController(title: "Setup standard vagter", message: "Gå til indstillinger for at lave dine setup vagter.\nPS. Det vil gøre det langt hurtigere at lave vagter", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Senere", style: .cancel, handler: nil)
            let settingsAction = UIAlertAction(title: "Gå til indstillinger", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "unwindToVagter", sender: nil)
            })
            alert.addAction(cancelAction)
            alert.addAction(settingsAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            updateDatePickers(from: sender, weekDay: calendar.component(.weekday, from: startTimePicker.date))
        }
    }
    
    // MARK: - Helper Functions
    
    func setStandardVagter() {
        
        let standardHverdagData = defaults.object(forKey: kStandardHverdage) as! Data
        let standardLørdagData = defaults.object(forKey: kStandardLørdag) as! Data
        let standardSøndagData = defaults.object(forKey: kStandardSøndag) as! Data
        
        standardHverdag = NSKeyedUnarchiver.unarchiveObject(with: standardHverdagData) as! [StandardVagt]
        standardLørdag = NSKeyedUnarchiver.unarchiveObject(with: standardLørdagData) as! [StandardVagt]
        standardSøndag = NSKeyedUnarchiver.unarchiveObject(with: standardSøndagData) as! [StandardVagt]
        
    }
    
    func shouldCreateDate() -> Bool {
        
        let startDate = startTimePicker.date
        let endDate = endTimePicker.date
        let dateInterval = startDate.differenceInMins(withDate: endDate)
        
        if dateInterval <= 0 {
            return false
        } else {
            return true
        }
    }
    
    func hideStartPicker(_ hide: Bool) {
        if hide {
            lblStartDate.textColor = UIColor.black
        } else {
            lblStartDate.textColor = self.view.tintColor
        }
        
        startDatePickerHidden = hide
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func hideEndPicker(_ hide: Bool) {
        if hide {
            lblEndDate.textColor = UIColor.black
        } else {
            lblEndDate.textColor = self.view.tintColor
        }
        
        endDatePickerHidden = hide
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func updateDateLabels() {
        lblStartDate.text = formatDate(date: startTimePicker.date)
        lblEndDate.text = formatDate(date: endTimePicker.date)
    }
    
    func formatDate(date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: date)
        
        return dateString
    }
    
    func setInitialDates() {
        let date = Date(timeIntervalSinceNow: 60*40)
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let numberOfTimes = components.minute! / 15
        let newMinute = numberOfTimes * 15
        components.minute! = newMinute
        
        startTimePicker.date = Calendar.current.date(from: components)!
        endTimePicker.date = Date(timeInterval: 10800, since: startTimePicker.date)
    }

}

// MARK: - UITableViewDelegate

extension VagtDetailVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        noteTextField.resignFirstResponder()
        tableView.cellForRow(at: indexPath)!.setSelected(false, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            
            if startDatePickerHidden {
                hideStartPicker(false)
            } else {
                hideStartPicker(true)
            }
            
        } else if indexPath.section == 2 && indexPath.row == 0 {
            if endDatePickerHidden {
                hideEndPicker(false)
            } else {
                hideEndPicker(true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if startDatePickerHidden && indexPath.section == 1 && indexPath.row == 1 {
            return 0
        } else if endDatePickerHidden && indexPath.section == 2 && indexPath.row == 1{
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

}

// MARK: - Segment Control Functions

extension VagtDetailVC {
    
    func setupSegControl() {
        let weekday = calendar.component(.weekday, from: startTimePicker.date)
        var standardVagter = [StandardVagt]()
        
        timesSegControl.removeAllSegments()
        
        switch weekday {
        case 1:
            standardVagter = standardSøndag
        case 2...6:
            standardVagter = standardHverdag
        case 7:
            standardVagter = standardLørdag
        default:
            break
        }
        
        if standardVagter.count != 0 {
            timesSegControl.isMomentary = false
            var i = 0
            for vagt in standardVagter {
                timesSegControl.insertSegment(withTitle: vagt.getTimeIntervalString(), at: i, animated: false)
                i += 1
            }
        } else {
            timesSegControl.isMomentary = true
            timesSegControl.insertSegment(withTitle: "Setup standard vagter", at: 0, animated: false)
        }
        
        
    }

    func updateDatePickers(from segControl: UISegmentedControl, weekDay: Int) {
        
        var standardVagt: StandardVagt!
        
        let index = segControl.selectedSegmentIndex
        
        switch weekDay {
        case 1:
            standardVagt = standardSøndag[index]
        case 2...6:
            standardVagt = standardHverdag[index]
        case 7:
            standardVagt = standardLørdag[index]
        default:
            break
        }
        
        var startComps = calendar.dateComponents(in: .current, from: startTimePicker.date)
        let standardStartComps = calendar.dateComponents(in: .current, from: standardVagt.startTime)
        
        startComps.hour = standardStartComps.hour
        startComps.minute = standardStartComps.minute
        
        var endComps = calendar.dateComponents(in: .current, from: endTimePicker.date)
        let standardEndComps = calendar.dateComponents(in: .current, from: standardVagt.endTime)
        
        endComps.hour = standardEndComps.hour
        endComps.minute = standardEndComps.minute
        
        startTimePicker.date = calendar.date(from: startComps)!
        endTimePicker.date = calendar.date(from: endComps)!
        txtPause.text = String(standardVagt.pause) + " min"
        
        updateDateLabels()
    }
}

// MARK: - UITextFieldDelegate

extension StandardVagtDetailVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            let position = textField.position(from: textField.beginningOfDocument, offset: textField.text!.characters.count - 4)!
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}













