//
//  VagterVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 27/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import CoreData

class VagterVC: UITableViewController {
    
    let calendar = Calendar.current
    
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!
    var vagterFRC: NSFetchedResultsController<NSFetchRequestResult>!
    
    var dateAlert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()

        setColors()
        setAttributes(for: navigationController!.navigationBar)
        
        setupFetchedResultsController()
        
        print(dataController)
        print(managedObjectContext)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let destinationVC = navController.viewControllers[0] as! VagtDetailVC
        
        if let indexPath = sender as? IndexPath {
            destinationVC.vagtToEdit = vagterFRC.object(at: indexPath) as? Vagt
        }
        destinationVC.delegate = self
        destinationVC.dataController = self.dataController
        destinationVC.managedObjectContext = self.managedObjectContext
    }
    
    // MARK: - Colors
    
    private func setColors() {
        tableView.backgroundColor = fotexBlue
    }
    
    private func setColors(for cell: UITableViewCell) {
        cell.backgroundColor = fotexBlue
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.lightText
        
        let cellView = UIView()
        cellView.backgroundColor = gothicBlue
        cell.selectedBackgroundView = cellView
    }
    
    // MARK: - Core Data Functions
    
    func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Vagt", in: self.managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "monthNumber", ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: "startTime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        
        vagterFRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "monthNumber", cacheName: "vagter")
        vagterFRC.delegate = self
        
        do {
            try vagterFRC.performFetch()
            
            if vagterFRC.fetchedObjects?.count == 0 {
                
                // Vagt eksisterer endnu ikke
                
                let vagt = NSEntityDescription.insertNewObject(forEntityName: "Vagt", into: managedObjectContext) as! Vagt
                vagt.startTime = Date()
                vagt.endTime = Date(timeInterval: 60, since: vagt.startTime)
                vagt.pause = 0
                vagt.monthNumber = vagt.startTime.getMonthNumber(withYear: true)
                
                dataController.save()
            }
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    func fetchObjects() {
        do {
            try vagterFRC.performFetch()
            
            if vagterFRC.fetchedObjects?.count == 0 {
                
                // Vagt eksisterer endnu ikke
                
                let vagt = NSEntityDescription.insertNewObject(forEntityName: "Vagt", into: managedObjectContext) as! Vagt
                vagt.startTime = Date()
                vagt.endTime = Date(timeInterval: 60, since: vagt.startTime)
                vagt.pause = 30
                vagt.monthNumber = vagt.startTime.getMonthNumber(withYear: true)
                
                dataController.save()
            }
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    // MARK: - Helper Functions
    
    func configure(cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let vagt = vagterFRC.object(at: indexPath) as! Vagt
        
        setColors(for: cell)
        
        if indexPath.row == 0 {
            let attString = NSMutableAttributedString(string: vagt.getDateIntervalString().capitalized)
            attString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attString.length))
            
            let attString2 = NSMutableAttributedString(string: "\(Int(vagt.samletLon)),-")
            attString2.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attString2.length))
            
            cell.textLabel?.attributedText = attString
            cell.textLabel?.textColor = UIColor.lightGray
            
            cell.detailTextLabel?.attributedText = attString2
            cell.detailTextLabel?.textColor = UIColor.lightGray
        } else {
            cell.textLabel?.text = vagt.getDateIntervalString().capitalized
            cell.detailTextLabel?.text = "\(Int(vagt.samletLon)),-"
        }
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))
        longPressGR.minimumPressDuration = 1.0
        cell.addGestureRecognizer(longPressGR)
        
    }
    
}

// MARK: - UITableViewDataSource

extension VagterVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return vagterFRC.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = vagterFRC.sections![section]
        
        return section.objects!.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "vagtCell")
        
        configure(cell: cell, atIndexPath: indexPath)
        
        return cell
    }
     
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     
        let section = vagterFRC.sections![section]
        let monthString = section.name
        let monthNumber = Double(monthString)!
        
        let month = Month(fetchedRC: vagterFRC, monthNumber: monthNumber)
     
        return month.getMonthString() + " " + month.getYearString()
    }
     
    
    
}

