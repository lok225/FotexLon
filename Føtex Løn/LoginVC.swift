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
    
    var defaults = UserDefaults.standard
    
    var prevCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtColor = txtPassword.backgroundColor
        
        txtPassword.autocapitalizationType = .allCharacters
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        guard let text = txtPassword.text?.uppercased() else {
            return
        }

        for store in stores {
            print(store.code)
            if store.code == text {
                
                // Set løn ved store
                defaults.set(store.basisLon ?? 0.0, forKey: kYoungBasisLon)
                defaults.set(store.aftenTillæg ?? 0.0, forKey: kYoungAftensSats)
                defaults.set(store.lørdagTillæg ?? 0.0, forKey: kYoungLordagsSats)
                defaults.set(store.søndagTillæg ?? 0.0, forKey: kYoungSondagsSats)
                
                // Set lønperiode indstillinger
                if store.lonPeriodeStart != nil {
                    defaults.set(store.lonPeriodeStart, forKey: kLønPeriodeStart)
                    defaults.set(true, forKey: kLønperiodeIsSet)
                }
                
                // Set hasOldLøn
                if !store.hasOldLøn {
                    defaults.set(true, forKey: kAlderIsSet)
                }
                
                // Lav afsluttende login indstillinger
                defaults.set(text, forKey: kEnteredCode)
                defaults.set(store.id, forKey: kStore)
                defaults.set(true, forKey: kIsLoggedIn)
                defaults.synchronize()
                
                // Lav animationer 
                UIView.animate(withDuration: 0.2, animations: {
                    let view = self.txtPassword.superview
                    view?.backgroundColor = UIColor.green
                    self.txtPassword.backgroundColor = UIColor.green
                    self.txtPassword.textColor = UIColor.white
                }, completion: { (_) in
                    self.performSegue(withIdentifier: kDismissToMainVCSegue, sender: nil)
                })
                
                return
            }
        }
        
        // Perform password textField animation
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! MainVC
        destVC.firstTime()
    }
}

extension LoginVC: UITextFieldDelegate {
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let count = textField.text!.characters.count
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
