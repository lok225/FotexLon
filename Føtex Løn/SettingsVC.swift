//
//  SettingsVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 14/08/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit

protocol SettingsVCDelegate: class {
    func settingsVCDidCancel(controller: VagtDetailVC)
    func settingsVCDidSave(controller: VagtDetailVC)
}

class SettingsVC: UITableViewController {
    
    @IBOutlet weak var ageSegControl: UISegmentedControl!
    @IBOutlet weak var lblGrundlon: UITextField!
    @IBOutlet weak var lblAftensats: UITextField!
    @IBOutlet weak var lblLordagssats: UITextField!
    @IBOutlet weak var lblSondagssats: UITextField!
    
    let defaults = UserDefaults.standard

    var youngWorker: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        setAttributes(for: navigationController!.navigationBar)
        
        youngWorker = defaults.bool(forKey: kYoungWorker)
        
        if youngWorker == true {
            ageSegControl.selectedSegmentIndex = 0
        } else {
            ageSegControl.selectedSegmentIndex = 1
        }
        
        setLonViews()
        
    }

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
    }
    
    // MARK: - @IBActions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        
        self.dismissKeyboard()
        
        let grundlon = Double(lblGrundlon.text!.replacingOccurrences(of: ",-", with: ""))
        let aftensSats = Double(lblAftensats.text!.replacingOccurrences(of: ",-", with: ""))
        let lordagsSats = Double(lblLordagssats.text!.replacingOccurrences(of: ",-", with: ""))
        let sondagsSats = Double(lblSondagssats.text!.replacingOccurrences(of: ",-", with: ""))
        
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
}

extension SettingsVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let position = textField.position(from: textField.beginningOfDocument, offset: textField.text!.characters.count - 2)!
        textField.selectedTextRange = textField.textRange(from: position, to: position)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
}



