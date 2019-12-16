//
//  RegisterViewController.swift
//  Chatty
//
//  Created by MacBookPro on 12/13/19.
//  Copyright © 2019 MacBookPro. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func registerPressed(_ sender: Any) {
        
        Auth.auth().createUser(withEmail: userEmail.text!, password: userPassword.text!) { (result, error) in
            if (self.userEmail.text?.isEmpty == true || self.userPassword.text?.isEmpty == true){
                self.displayAlert(errorText: "Please Fill Empty Fields")
            }else if(error != nil) {
                print(error!)
                self.displayAlert(errorText: "Wrong UserName or Password")
            }else{
                guard let userId = result?.user.uid, let userName = self.userName.text  else {
                    return
                }
                let reference = Database.database().reference()
                let user = reference.child("users").child(userId)
                let dataArr:[String: Any] = ["userName": userName]
                user.setValue(dataArr)
                
                print("..... User Added .....")
                
                //let roomScreen = self.storyboard?.instantiateViewController(identifier: "Room") as! RoomsViewController
                //self.navigationController?.pushViewController(roomScreen, animated: false)
                
                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                
            }
            
        }
        
    }
    
    
    func displayAlert(errorText: String){
        let alert = UIAlertController.init(title: "Error", message: errorText, preferredStyle: .alert)
        self.present(alert,animated: true,completion: nil)
        
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
    }
}
