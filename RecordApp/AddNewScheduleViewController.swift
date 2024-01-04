//
//  AddNewScheduleViewController.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/13/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import FirebaseDatabase
import FirebaseAuth

class AddNewScheduleViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UITextField!
    @IBOutlet weak var scheduleLabel: UILabel!
    var subjectID : String?
    @IBOutlet weak var EndLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleLabel?.isUserInteractionEnabled = true
        EndLabel?.isUserInteractionEnabled = true
        let tapStartGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        scheduleLabel?.addGestureRecognizer(tapStartGesture)
        
        let tapEndGesture = UITapGestureRecognizer(target: self, action: #selector(endLabelTapped))
        
        EndLabel.addGestureRecognizer(tapEndGesture)
        
        if let subjectId = subjectID{
            print("SubjectID: \(subjectId)")
        }
        else{
            print("SubjectID not found")
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func endLabelTapped() {
        let datePicker = ActionSheetDatePicker(title: "Select Time",
               datePickerMode: .dateAndTime,
               selectedDate: Date(),
               doneBlock: { picker, selectedDate, origin in
                   if let selectedDate = selectedDate as? Date {
                    self.handleTimeSelection(selectedDate, label: self.EndLabel)
                   }
               },
               cancel: { picker in },
               origin: EndLabel)
               datePicker?.show()
    }
    
    
    
    @IBAction func doneTapped(_ sender: Any) {
       
        let time = self.scheduleLabel.text
        let endTime = self.EndLabel.text
        let description = self.descriptionLabel.text
        
        self.writeDataToFirebase(subjectId: subjectID!, time: time!, endTime: endTime!, description: description!)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func labelTapped(){
        let datePicker = ActionSheetDatePicker(title: "Select Time",
        datePickerMode: .dateAndTime,
        selectedDate: Date(),
        doneBlock: { picker, selectedDate, origin in
            if let selectedDate = selectedDate as? Date {
                self.handleTimeSelection(selectedDate, label: self.scheduleLabel)
            }
        },
        cancel: { picker in },
        origin: scheduleLabel)
        datePicker?.show()
    }
    
    func handleTimeSelection(_ selectedTime: Date, label: UILabel){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        let formattedTime = dateFormatter.string(from: selectedTime)
        label.text = formattedTime
    }
    
    
    func writeDataToFirebase(subjectId: String, time: String, endTime: String, description: String) {
    let ref = Database.database().reference().child("Subjects").child(subjectId).childByAutoId()
    
    let schedules : [String:Any] = [
        "start": time,
        "end": endTime,
        "description": description
    ]
            ref.setValue(schedules) { error, _ in
                if let error = error {
                    print("Error:", error.localizedDescription)
                    self.displayAlert(title: "Error", message: error.localizedDescription ?? "Try Again")
                } else {
                    self.displayAlert(title: "Success", message: "Schedule added")
                    print("Schedule successfully written in the database")
                    }
                }
        }
    
    func displayAlert(title:String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController,animated: true, completion: nil)
    }
}


