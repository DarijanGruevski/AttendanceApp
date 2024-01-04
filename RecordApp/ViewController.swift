//
//  ViewController.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/12/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func LoginPressed(_ sender: Any) {
        login()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func login(){
        if emailTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true {
            displayAlert(title: "Missing Credentials", message: "Please provide your email and password")
        }
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!){ (user, error) in
            if error != nil {
                print("Error Logging in")
            }
            else{
                print("Login Successful!")
                if user?.user.displayName == "Professor"{
                    self.performSegue(withIdentifier: "LoginProfessorSegue", sender: nil)
                } else {
                    self.performSegue(withIdentifier: "LoginStudentSegue", sender: nil)
                }
            
            }
        }
        
    }

    func displayAlert(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(alertAction)

}

}
