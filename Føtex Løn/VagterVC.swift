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
    
    var næsteVagt: Vagt?
    
    var dismissed: Bool = false
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setColors(forTableView: tableView)
        setAttributes(for: navigationController!.navigationBar)
        do {
            try vagterFRC.performFetch()
        } catch {
            print(error)
        }
        tableView.reloadData()
        
        if dismissed {
            self.dismissed = false
            goToSettings()
        }
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
    
    // MARK: - @IBActions
    
    @IBAction func dismissVC(segue:UIStoryboardSegue) {}
    
    @IBAction func toDate(_ sender: UIBarButtonItem) {
        goToCurrentMonth()
    }
    
    // MARK: - Core Data Functions
    
    func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Vagt", in: self.managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "monthNumber", ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: "startTime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        vagterFRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "monthNumber", cacheName: "vagter")
        vagterFRC.delegate = self
        
        do {
            try vagterFRC.performFetch()
            
            if vagterFRC.fetchedObjects?.count == 0 {
                
                // Vagt eksisterer endnu ikke
                
                /*
                let vagt = NSEntityDescription.insertNewObject(forEntityName: "Vagt", into: managedObjectContext) as! Vagt
                vagt.startTime = Date()
                vagt.endTime = Date(timeInterval: 60, since: vagt.startTime)
                vagt.pause = 0
                vagt.monthNumber = vagt.startTime.getMonthNumber(withYear: true)
                
                dataController.save()
 */
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
    
    /*
    func setNæsteVagt() {
        
        var vagter = vagterFRC.fetchedObjects as! [Vagt]
        vagter = vagter.sorted(by: { $0.startTime.compare($1.startTime) == .orderedAscending })
        
        var filteredVagter = [Vagt]()
        
        for vagt in vagter {
            let date = Date()
            let order = date.compare(vagt.startTime)
            
            if order == .orderedAscending {
                filteredVagter.append(vagt)
            }
        }
        
        næsteVagt = filteredVagter.first
        
        let cell = tableView.cellForRow(at: vagterFRC.indexPath(forObject: næsteVagt!)!)!
        cell.backgroundColor = UIColor.lightGray
    }
    */
    
    func goToSettings() {
        // let tabBarCon = self.tabBarController!
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let tabBar = appDel.window?.rootViewController as! UITabBarController
        tabBar.selectedIndex = 0
        let mainNC = tabBar.viewControllers![0] as! UINavigationController
        let mainVC = mainNC.topViewController as! MainVC
        mainVC.fromDetailVC = true
        mainVC.performSegue(withIdentifier: kSettingsSegue, sender: nil)
    }
    
    func goToCurrentMonth() {
        if tableView.visibleCells.count != 0 {
            let indexPath = IndexPath(row: 0, section: currentMonthIndex)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func configure(cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let vagt = vagterFRC.object(at: indexPath) as! Vagt
        
        setColors(forCell: cell)
        
        if vagt.active == false {
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
            // cell.detailTextLabel?.text = "\(Int(vagt.samletLon)),-"
            cell.detailTextLabel?.text = getFormatted(number: Int(vagt.samletLon))
        }
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))
        cell.addGestureRecognizer(longPressGR)
        
    }
    
}

// MARK: - UITableViewDataSource

extension VagterVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if vagterFRC.sections!.count == 0 {
            
            let view = UIView(frame: CGRect(
                x: 0,
                y: 0,
                width: tableView.bounds.size.width,
                height: tableView.bounds.size.height
            ))
            
            let label = UILabel(frame: CGRect(
                x: 20,
                y: 20,
                width: view.bounds.size.width - 40,
                height: view.bounds.size.height - 40
                )
            )
            
            label.text = "Der er ingen vagter ☹️" + "\n\n" + "Tryk '+' i højre hjørne for at tilføje en vagt."
            label.textAlignment = .center
            label.numberOfLines = 0
            label.textColor = UIColor.white
            //label.sizeToFit()
            
            view.addSubview(label)
            
            tableView.backgroundView = view
            tableView.separatorStyle = .none
            
            return 0
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            return vagterFRC.sections!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = vagterFRC.sections![section]
        
        return section.numberOfObjects
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
     
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
}

// MARK: - UITableViewDelegate 

extension VagterVC {
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        setColors(forTableViewHeader: view as! UITableViewHeaderFooterView)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.performSegue(withIdentifier: kVagtDetailSegue, sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let vagt = self.vagterFRC.object(at: indexPath) as! Vagt
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Slet") { (action, indexPath) in
            tableView.isEditing = false
            
            self.dataController.delete(vagt: vagt)
        }
        
        let inactiveAction: UITableViewRowAction!
        
        if vagt.active {
            inactiveAction = UITableViewRowAction(style: .normal, title: "Byttet væk") { (action, indexPath) in
                
                let alert = UIAlertController(title: "Tilføj note", message: "Hvem har du byttet vagten til?", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "F.eks. 'Byttet til Camilla'"
                    textField.text = vagt.note
                    textField.autocapitalizationType = .sentences
                })
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    vagt.note = alert.textFields?.first?.text
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
                
                tableView.isEditing = false
                
                let time = DispatchTime.now() + .milliseconds(500)
                DispatchQueue.main.asyncAfter(deadline: time, execute: { 
                    vagt.active = !vagt.active
                    self.dataController.save()
                })
                
            }
        } else {
            inactiveAction = UITableViewRowAction(style: .normal, title: "Fået tilbage") { (action, indexPath) in
                
                if let note = vagt.note {
                    if note.characters.count > 0 {
                        let alert = UIAlertController(title: "Behold eller slet note", message: "Hvad vil du gøre med den tilhørende note?", preferredStyle: .alert)
                        let keepAction = UIAlertAction(title: "Behold", style: .default, handler: nil)
                        let deleteAction = UIAlertAction(title: "Slet", style: .destructive, handler: { (action) in
                            vagt.note = nil
                        })
                        alert.addAction(keepAction)
                        alert.addAction(deleteAction)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                tableView.isEditing = false
                
                let time = DispatchTime.now() + .milliseconds(500)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    vagt.active = !vagt.active
                    self.dataController.save()
                })
            }
        }
        
        return [deleteAction, inactiveAction]
    }
    
    func cellLongPressed(longPressGR: UILongPressGestureRecognizer) {
        
        let indexPath = self.tableView.indexPathForRow(at: longPressGR.location(in: self.tableView))!
        let vagt = self.vagterFRC.object(at: indexPath) as! Vagt
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Annuller", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Slet", style: .destructive) { (_) in
            
            self.dataController.delete(vagt: vagt)
        }
        
        let dublicateAction = UIAlertAction(title: "Dubler", style: .default) { (_) in
            
            self.dateAlert = UIAlertController(title: "Vælg dato", message: nil, preferredStyle: .alert)
            
            var datePicker: UIDatePicker!
            
            let annullerAction = UIAlertAction(title: "Annuller", style: .cancel, handler: nil)
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
                
                newVagt.createNotifications()
                newVagt.createCalendarEvent()
                newVagt.createID()
                
                self.dataController.save()
            })
            
            self.dateAlert?.addAction(annullerAction)
            self.dateAlert!.addAction(action)
            self.dateAlert!.addTextField(configurationHandler: { (textField) in
                datePicker = UIDatePicker()
                datePicker.datePickerMode = .date
                textField.text = self.getFormattedDate(datePicker.date)
                textField.autocapitalizationType = .sentences
                datePicker.addTarget(self, action: #selector(self.alertPickerChanged), for: .valueChanged)
                textField.inputView = datePicker
            })
            self.present(self.dateAlert!, animated: true, completion: nil)
        }
        
        actionSheet.addAction(dublicateAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func alertPickerChanged(sender: UIDatePicker) {
        let textField = dateAlert!.textFields![0]
        textField.text = getFormattedDate(sender.date)
    }
    
    func getFormattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
}

// MARK: - VagtDetailVCDelegate

extension VagterVC: VagtDetailVCDelegate {
    
    func vagtDetailVCDidCancel(controller: VagtDetailVC) {
        dismiss(animated: true, completion: nil)
    }
    
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
            if let cell = tableView.cellForRow(at: indexPath!) {
                configure(cell: cell, atIndexPath: indexPath!)
            }

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

