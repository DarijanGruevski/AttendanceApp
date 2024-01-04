//
//  TimeTableViewController.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/20/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//

import FSCalendar
import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

class TimeTableViewController: UIViewController,FSCalendarDelegateAppearance, FSCalendarDelegate,FSCalendarDataSource, CLLocationManagerDelegate {

    var manager = CLLocationManager()
    var location = CLLocationCoordinate2D()
    let dateFormatter = DateFormatter()
   var allSchedules : [[String:Any]] = []
    var currUserID: String = (Auth.auth().currentUser?.uid)!
    var enrolledSubjects : [[String:Any]]?
    @IBOutlet weak var calendar: FSCalendar!
    let kalendar = Calendar.current
    var markedDates: [Date] = []
    var userAttendClass = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.dataSource = self
        getSubjects {
            
        }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            self.location = location.coordinate
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            displayScheduleForSelectedDate(date)
            
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return markedDates.contains { datesAreSameDay(date1: $0, date2: date) } ? 1 : 0
    }


        func datesAreSameDay(date1: Date, date2: Date) -> Bool {
            let components1 = self.kalendar.dateComponents(in: TimeZone.current, from: date1)
            let components2 = self.kalendar.dateComponents(in: TimeZone.current, from: date2)

            return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
        }


    

    func displayScheduleForSelectedDate(_ date: Date) {
        for schedule in allSchedules {
            if let scheduleDate = schedule["time"] as? String,
                let scheduleDateTime = dateFormatter.date(from: scheduleDate) {
                if datesAreSameDay(date1: date, date2: scheduleDateTime){
                    self.markedDates.append(date)
                    print("Marked Dates",markedDates)
                    print("Dates match")
                    if let time = schedule["time"] as? String,
                        let description = schedule["description"] as? String {
                        let alertController = UIAlertController(title: "Schedule details:", message: "Time: \(extractTime(from: schedule) ?? "")\nDescription: \(description)", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        
                        let imHereAction = UIAlertAction(title: "I'm here!", style: .default) { (action) in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.writeLocation(uniqueID: self.currUserID, location: self.location, selectedDate: scheduleDateTime)
                            }
                        }
                        alertController.addAction(imHereAction)
                        present(alertController, animated: true, completion: nil)
                        return
                    }
                    else{
                        print("Here!")
                    }
                    
                }
                    
            else{
                    
                    print("Dates do not match")
                }
            }
            else{
                          print("No schedule found for selected date.")
                   }
            
    }
       
    }
    
    
    
    
    func getSubjects(completion: @escaping () -> Void) {
        guard let enrolledSubjects = enrolledSubjects else {
            return
        }
        
        let subjectsRef = Database.database().reference().child("Subjects")
        
        for subject in enrolledSubjects {
            guard let subjectId = subject["id"] as? String,
                let subjectName = subject["subject"] as? String else {
            print("invalid data")
                    return
            }
                let ref = subjectsRef.child(subjectId)

                ref.observeSingleEvent(of: .value) { snapshot in
                    guard let subjectsData = snapshot.value as? [String: Any] else {
                        return
                    }

                    for (autoScheduleID, scheduleData) in subjectsData {
                        
                        if let scheduleInfo = scheduleData as? [String: Any],
                            let start = scheduleInfo["start"] as? String,
                            let end = scheduleInfo["end"] as? String,
                            let description = scheduleInfo["description"] as? String {
                            let schedule = [
                                "subject": subjectName,
                                "scheduleID": autoScheduleID,
                                "time": start,
                                "end": end,
                                "description": description
                            ]
                            self.allSchedules.append(schedule)
                            print("AllSchedules",self.allSchedules)
                            
                            
                            if let scheduleDate = schedule["time"] as? String{
                                self.dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
                          if let scheduleDateTime = self.dateFormatter.date(from: scheduleDate) {                            self.markedDates.append(scheduleDateTime)
//                                print("Marked Dates:",self.markedDates)
                            } else {
                                print("Error creating date from scheudleDate")
                                    }
                                }
                        }
                    completion()
                    self.calendar.reloadData()
                }
            }
        }
    }
    
    func extractTime(from schedule: [String:Any]) -> String?{
        
        if let dateString = schedule["time"] as? String {
            self.dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
            self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            self.dateFormatter.amSymbol = "AM"
            self.dateFormatter.pmSymbol = "PM"
            
            if let date = self.dateFormatter.date(from: dateString){
                let timeFormatter = DateFormatter()
              timeFormatter.dateFormat = "hh:mm a"
                
                return timeFormatter.string(from: date)
            } else {
                print("Error extracting time from schedule")
                return nil
            }
        }
        else{
            print("Nothing found under key 'time' ")
            return nil
        }
    }
    
    func extractTime2(from dateString: String) -> String?{
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        if let dateString = dateFormatter.date(from: dateString){
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            
            return timeFormatter.string(from: dateString)
        }
        return nil
    }
    
    
    
    func writeLocation(uniqueID: String, location: CLLocationCoordinate2D, selectedDate: Date){
        
        if CLLocationCoordinate2DIsValid(location){
            var studentLocation = ["Id": uniqueID, "latitude": location.latitude, "longitude":location.longitude] as [String : Any]
            for schedule in allSchedules {
                if let scheduleStartDate = schedule["time"] as? String,
                    let scheduleEndDate = schedule["end"] as? String,
                    let name = schedule["subject"] as? String{
                    if let dateStart = dateFormatter.date(from: scheduleStartDate){
                     if datesAreSameDay(date1: selectedDate, date2: dateStart) {
                        if let time = extractTime(from: schedule),
                            let endTime = extractTime2(from: scheduleEndDate){
                            studentLocation["time"] = time
                            studentLocation["end"] = endTime
                            studentLocation["subject"] = name
                            let collegeLocation = CLLocationCoordinate2D(latitude: 42.005, longitude: 21.4083)
                            let threshhold = 0.001
                            
                            let distanceToCollege = calculateDistanceToCollege(student: location, college: collegeLocation)
                            if distanceToCollege < threshhold{
                            let ref = Database.database().reference().child("Attendance").childByAutoId()
                            ref.setValue(studentLocation) { (error, _) in
                                if let error = error {
                                    print("error", error.localizedDescription)
                            }else{
                                    self.displayAlert(title: "Attention", message: "You are attending this class now!")
                                    print("You are attending this class now!")
                                }
                            }
                            }else{
                                self.displayAlert(title: "Attention", message: "You are not at college. Stop going on coffees and focus on your education!")
                                print("You are not at college.")
                            }
                            break
                            }
                    }
                    else {
                        print("ERROR!")
                        }
                    }
                }
            }
        }else{
            print("Invalid coordinates")
            }
    }
    
    func calculateDistanceToCollege(student: CLLocationCoordinate2D, college: CLLocationCoordinate2D) -> CLLocationDistance{
        let studentLocation = CLLocation(latitude: student.latitude, longitude: student.longitude)
        let collegeLocation = CLLocation(latitude: college.latitude, longitude: college.longitude)
        return studentLocation.distance(from: collegeLocation)
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
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


