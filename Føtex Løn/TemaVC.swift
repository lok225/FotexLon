//
//  TemaVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 19/09/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit

class TemaVC: UITableViewController {
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let shop = defaults.integer(forKey: kTheme)
        let indexPath = IndexPath(row: shop, section: 0)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        print(shop)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var i = 0
        
        for cell in tableView.visibleCells {
            if cell.accessoryType == .checkmark {
                break
            } else {
                i += 1
            }
        }
        
        var shop: Shop!
        
        switch i {
        case 0:
            shop = .teal
        case 1:
            shop = .føtex
        case 2:
            shop = .fakta
        case 3:
            shop = .bio
        default:
            shop = .ingen
        }
        
        defaults.set(shop.rawValue, forKey: kTheme)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        cell.setSelected(false, animated: true)
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        cell.accessoryType = .checkmark
    }

}
