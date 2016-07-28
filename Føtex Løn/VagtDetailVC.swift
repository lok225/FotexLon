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
    
    var managedObjectContext: NSManagedObjectContext!
    
    var vagtToEdit: Vagt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - @IBActions
    
    @IBAction func doneBtnPressed(_ sender: UIBarButtonItem) {
        
        if let vagt = vagtToEdit {
            vagt.startTime = startTimePicker.date
            vagt.endTime = startTimePicker.date
            vagt.withPause = pauseSwitch.isOn
            if let text = noteTextField.text {
                vagt.note = text
            }
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("Error: \(error)")
            }
            
            delegate?.vagtDetailVC(controller: self, didFinishEditingVagt: vagt)
        } else {
            // let vagt = NSEntityDescription.insertNewObjectForEntityForName("Vagt", inManagedObjectContext: managedObjectContext) as! Vagt
            let vagt = Vagt(startTime: startTimePicker.date, endTime: endTimePicker.date, pause: pauseSwitch.isOn)
            vagt.startTime = startTimePicker.date
            vagt.endTime = startTimePicker.date
            vagt.withPause = pauseSwitch.isOn
            if let text = noteTextField.text {
                vagt.note = text
            }
            
//            do {
//                try managedObjectContext.save()
//            } catch {
//                fatalError("Error: \(error)")
//            }
            
            delegate?.vagtDetailVC(controller: self, didFinishAddingVagt: vagt)
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        delegate?.vagtDetailVCDidCancel(controller: self)
    }

    @IBAction func startTimePickerChanged(_ sender: UIDatePicker) {
    }
    
    @IBAction func endTimePickerChanged(_ sender: UIDatePicker) {
    }
    
    @IBAction func timeSegControlChanged(_ sender: UISegmentedControl) {
    }
    
    @IBAction func pauseSwitchChanged(_ sender: UISwitch) {
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */



}
