//
//  StudentSubjectsEnrollViewController.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/19/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//
import FirebaseDatabase
import UIKit
import FirebaseAuth
class StudentSubjectsEnrollViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let currUserId :String = (Auth.auth().currentUser?.uid)!
    var subjects = [Dictionary <String, AnyObject>()]
    
    @IBOutlet weak var subjectsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSubjects()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        presentingViewController?.viewWillAppear(true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubjectsToEnrollCell", for: indexPath) as? StudentEnrollSubjectsCollectionViewCell else{
                   print("Error retrieving cell")
               return UICollectionViewCell()
               }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        displayAlert(title: "Attention", message: "Do you want to enroll to this course?", indexPath: indexPath)
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
                self.subjectsCollectionView.reloadData()
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

    func displayAlert(title: String, message: String, indexPath: IndexPath){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let enrollAction = UIAlertAction(title: "Enroll", style: .default) { (action) in
            
            self.enrollSubject(at: indexPath)
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(enrollAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func enrollSubject(at indexPath: IndexPath){
     let selectedSubject = self.subjects[indexPath.row]
            guard let subjectID = selectedSubject["id"] as? String,
             let subjectName = selectedSubject["subject"] as? String
        else{
            print("Subject id or name not found")
            return
        }
        
        let subjectsRef = Database.database().reference().child("users").child(currUserId).child("Enrolled Subjects")
        
        let newSubjectsRef = subjectsRef.childByAutoId()
        
        let enrolledData = ["id": subjectID, "subject": subjectName]
        
        newSubjectsRef.setValue(enrolledData) { (error, _) in
            if let error = error{
                print("Error writing in the database", error.localizedDescription)
            }
            else{
                print("Success!")
                self.dismiss(animated: true) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
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

}
