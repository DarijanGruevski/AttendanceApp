//
//  AddSubjectViewController.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/16/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//

import UIKit
import FirebaseDatabase


class AddSubjectViewController: UIViewController {
    @IBOutlet weak var subjectTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        presentingViewController?.viewWillAppear(true)
    }
    
    
    @IBAction func checkAttendanceTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "CheckAttendanceSegue", sender: self)
    }
    
    @IBAction func AddLectureTapped(_ sender: Any) {
        
        if subjectTextField.text?.isEmpty == true {
                      displayAlert(title: "Insufficient Information", message: "Please provide the needed information.")
                  }
                else{
            writeSubject(subject: subjectTextField.text!)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func writeSubject(subject: String){
        
        let ref = Database.database().reference().child("Subjects")
         let newRef = ref.childByAutoId()
        
        
        let subject : [String: Any] = [
            "id": newRef.key,
            "subject" : self.subjectTextField.text
        ]
       
        
        newRef.setValue(subject) { (error, _) in
            if let error = error {
                print("Error writing in database")
            } else {
                print("Object written in database")
            }
        }
        
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
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
