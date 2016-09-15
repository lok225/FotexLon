//
//  StandardVagterVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 24/08/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit

class StandardVagterVC: UITableViewController {
    
    let defaults = UserDefaults.standard
    
    var standardVagter: [StandardVagt]!
    var standardVagterInt: Int!
    
    var currentKey: String {
        switch standardVagterInt {
        case 0:
            return kStandardHverdage
        case 1:
            return kStandardLørdag
        case 2:
            return kStandardSøndag
        default:
            return ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttributes(for: navigationController!.navigationBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch standardVagterInt! {
        case 0:
            print("Hverdag")
            let vagterData = defaults.object(forKey: kStandardHverdage) as! Data
            standardVagter = NSKeyedUnarchiver.unarchiveObject(with: vagterData) as! [StandardVagt]
        case 1:
            print("Lørdag")
            let vagterData = defaults.object(forKey: kStandardLørdag) as! Data
            standardVagter = NSKeyedUnarchiver.unarchiveObject(with: vagterData) as! [StandardVagt]
            //standardVagter.removeAll()
        case 2:
            print("Søndag")
            let vagterData = defaults.object(forKey: kStandardSøndag) as! Data
            standardVagter = NSKeyedUnarchiver.unarchiveObject(with: vagterData) as! [StandardVagt]
            //standardVagter.removeAll()
        default:
            break
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        if standardVagter.isEmpty {
            cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.textColor = cell.tintColor
            cell.textLabel?.text = "Tilføj standard vagt"
            cell.accessoryType = .none
            cell.textLabel?.isUserInteractionEnabled = true
            
            return cell
            
        } else {
            if indexPath.row < standardVagter.count {
                
                let vagt: StandardVagt? = standardVagter[indexPath.row]
                
                if vagt != nil {
                    cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                    cell.textLabel?.text = vagt!.getTimeIntervalString() + " med \(vagt!.pause!) min pause"
                }
            } else {
                cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.textColor = cell.tintColor
                cell.textLabel?.text = "Tilføj standard vagt"
                cell.accessoryType = .none
                cell.textLabel?.isUserInteractionEnabled = true
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        if cell.textLabel?.textColor != cell.textLabel?.tintColor {
            performSegue(withIdentifier: "nyStandardVagtSegue", sender: standardVagter[indexPath.row])
        } else {
            performSegue(withIdentifier: "nyStandardVagtSegue", sender: nil)
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            standardVagter.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < standardVagter.count {
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navVC = segue.destination as! UINavigationController
        let vc = navVC.topViewController as! StandardVagtDetailVC
        
        if let _ = sender as? StandardVagt {
            vc.title = "Ændre standard vagt"
            vc.standardVagtToEdit = sender as! StandardVagt?
        }
        
        vc.delegate = self
    }
}

extension StandardVagterVC: StandardVagtDetailVCDelegate {
    
    func standardVagtDetailVCDidCancel(controller: StandardVagtDetailVC) {
        dismiss(animated: true, completion: nil)
        print("Key: \(currentKey)")
    }
    
    func standardVagtDetailVC(controller: StandardVagtDetailVC, didFinishAddingVagt vagt: StandardVagt) {
        
        dismiss(animated: true, completion: nil)
        
        standardVagter.append(vagt)
        
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: standardVagter)
        
        defaults.set(data, forKey: currentKey)
        print("Key: \(currentKey)")
        defaults.synchronize()
        
        tableView.reloadData()
    }
    
    func standardVagtDetailVC(controller: StandardVagtDetailVC, didFinishEditingVagt vagt: StandardVagt) {
        
    }
}











