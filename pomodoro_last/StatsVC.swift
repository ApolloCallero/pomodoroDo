//
//  StatsVC.swift
//  Pomodoro
//
//  Created by Apollo Callero on 4/3/21.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import Charts

class StatsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("stats")
        // Do any additional setup after loading the view.
        //self.getData()
    }


    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var allStudySessions = [Int]()
    var dataNodes = [dataNode]()
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        //all time
        case 0:
            self.allSessions()
        //monthly
        case 1:
            self.viewMonthly()
        //weekly
        case 2:
            self.viewWeekly()
        default:
            break
        }
    }
    
    @IBOutlet weak var chartView: BarChartView!
    
    //firebase.firestore.FieldValue.serverTimestamp()
    func getData() {
        self.dataNodes = []
        self.allStudySessions = []
        let email = UserDefaults.standard.string(forKey: "email")!
        //let password = UserDefaults.standard.string(forKey: "password")!
        let collectionStudy = Firestore.firestore().collection(email  + "StudySession")
        collectionStudy.getDocuments() { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let minutes = document.get("StudySessionTime") as! Int
                    let dateMade = document.get("date") as! String
                    self.allStudySessions.append(minutes)
                    self.dataNodes.append(dataNode(isStudySess_: true, minutes_: minutes, date_: dateMade, currentDate_: getDate()))
                }
                self.allSessions()
            }
        }
        print("out closure",self.allStudySessions)
    }
    
    func viewMonthly(){
        self.dataNodes = sortByDate(nodes: self.dataNodes)
        chartView.animate(yAxisDuration: 2.0)
        chartView.pinchZoomEnabled = false
        chartView.drawBarShadowEnabled = false
        chartView.drawBordersEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.drawGridBackgroundEnabled = true
        chartView.noDataText = "No Data available for Chart"
        var dataEntries: [BarChartDataEntry] = []
        var arrIndex = 0
        for node in self.dataNodes {
            if node.occuredMonth{
                let dataEntry = BarChartDataEntry(x: Double(arrIndex), y: Double(node.minutes))
                dataEntries.append(dataEntry)
                arrIndex = arrIndex + 1
                
            }
            
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
    }
    
    func viewWeekly(){
        self.dataNodes = sortByDate(nodes: self.dataNodes)
        chartView.animate(yAxisDuration: 2.0)
        chartView.pinchZoomEnabled = false
        chartView.drawBarShadowEnabled = false
        chartView.drawBordersEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.drawGridBackgroundEnabled = true
        chartView.noDataText = "No Data available for Chart"
        var dataEntries: [BarChartDataEntry] = []
        var arrIndex = 0
        for node in self.dataNodes {
            if node.occuredWeek{
            let dataEntry = BarChartDataEntry(x: Double(arrIndex), y: Double(node.minutes))
            dataEntries.append(dataEntry)
            arrIndex = arrIndex + 1}
            
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
    }
    
    
    
    
    func allSessions(){
        self.dataNodes = sortByDate(nodes: self.dataNodes)
        chartView.animate(yAxisDuration: 2.0)
        chartView.pinchZoomEnabled = false
        chartView.drawBarShadowEnabled = false
        chartView.drawBordersEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.drawGridBackgroundEnabled = true
        chartView.noDataText = "No Data available for Chart"
        var dataEntries: [BarChartDataEntry] = []
        var arrIndex = 0
        for i in self.dataNodes {
            let dataEntry = BarChartDataEntry(x: Double(arrIndex), y: Double(i.minutes))
            dataEntries.append(dataEntry)
            arrIndex = arrIndex + 1
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
    }
    override func viewDidAppear(_ animated: Bool) {
        self.dataNodes = []
        self.getData()
    }
}