// MARK: - UITableViewDelegate 

extension VagterVC {
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.alpha = 0.85
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.performSegue(withIdentifier: kVagtDetailSegue, sender: indexPath)
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let vagt = vagterFRC.object(at: indexPath) as! Vagt
            
            managedObjectContext.delete(vagt)
            
            dataController.save()
        }
    }

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func cellLongPressed(longPressGR: UILongPressGestureRecognizer) {
        print("Pressed")
        
        let indexPath = self.tableView.indexPathForRow(at: longPressGR.location(in: self.tableView))!
        let vagt = self.vagterFRC.object(at: indexPath) as! Vagt
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Slet", style: .destructive) { (_) in
            self.managedObjectContext.delete(vagt)
            
            self.dataController.save()
        }
        
        let dublicateAction = UIAlertAction(title: "Dubler", style: .default) { (_) in
            
            self.dateAlert = UIAlertController(title: "Vælg dato", message: nil, preferredStyle: .alert)
            
            var datePicker: UIDatePicker!
            
            let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                let newVagt = NSEntityDescription.insertNewObject(forEntityName: "Vagt", into: self.managedObjectContext) as! Vagt
                
                let newComps = self.calendar.dateComponents([.year, .month, .day], from: datePicker.date)
                var startComps = self.calendar.dateComponents([.hour, .minute], from: vagt.startTime)
                startComps.year = newComps.year
                startComps.month = newComps.month
                startComps.day = newComps.day
                
                var endComps = self.calendar.dateComponents([.hour, .minute], from: vagt.endTime)
                endComps.year = newComps.year
                endComps.month = newComps.month
                endComps.day = newComps.day
                
                newVagt.startTime = self.calendar.date(from: startComps)
                newVagt.endTime = self.calendar.date(from: endComps)
                newVagt.pause = vagt.pause
                newVagt.monthNumber = newVagt.startTime.getMonthNumber(withYear: true)
                
                self.dataController.save()
            })
            
            self.dateAlert!.addAction(action)
            self.dateAlert!.addTextField(configurationHandler: { (textField) in
                datePicker = UIDatePicker()
                datePicker.datePickerMode = .date
                datePicker.addTarget(self, action: #selector(self.alertPickerChanged), for: .valueChanged)
                textField.inputView = datePicker
            })
            self.present(self.dateAlert!, animated: true, completion: nil)
            
            /*
            let newVagt = NSEntityDescription.insertNewObject(forEntityName: "Vagt", into: self.managedObjectContext) as! Vagt
            newVagt.startTime = vagt.startTime
            newVagt.endTime = vagt.endTime
            newVagt.pause = vagt.pause
            newVagt.monthNumber = newVagt.startTime.getMonthNumber(withYear: true)
            */
 
            self.dataController.save()
        }
        
        actionSheet.addAction(dublicateAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func alertPickerChanged(sender: UIDatePicker) {
        let textField = dateAlert!.textFields![0]
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        textField.text = formatter.string(from: sender.date)
    }
    
}

// MARK: - VagtDetailVCDelegate

extension VagterVC: VagtDetailVCDelegate {
    
    func vagtDetailVCDidCancel(controller: VagtDetailVC) {
        dismiss(animated: true, completion: nil)
    }
    
    // TODO: Færdiggør protokollen
    
    func vagtDetailVC(controller: VagtDetailVC, didFinishEditingVagt vagt: Vagt) {
        dismiss(animated: true, completion: nil)
    }
    
    func vagtDetailVC(controller: VagtDetailVC, didFinishAddingVagt vagt: Vagt) {
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension VagterVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            configure(cell: tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
        
        tableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
        
        tableView.reloadData()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
    
}

