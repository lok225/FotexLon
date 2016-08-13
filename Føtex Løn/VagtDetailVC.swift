//
//  VagtDetailVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 28/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import CoreData

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
    @IBOutlet weak var pauseSwitch: UISwitch!
    @IBOutlet weak var noteTextField: UITextField!
    
    // MARK: - Variabler
    
    weak var delegate: VagtDetailVCDelegate?
    
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!
    
    var vagtToEdit: Vagt?
    
    var startDatePickerHidden = false
    var endDatePickerHidden = true
    
    var calendar: Calendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttributes(for: navigationController!.navigationBar)
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
            pauseSwitch.isOn = vagt.pause
            if let note = vagt.note {
                noteTextField.text = note
            }
        } else {
            setInitialDates()
            pauseSwitch.isOn = true
            noteTextField.text = nil
        }
        
        lblStartDate.text = formatDate(date: startTimePicker.date)
        lblEndDate.text = formatDate(date: endTimePicker.date)
    }

    // MARK: - @IBActions
    
    @IBAction func doneBtnPressed(_ sender: UIBarButtonItem) {
        
        if let vagt = vagtToEdit {
            vagt.startTime = startTimePicker.date
            vagt.endTime = startTimePicker.date
            vagt.pause = pauseSwitch.isOn
            vagt.monthNumber = vagt.startTime.getMonthNumber(withYear: true)
            
            if let text = noteTextField.text {
                vagt.note = text
            }
            
            dataController.save()
            
            delegate?.vagtDetailVC(controller: self, didFinishEditingVagt: vagt)
            
        } else {
            let vagt = NSEntityDescription.insertNewObject(forEntityName: "Vagt", into: managedObjectContext) as! Vagt
            vagt.startTime = startTimePicker.date
            vagt.endTime = endTimePicker.date
            vagt.pause = pauseSwitch.isOn
            vagt.monthNumber = vagt.startTime.getMonthNumber(withYear: true)
            
            if let text = noteTextField.text {
                vagt.note = text
            }
            
            dataController.save()
            
            delegate?.vagtDetailVC(controller: self, didFinishAddingVagt: vagt)
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
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
    
    @IBAction func pauseSwitchChanged(_ sender: UISwitch) {
    }
    
    // MARK: - Helper Functions
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
}













