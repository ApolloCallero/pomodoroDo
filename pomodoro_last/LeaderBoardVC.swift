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
        reloadPeople()
    }

    func addFriendPopUp(){
        //Step : 1
        let alert = UIAlertController(title: "Enter Your Friends Unique Username", message: "", preferredStyle: UIAlertController.Style.alert )
        //Step : 2
        let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let emailTextField = alert.textFields![0] as UITextField
            if emailTextField.text != "" {
                self.save(name: emailTextField.text!)
            } else {
                print("TF 1 is Empty...")
            }
        }

        //Step : 3
        //For first TF
        alert.addTextField { (emailTextField) in
            emailTextField.placeholder = "Enter Your Friends Username"
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
        cell.textLabel?.text = String(indexPath.row + 1) + ": " + people[indexPath.row].name
        cell.detailTextLabel?.text = "Minutes Suudied: " + String(people[indexPath.row].timeStudy)
        //change text color if it's the users turn
        if UserDefaults.standard.string(forKey: "email")! == people[indexPath.row].name{
            cell.textLabel?.textColor = UIColor.blue
            cell.detailTextLabel?.textColor = UIColor.blue
        }
        else{
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        }
        return cell
    }
    
    
    //save name to to coredate
    func save(name: String) {
        let q = NSEntityDescription.insertNewObject(forEntityName:"Friend", into: self.managedObjectContext)
        q.setValue(name, forKey: "name")
        self.dataF.append(q)
        appDelegate.saveContext() // In AppDelegate.swift
        addFriend(friend: name)
    }
    
    func addFriend(friend: String){
        Firestore.firestore().collection(friend + "StudySession")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var totalTime = 0
                    for document in querySnapshot!.documents {
                        totalTime = totalTime + (document.get("StudySessionTime") as! Int)
                    }
                    if self.inPeople(n: friend) == false{
                        self.people.append(Person(n: friend, mins: totalTime))
                        self.reloadPeople()
                    }
                    
                }
                
        }
    }
    func inPeople(n: String) -> Bool{
        for i in people{
            if n == i.name{
                return true
            }
        }
        return false
    }
    func getTimeStudied(friend:String) -> Int {
        var totalTime = 0
        Firestore.firestore().collection(friend + "StudySession")
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    totalTime = totalTime + (document.get("StudySessionTime") as! Int)
                }
                let new = Person(n: friend, mins: totalTime)
                if !self.inPeople(n: friend){
                    self.people.append(new)
                    self.friendsTableView.reloadData()
                }
            }
    }
        return totalTime
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
            //gt the data for this person
            self.people = []
            var thisPersonTime = 0
            let email = UserDefaults.standard.string(forKey: "email")!
            getTimeStudied(friend: email)
            
                
            //get name from core data
            coreQ = try self.managedObjectContext.fetch(fetchRequest)
            self.dataF = coreQ
            
            for i in coreQ{
                //get mins from firebase and add to array
                getTimeStudied(friend: i.value(forKey: "name") as! String)
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


