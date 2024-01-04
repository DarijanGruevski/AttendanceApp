//
//  StudentViewController.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/13/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class StudentViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    let currUserID : String = (Auth.auth().currentUser?.uid)!
    var enrolledSubject = [Dictionary <String, AnyObject>()]
    @IBOutlet weak var HelloLabel: UILabel!
    var selectedSubject : String?
    var selectedID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        getName()
        getEnrolledSubjects()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getEnrolledSubjects()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enrolledSubject.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EnrolledSubjectsCell") as! EnrolledSubjectsTableViewCell
        
        let subject = self.enrolledSubject[indexPath.row]
        
        if let subjectTitle = subject["subject"] as? String {
        cell.TitleLabel?.text = subjectTitle
        }
        else{
            cell.TitleLabel?.text = "HOHO!"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSubject = self.enrolledSubject[indexPath.row]
        
        if let subject = selectedSubject["subject"] as? String{
            getAttendanceForSubject(subject: subject)
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "timeTableSegue",
            let destinationVC = segue.destination as? TimeTableViewController,
            let subjectsArray = sender as? [[String:Any]]{
            
            destinationVC.enrolledSubjects = subjectsArray
        }
    }

    
    
    @IBAction func LogoutTapped(_ sender: Any) {
       try? Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func EnrollTapped(_ sender: Any) {
        performSegue(withIdentifier: "EnrollSubjects", sender: nil)
    }
    
    
   
    @IBAction func timeTableTapped(_ sender: Any) {
        var subjectsFromDatabase: [[String: Any]] = []
        for subject in self.enrolledSubject{
     if let subjectID = subject["id"] as? String,
        let subjectName = subject["subject"] as? String{
        
        
        let individualSubject = ["id": subjectID, "subject":subjectName]
        subjectsFromDatabase.append(individualSubject)
            }
            
    }
        performSegue(withIdentifier: "timeTableSegue", sender: subjectsFromDatabase)
    
    }
    
    
    func getName() {
        let ref = Database.database().reference()
        
        let usersRef = ref.child("users").child(currUserID)
        
        usersRef.observeSingleEvent(of: .value) { (snapshot) in
            if let usersData = snapshot.value as? [String:Any],
                let usersName = usersData["name"] as? String {
                if let firstName = usersName.components(separatedBy: " ").first{
                    self.HelloLabel.text = "Hello \(firstName)"
                }
                else{
                    self.HelloLabel.text = "Hello User"
                }
                }
            }
        }
    
    func getEnrolledSubjects(){
        let subjectsRef = Database.database().reference().child("users").child(currUserID).child("Enrolled Subjects")
        
        subjectsRef.observeSingleEvent(of: .value) { (snapshot) in
             if let subjectInfo = snapshot.value as? [String: AnyObject] {
                               self.enrolledSubject.removeAll()
                               for(_, subj) in subjectInfo{
                                   if let individualSubject = subj as? [String: AnyObject]{
                                       self.enrolledSubject.append(individualSubject)
                }
            }
                self.table.reloadData()
        }
            else {
                print("No subjects found in the database.")
                            return
                        }
           
                    }
        
    }

    func getAttendanceForSubject(subject: String) {

        let attendanceRef = Database.database().reference().child("Attendance")

        attendanceRef.observeSingleEvent(of: .value) { (snapshot) in
            if let attendanceData = snapshot.value as? [String:Any] {
//                print("attendanceData:",attendanceData)
                
                 let subjectsData = (attendanceData.filter{($0.value as? [String:Any])?["subject"] as? String == subject})
                print("subjects Data", subjectsData)
                if subjectsData.isEmpty {
                    self.notAttendingAlert()
                }else{
                for (attendanceID, subjectData) in subjectsData {
//                    print("subjectData",subjectData)
                    self.showAttendanceAlert(attendanceID: attendanceID, subjectData: subjectData )
                }
                
                }
            }
                }
            }
    
    func showAttendanceAlert(attendanceID:String,subjectData: Any){
        let alertController = UIAlertController(title: "Survey", message: "Please take this short survey", preferredStyle: .alert)
        alertController.addTextField { (TextField) in
            TextField.placeholder = "Enter grade"
        }
        alertController.addTextField { (TextField) in
            TextField.placeholder = "Enter a comment"
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            if let inputField1 = alertController.textFields?[0].text,
                let inputField2 = alertController.textFields?[1].text{
                self.writeGrade(grade:inputField1, comment: inputField2, attendanceID: attendanceID)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func writeGrade(grade: String, comment:String, attendanceID: String){
        
        
        let attendanceRef = Database.database().reference().child("Attendance").child(attendanceID)
    
        attendanceRef.updateChildValues(["grade": grade, "comment":comment]) { (error, _) in
            if let error = error{
                print("error",error.localizedDescription)
            }else{
                print("object updated successfully")
            }
        }
    }
    
    
    func notAttendingAlert() {
        let alertController = UIAlertController(title: "Attention", message: "You are not attending this class", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
        }
        
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

