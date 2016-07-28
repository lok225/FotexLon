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
    
    var managedObjectContext: NSManagedObjectContext!
    var vagterFRC: NSFetchedResultsController<NSFetchRequestResult>!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Core Data Functions
    
    func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Vagt", in: self.managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor1 = SortDescriptor(key: "monthNumber", ascending: false)
        let sortDescriptor2 = SortDescriptor(key: "startTime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        
        vagterFRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "monthNumber", cacheName: "vagter")
        vagterFRC.delegate = self
        
        do {
            try vagterFRC.performFetch()
            
            if vagterFRC.fetchedObjects?.count == 0 {
                
                // Vagt eksisterer endnu ikke
//                
//                let vagt = NSEntityDescription.insertNewObject(forEntityName: "Vagt", into: managedObjectContext) as! Vagt
//                vagt.startTime = Date()
//                vagt.endTime = Date(timeInterval: 60, since: vagt.startTime as! Date)
//                vagt.monthNumber = 5
//                do {
//                    try managedObjectContext.save()
//                } catch {
//                    fatalError("Error: \(error)")
//                }
            }
        } catch {
            fatalError(String(error))
        }
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vagter.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        let vagt = vagter[indexPath.row]
        cell.textLabel?.text = vagt.getDateIntervalString()
        cell.detailTextLabel?.text = "\(Int(vagt.samletLon))"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let vagt = vagter[0]
        
        return vagt.getMonthString() + ", " + vagt.getYearString()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Gør så man ikke kan selecte row
        return nil
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            // tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.isEditing = false
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
}

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
    }
}

extension VagterVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

