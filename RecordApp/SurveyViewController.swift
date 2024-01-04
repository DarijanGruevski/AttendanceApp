//
//  SurveyViewController.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/27/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var enrolledSubjects = [Dictionary<String,Any>()]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.enrolledSubjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subjectCell") as! UITableViewCell
        let subject = self.enrolledSubjects[indexPath.row]
        
        if let title = subject["subject"] as? String{
            cell.textLabel?.text = title
        }
        return cell
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("enrolled Sbujects", enrolledSubjects)
        // Do any additional setup after loading the view.
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
