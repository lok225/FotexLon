//
//  MainVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 22/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var lblFøtexTotalLøn: UILabel!
    @IBOutlet weak var lblFøtexTillæg: UILabel!
    @IBOutlet weak var lblFøtexTimer: UILabel!
    @IBOutlet weak var lblFøtexVagter: UILabel!
    
    @IBOutlet weak var vagtTableView: UITableView!
    
    // MARK: - Variabler
    
    var managedObjectContext: NSManagedObjectContext!
    var vagterFRC: NSFetchedResultsController<NSFetchRequestResult>!
    
    // MARK: - Initial Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupFetchedResultsController()
        // performFetch()
        
    }
    
    // MARK: - Core Data Functions
    
    func performInitialCoreDataSetup() {
        
    }
    
    func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Vagt", in: self.managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor1 = SortDescriptor(key: "monthNumber", ascending: false)
        let sortDescriptor2 = SortDescriptor(key: "startTime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        
        vagterFRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        vagterFRC.delegate = self
    }
    
    private func performFetch() {
        do {
            try vagterFRC.performFetch()
            
            if vagterFRC.fetchedObjects?.count == 0 {
                
                // Vagt eksisterer endnu ikke
                
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
    
    

}

extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension MainVC: UITableViewDelegate {
    
}

extension MainVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        vagtTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        vagtTableView.endUpdates()
    }
    
}

//    lazy var vagterFRC: NSFetchedResultsController<NSFetchRequestResult> = {
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
//        let entity = NSEntityDescription.entity(forEntityName: "Vagt", in: self.managedObjectContext)
//        fetchRequest.entity = entity
//
//        let sortDescriptor1 = SortDescriptor(key: "monthNumber", ascending: false)
//        let sortDescriptor2 = SortDescriptor(key: "startTime", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
//
//        fetchRequest.fetchBatchSize = 20
//
//        let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
//
//        return fetchedResultsController
//
//    }















