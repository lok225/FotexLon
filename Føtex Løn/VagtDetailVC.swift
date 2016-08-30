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
    
    var startDatePickerHidden = false
    var endDatePickerHidden = true
    
    var calendar: Calendar!
    
    var currentStartTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttributes(for: navigationController!.navigationBar)
        // hideKeyboardWhenTappedAround()
        self.standardHverdag = defaults.object(forKey: kStandardHverdage) as! [StandardVagt]
        self.standardLørdag = defaults.object(forKey: kStandardLørdag) as! [StandardVagt]
        self.standardSøndag = defaults.object(forKey: kStandardSøndag) as! [StandardVagt]
        self.calendar = Calendar.current
        
        if let _ = vagtToEdit {
            startDatePickerHidden = true
            title = "Ændre Vagt"
        }
        
        lblStartDate.textColor = UIColor.gray
        lblEndDate.textColor = UIColor.gray
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
        
        // setupSegControl()
        
        lblStartDate.text = formatDate(date: startTimePicker.date)
        lblEndDate.text = formatDate(date: endTimePicker.date)
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
            vagt.createNotifications()
            
            if let text = noteTextField.text {
                vagt.note = text
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
        // setupSegControl()
    }
    
    @IBAction func endTimePickerChanged(_ sender: UIDatePicker) {
        lblEndDate.text = formatDate(date: sender.date)
    }
    
    @IBAction func timeSegControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 4 {
            hideStartPicker(false)
            hideEndPicker(false)
        } else {
            hideStartPicker(false)
            hideEndPicker(true)
        }
    }
    
    // MARK: - Helper Functions
    
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
        startDatePickerHidden = hide
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func hideEndPicker(_ hide: Bool) {
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
        
        timesSegControl.removeAllSegments()
        
        switch weekday {
        case 0:
            var i = 0
            
            if standardSøndag.isEmpty {
                timesSegControl.insertSegment(withTitle: "Vælg selv", at: i, animated: true)
                timesSegControl.selectedSegmentIndex = i
            }
            
            for vagt in standardSøndag {
                timesSegControl.insertSegment(withTitle: vagt.getTimeIntervalString(), at: i, animated: true)
                i += 1
            }
        case 1...5:
            var i = 0
            
            if standardHverdag.isEmpty {
                timesSegControl.insertSegment(withTitle: "Vælg selv", at: i, animated: true)
                timesSegControl.selectedSegmentIndex = i
            }
            
            for vagt in standardHverdag {
                timesSegControl.insertSegment(withTitle: vagt.getTimeIntervalString(), at: i, animated: true)
                i += 1
            }
        case 6:
            var i = 0
            
            if standardLørdag.isEmpty {
                timesSegControl.insertSegment(withTitle: "Vælg selv", at: i, animated: true)
                timesSegControl.selectedSegmentIndex = i
            }
            
            for vagt in standardLørdag {
                timesSegControl.insertSegment(withTitle: vagt.getTimeIntervalString(), at: i, animated: true)
                i += 1
            }
        default:
            break
        }
    }

    func updateDatePicker(from segControl: UISegmentedControl, weekDay: Int) {
        
    }
    
//    func updateDatePickerFromSegmentControl(startTimes: [Int], endTimes: [Int], atIndex index: Int) {
//        let startTime = startTimePicker.date
//        
//        let newStartTimeComps = calendar.dateComponents([.year, .month, .day], from: startTime)
//        let newEndTimeComps = calendar.dateComponents([.year, .month, .day], from: startTime)
//    }
}

// MARK: - UITextFieldDelegate

extension VagtDetailVC: UITextFieldDelegate {
    
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













