//
//  SurveyAnswersViewController.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/27/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SurveyAnswersViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var grades = [Dictionary <String,Any>()]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.grades.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "surveyCell") as! SurveyAnswersTableViewCell
        
        return cell
    }
    

    @IBOutlet weak var table: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        getGradesforSubjects()
        // Do any additional setup after loading the view.
    }
    
    
    func getGradesforSubjects(){
    let attendanceRef = Database.database().reference().child("Attendance")
        
        attendanceRef.observeSingleEvent(of: .value) { (snapshot) in
            if let attendanceData = snapshot.value as? [String:Any] {
                for(attID, data) in attendanceData {
                    if let info = data as? [String:Any]{
                        let subject = info["subject"] as? String
                        let grade = info["grade"] as? String
                        let comment = info["comment"] as? String
                        print(subject, grade, comment)
                        let gradeDict = ["for subject":subject,"grade":grade,"comment":comment]
                        self.grades.append(gradeDict)
                    }
                }
            }
        }
        print("Grades array:\(self.grades)")
        
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
