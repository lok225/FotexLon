//
//  LoginVC.swift
//  Føtex Løn
//
//  Created by Martin Lok on 17/09/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var txtPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        let text = txtPassword.text?.capitalized
        
        if text == "A" {
            UserDefaults.standard.set(true, forKey: kIsLoggedIn)
            UserDefaults.standard.synchronize()
            
            dismiss(animated: true, completion: nil)
        }
    }

}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
}
