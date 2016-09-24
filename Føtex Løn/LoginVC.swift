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
    
    var txtColor: UIColor!
    
    var prevCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtColor = txtPassword.backgroundColor
        
        txtPassword.autocapitalizationType = .allCharacters
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        let text = txtPassword.text?.uppercased()
        
        if text == "XDGJ-QAID" {
            UserDefaults.standard.set(true, forKey: kIsLoggedIn)
            UserDefaults.standard.synchronize()
            
            UIView.animate(withDuration: 0.2, animations: { 
                let view = self.txtPassword.superview
                view?.backgroundColor = UIColor.green
                self.txtPassword.backgroundColor = UIColor.green
                self.txtPassword.textColor = UIColor.white
                }, completion: { (_) in
                    self.performSegue(withIdentifier: kDismissToMainVCSegue, sender: nil)
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                let view = self.txtPassword.superview
                view?.backgroundColor = faktaRed
                self.txtPassword.backgroundColor = faktaRed
                self.txtPassword.textColor = UIColor.white
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.2, animations: { 
                        let view = self.txtPassword.superview
                        view?.backgroundColor = UIColor.white
                        self.txtPassword.backgroundColor = UIColor.white
                        self.txtPassword.textColor = UIColor.black
                    })
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! MainVC
        destVC.firstTime()
    }
}

extension LoginVC: UITextFieldDelegate {
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let count = textField.text!.characters.count
        print("Count: \(count)")
        print("PrevCount: \(prevCount)\n")
        if textField.text?.characters.count == 4 && prevCount == 3{
            textField.text = textField.text! + "-"
            
        }
        
        prevCount = count
        
        return true
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
}
