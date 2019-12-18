//
//  SignInViewController.swift
//  Chatty
//
//  Created by MacBookPro on 12/13/19.
//  Copyright © 2019 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignInViewController: UIViewController {
    
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func signInPressed(_ sender: Any) {
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: userEmailTextField.text!,password: userPasswordTextField.text!) { (result, error) in
            if error != nil {
                print(error!)
            }else{
                self.dismiss(animated: true, completion: nil)
                print("Logged In ........")
                SVProgressHUD.dismiss()
            }
        }
    }
}
