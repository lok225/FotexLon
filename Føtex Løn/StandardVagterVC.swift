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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttributes(for: navigationController!.navigationBar)
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
            
            let touchGR = UITapGestureRecognizer(target: self, action: #selector(emptyCellTapped))
            // cell.textLabel?.addGestureRecognizer(touchGR)
            cell.textLabel?.isUserInteractionEnabled = true
            return cell
        } else {
            
            var i = 0
            for vagt in standardVagter {
                if let vagt = standardVagter[i] as? StandardVagt {
                    cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                    cell.textLabel?.text = vagt.getTimeIntervalString()
                }
                i += 1
            }
            
            return cell
        }
    }
    
    func emptyCellTapped(sender: UITapGestureRecognizer) {
        
        switch sender.state {
        case .began:
            let label = sender.view as! UILabel
            label.textColor = UIColor.darkGray
            print("Began")
        case .ended:
            print("Hej")
        default:
            break
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
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navVC = segue.destination as! UINavigationController
        let vc = navVC.topViewController as! StandardVagtDetailVC
        
        if let _ = sender as? StandardVagt {
            vc.title = "Ændre standard vagt"
        }
        
        vc.delegate = self
    }
}

extension StandardVagterVC: StandardVagtDetailVCDelegate {
    
    func standardVagtDetailVCDidCancel(controller: StandardVagtDetailVC) {
        dismiss(animated: true, completion: nil)
    }
    
    func standardVagtDetailVC(controller: StandardVagtDetailVC, didFinishAddingVagt vagt: StandardVagt) {
        
        dismiss(animated: true, completion: nil)
        standardVagter.append(vagt)
        defaults.set(standardVagter, forKey: "hej")
        tableView.reloadData()
    }
    
    func standardVagtDetailVC(controller: StandardVagtDetailVC, didFinishEditingVagt vagt: StandardVagt) {
        
    }
}











