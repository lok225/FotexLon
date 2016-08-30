//
//  StandardVagtDetailVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 24/08/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit

protocol StandardVagtDetailVCDelegate: class {
    func standardVagtDetailVCDidCancel(controller: StandardVagtDetailVC)
    func standardVagtDetailVC(controller: StandardVagtDetailVC, didFinishEditingVagt vagt: StandardVagt)
    func standardVagtDetailVC(controller: StandardVagtDetailVC, didFinishAddingVagt vagt: StandardVagt)
}

class StandardVagtDetailVC: UITableViewController {
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var txtPause: UITextField!
    
    weak var delegate: StandardVagtDetailVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setAttributes(for: navigationController!.navigationBar)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        let standardVagt = StandardVagt(startTime: startTimePicker.date, endTime: endTimePicker.date, pause: Int(txtPause.text!.replacingOccurrences(of: " min", with: ""))!)
        
        delegate?.standardVagtDetailVC(controller: self, didFinishAddingVagt: standardVagt)
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        delegate?.standardVagtDetailVCDidCancel(controller: self)
    }
    
}
