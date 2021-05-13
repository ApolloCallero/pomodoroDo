//
//  AchivementsVC.swift
//  Pomodoro
//
//  Created by Apollo Callero on 4/3/21.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
class AchivmentsVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("achiuviemkebht")
        // Do any additional setup after loading the view.
    }
    var studySessions = [Int]()
    var totalMinutes = 0
    let titles = ["Rank: beginner 1", "Rank: beginner 2","Rank: beginner 3", "Rank: challenger 1","Rank: challenger 2","Rank: challenger 3","Rank: Pomodoer 1","Rank: Pomodoer 2",
                  "Rank: Pomodoer 3", "Rank: elite giga nerd 1", "Rank: elite giga nerd 2", "Rank: elite giga nerd 3"]
    let hoursForRank = [1,2,3,10,15,20,30,40,50,65,69,100]
    func getData() {
        let email = UserDefaults.standard.string(forKey: "email")!
        //let password = UserDefaults.standard.string(forKey: "password")!
        let collectionStudy = Firestore.firestore().collection(email  + "StudySession")
        collectionStudy.getDocuments() { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.studySessions.append(document.get("StudySessionTime") as! Int)
                }
                self.allSessions()
                self.tableView.reloadData()
            }
        }
        print("out closure",self.studySessions)
    }
    func allSessions(){
        totalMinutes = studySessions.reduce(0, +)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getData()
    }
    
    
    
    //table view funcs
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.titles.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        if self.totalMinutes > 60 * hoursForRank[indexPath.row]{
            cell.detailTextLabel?.text = String(self.totalMinutes) + "/" + String(60 * hoursForRank[indexPath.row]) + " minutes"
            cell.textLabel?.text = self.titles[indexPath.row]
        }
        else{
            cell.detailTextLabel?.text = "??????????"
            cell.textLabel?.text = "????????????"
        }
        return cell
    }
}
