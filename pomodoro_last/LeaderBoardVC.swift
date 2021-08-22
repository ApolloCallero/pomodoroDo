//
//  LeaderBoardVC.swift
//  pomodoro_last
//
//  Created by Apollo Callero on 4/24/21.
//

import Foundation
import UIKit
import SwiftUI
import Firebase
import FirebaseFirestore
import CoreData
class LeaderBoardVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    override func viewDidLoad() {
        print("init")
        super.viewDidLoad()
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        self.friendsTableView.reloadData()
    }
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    var dataF: [NSManagedObject] = []
    var people: [Person] = []

    @IBOutlet weak var friendsTableView: UITableView!
    @IBAction func addTapped(_ sender: Any) {
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        addFriendPopUp()
    }

    func addFriendPopUp(){
        //Step : 1
        let alert = UIAlertController(title: "Enter Your Friends Unique Username", message: "", preferredStyle: UIAlertController.Style.alert )
        //Step : 2
        let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let emailTextField = alert.textFields![0] as UITextField
            if emailTextField.text != "" {
                self.save(email: emailTextField.text!)
            } else {
                print("TF 1 is Empty...")
            }
        }

        //Step : 3
        //For first TF
        alert.addTextField { (emailTextField) in
            emailTextField.placeholder = "Your Friend's Email"
            emailTextField.textColor = .blue
        }

        //Step : 4
        alert.addAction(save)
        self.present(alert, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            people = sortPeople()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "freindCell", for: indexPath)
        print(String(indexPath.row + 1) + ": " + people[indexPath.row].name)
        cell.textLabel?.text = String(indexPath.row + 1) + ": " + people[indexPath.row].name
        cell.detailTextLabel?.text = "Minutes Suudied: " + String(people[indexPath.row].timeStudy)
        //change text color if it's the users turn
        let user = Auth.auth().currentUser
        if user!.email! == people[indexPath.row].email{
            cell.textLabel?.textColor = UIColor.blue
            cell.detailTextLabel?.textColor = UIColor.blue
        }
        else{
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        }
        return cell
    }
    
    
    //save name to to core data
    func save(email: String) {
        let q = NSEntityDescription.insertNewObject(forEntityName:"Friend", into: self.managedObjectContext)
        var friendInfoRef: DocumentReference?
        friendInfoRef = Firestore.firestore().collection(email).document("UserInfo")
        friendInfoRef?.getDocument() { (document, error) in
            if let document = document {
                let first = document.get("first name") as! String
                let last = document.get("last name") as! String
                let fEmail = document.get("Email") as! String
                if self.inPeople(n: fEmail) == false{
                    q.setValue(fEmail, forKey: "email")
                    q.setValue((first + " " + last), forKey: "name")
                    self.dataF.append(q)
                    self.appDelegate.saveContext() // In AppDelegate.swift
                    self.addFriend(email: email)
                    self.reloadPeople()
                    }
                }
                        
            else {
                print("Document does not exist in cache", document?.data())
            }
    }
    }
    func addFriend(email: String){
        var friendInfoRef: DocumentReference?
        let friendStudyDocu = Firestore.firestore().collection(email).document("StudySessions").collection("StudyDocuments")
        friendInfoRef = Firestore.firestore().collection(email).document("UserInfo")
        friendInfoRef?.getDocument() { (document, error) in
            if let document = document {
                let first = document.get("first name") as! String
                let last = document.get("last name") as! String
                let email = document.get("Email") as! String
                var totalTime = 0
                friendStudyDocu.getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            var totalTime = 0
                            for document in querySnapshot!.documents {
                                totalTime = totalTime + (document.get("Time") as! Int)
                            }
                            if self.inPeople(n: email) == false{
                                    self.people.append(Person(n: (first + " " + last), mins: totalTime, e: email))
                                    self.reloadPeople()
                                }
                            }
                        }
                }
            else {
                print("Document does not exist in cache", document?.data())
            }
        }
        self.friendsTableView.reloadData()

    }
    func inPeople(n: String) -> Bool{
        for i in people{
            if n == i.name{
                return true
            }
        }
        return false
    }
    func addFreind(friend:String){
        //gets the amount of time the friend has studied , makes a person instance
        //and then adds that instance to
        var totalTime = 0
        Firestore.firestore().collection(friend).document("StudySessions").collection("StudyDocuments").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    totalTime = totalTime + (document.get("Time") as! Int)
                }
                var friendInfoRef: DocumentReference?
                friendInfoRef = Firestore.firestore().collection(friend).document("UserInfo")
                friendInfoRef?.getDocument() { (document, error) in
                    if let document = document {
                        let first = document.get("first name") as! String
                        let last = document.get("last name") as! String
                        let new = Person(n: (first + " " + last), mins: totalTime,e:friend )
                        self.people.append(new)
                        if !self.inPeople(n: friend){
                            self.friendsTableView.reloadData()
                        }
                }

            }
          }
        }
        }
        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPeople()
        print("ok")
        self.friendsTableView.reloadData()
    }
    
    //fetch from cored data
    func reloadPeople(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Friend")
        var coreQ: [NSManagedObject] = []
        do {
            //get the data for this person
            self.people = []
            let user = Auth.auth().currentUser
            addFreind(friend: user!.email!)//add user to people array
            //get name from core data
            coreQ = try self.managedObjectContext.fetch(fetchRequest)
            self.dataF = coreQ
            for i in coreQ{
                //get mins from firebase and add to array
                addFreind(friend: i.value(forKey: "email") as! String)//add all friends to people array
            }
            
        } catch {
            print("fetchQuotes error: \(error)")
        }
    }
        func sortPeople() -> [Person] {
            guard people.count > 1 else {return people}
            var sortedArray = people
            for i in 0..<sortedArray.count {
                for j in 0..<sortedArray.count-i-1 {
                    if sortedArray[j].timeStudy<sortedArray[j + 1].timeStudy {
                        sortedArray.swapAt(j + 1, j)
                    }
                }
            }
            
            return sortedArray
        }
    
}


