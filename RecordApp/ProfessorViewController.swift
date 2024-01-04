//
//  ProfessorViewController.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/13/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfessorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    var subjects = [Dictionary <String, AnyObject>()]
    @IBOutlet weak var collectionView: UICollectionView!

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        displayAlert(title: "Attention", message: "Do you want to add a schedule for this course?", indexPath: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddScheduleSegue",
            let subjectID = sender as? String,
            let addScheduleController = segue.destination as? AddNewScheduleViewController{
                addScheduleController.subjectID = subjectID
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subjectCell", for: indexPath) as? SubjectViewCell else{
            print("Error retrieving cell")
        return UICollectionViewCell()
        }
        cell.isUserInteractionEnabled = true
        let subject = self.subjects[indexPath.row]
        if let subjectTitle = subject["subject"] as? String{
            
            cell.subjectLabel?.text = subjectTitle
        }
            else{
                print("Failed to retrieve the title")
            cell.subjectLabel?.text = "Default Title"
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
        subjects.removeAll()
        collectionView.reloadData()
        getSubjects()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getSubjects()
    }
    
    
    
    @IBAction func logoutTapped(_ sender: Any) {
       try? Auth.auth().signOut()

        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func AddTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(identifier: "AddSubjectViewController") as? AddSubjectViewController{
           
        self.present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }
    }
    
    func displayAlert(title:String, message: String, indexPath:IndexPath){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let AddScheduleAction = UIAlertAction(title: "Add Schedule", style: .default) { _ in
            self.addSchedule(at: indexPath)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(AddScheduleAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addSchedule(at indexPath: IndexPath){
        if let subjectID = self.subjects[indexPath.row]["id"] as? String{
            print("subjectID:\(subjectID)")
            self.performSegue(withIdentifier: "AddScheduleSegue", sender: subjectID)
        }
        
    }
    
    func getSubjects() {
        Database.database()
            .reference()
            .child("Subjects")
            .observeSingleEvent(of: .value) { snapshot in
                if let subjectInfo = snapshot.value as? [String: AnyObject] {
                    self.subjects.removeAll()
                    for(_, subj) in subjectInfo{
                        if let individualSubject = subj as? [String: AnyObject]{
                            self.subjects.append(individualSubject)
                        }
                    }
                    self.collectionView.reloadData()
                }
                else {
                    print("No subjects found in the database.")
                                return
                            }
                if self.subjects.isEmpty {
                                        print("Subjects array is empty.")
                                    } else {
                    print("Subjects retrieved successfully: \(self.subjects)")
                        }
                }
        }
}

    
