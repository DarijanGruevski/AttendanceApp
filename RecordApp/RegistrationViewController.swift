//
//  RegistrationViewController.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/13/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegistrationViewController: UIViewController {
    
    var type = " "
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var SPSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func registerTapped(_ sender: Any) {
        if nameTextField.text!.isEmpty == true && emailTextField.text!.isEmpty == true && passwordTextField.text!.isEmpty == true {
            self.displayAlert(title: "Invalid input", message: "Name, Email and Password is required!")
        }
        signUp()
    }
    
    func signUp() {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {user, error in
            if error != nil {
                self.displayAlert(title: "Error", message: error!.localizedDescription)
            }
            else {
                print("Registration Successful!")
                if self.SPSwitch.isOn {
                    self.type = "Professor"
                } else {
                    self.type = "Student"
                }
                
                let object : [String: Any] = [
                    "name": self.nameTextField.text as Any,
                    "email": self.emailTextField.text as Any,
                    "password": self.passwordTextField.text as Any,
                    "type": self.type
                ]
                
                let userID = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(userID!).setValue(object)
                print("Object Written")
                
                if self.type == "Professor"{
                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                    req?.displayName = "Professor"
                    req?.commitChanges(completion: nil)
                    self.performSegue(withIdentifier: "ProfessorSegue", sender: nil)
                }
                else{
                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                        req?.displayName = "Student"
                        req?.commitChanges(completion: nil)
                        self.performSegue(withIdentifier: "StudentSegue", sender: nil)
                }
            }
            
            
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
