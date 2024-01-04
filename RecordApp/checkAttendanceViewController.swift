//
//  checkAttendanceViewController.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/25/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//

import UIKit
import FirebaseDatabase

class checkAttendanceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    var students = [Dictionary <String, Any>()]
    var filteredStudents = [Dictionary <String,Any>()]

    
    @IBOutlet weak var searchStudents: UISearchBar!
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        getStudents()
         self.students.remove(at: 0)
        
    }
    @IBAction func surveyAnswersTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "SurveyAnswersSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredStudents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attendanceCell") as! checkAttendanceTableViewCell
        
        let student = self.filteredStudents[indexPath.row]
        
        if let name = student["name"] as? String{
            cell.attendanceLabel.text = name
        } else{
            cell.attendanceLabel.text = "HOHO"
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBySubject(searchText: searchText)
        self.table.reloadData()
    }
    
    func searchBySubject(searchText: String) {
        if searchText.isEmpty {
            filteredStudents = students
           
        } else{
            
            
            filteredStudents = students.filter{ student in
                guard let subjects = student["subjects"] as? [String] else {
                    print("Error!")
                    return false}
                print("subjects",subjects)
                print(subjects.contains{$0.localizedCaseInsensitiveContains(searchText)})
                return subjects.contains{$0.localizedCaseInsensitiveContains(searchText)}
        }
            print("Filtered Students by \(searchText)", filteredStudents)
    }
        DispatchQueue.main.async {
               self.table.reloadData()
           }
    }
    
    func getStudents() {
    let ref = Database.database().reference()
    let usersRef = ref.child("users")
        
    usersRef.observeSingleEvent(of: .value) { (snapshot) in
        guard let usersData = snapshot.value as? [String:Any] else {
            return
        }
        self.students.removeAll()
        self.filteredStudents.removeAll()
        
//        print(usersData)
        for (id, data) in usersData {
            if let userInfo = data as? [String:Any],
                let name = userInfo["name"] as? String,
                let type = userInfo["type"] as? String{
                if type == "Student" {
                    let student = [
                        "Id": id,
                        "name": name
                    ]
                    
                    self.students.append(student)
//                    print("Students:", self.students)
                }
            }
            self.getAttendingStudents()
        }
    }
}
    
    func getAttendingStudents() {
        let ref = Database.database().reference()
        let attendanceRef = ref.child("Attendance")

        attendanceRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let attendingData = snapshot.value as? [String:Any] else {
                return
            }

            for (studentID, studentInfo) in attendingData {
//                print("student data", studentInfo)
                if let studentData = studentInfo as? [String:Any]{
                    let studentId = studentData["Id"] as? String
                let studentIndex = self.students.firstIndex{
                    guard let id = $0["Id"] as? String else{return false}
                    
                    return id == studentId
                    }
                guard let index = studentIndex else{
                    print("not a valid index for \(studentID)")
                    return
                }

                    if let subject = studentData["subject"] as? String{
                        
                        var subjects = Set(self.students[index]["subjects"] as? [String]
                            ?? [])
                        subjects.insert(subject)
                    self.students[index]["subjects"] = Array(subjects)
                    }else{
                        print("the values are nil")
                    }
  
                            self.table.reloadData()

        }
          }
            print("Array:\(self.students)")
}
        self.filteredStudents = self.students
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

