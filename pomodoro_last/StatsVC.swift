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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.getStudyData()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //init chart view values
        chartView.pinchZoomEnabled = false
        chartView.drawBarShadowEnabled = false
        chartView.drawBordersEnabled = true
        chartView.doubleTapToZoomEnabled = false
        chartView.drawGridBackgroundEnabled = true
        chartView.noDataText = "No Data available for Chart"
        chartView.drawValueAboveBarEnabled = false
    }


    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var allStudySessions = [Int]()
    var dataNodes = [dataNode]()
    
    
    var load = false
    @IBAction func indexChanged(_ sender: Any) {
        /*
         This function Controls the segmented controller that controls how far back the user wants to see
         their study session, when the segmented controller is changed the corresponding function to dislay the
         appropiapate amount study sessions is called
         a function is called that then chan
         */
        switch segmentedControl.selectedSegmentIndex
        {
        //all study sessions are shown
        case 0:
            self.allSessions()
        //study sessions that occured 30 days ago are shown
        case 1:
            self.viewMonthly()
        //study sessions that occured 7 days ago are shown
        case 2:
            self.viewWeekly()
        default:
            break
        }
    }
    
    @IBOutlet weak var chartView: BarChartView!
    func getStudyData() {
        /*gets all of the users Study sessions and stores them in self.dataNodes as dataNodes and in  self.allStudySessions as minutes
         */
        self.dataNodes = []
        self.allStudySessions = []
        let user = Auth.auth().currentUser

        let collectionStudy = Firestore.firestore().collection(user!.email!).document("StudySessions").collection("StudyDocuments")
        collectionStudy.getDocuments() { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \n\n\n\n)")
            } else {
                let numDocu = querySnapshot!.documents.count
                var count = 0
                for document in querySnapshot!.documents{
                    let minutes = document.get("Time") as! Int
                    let dateMade = document.get("date") as! String
                    self.allStudySessions.append(minutes)
                    self.dataNodes.append(dataNode(isStudySess_: true, minutes_: minutes, date_: dateMade, currentDate_: getDate()))
                    count += 1
                    if numDocu == count{
                        self.load = true
                        self.allSessions()
                    }
                }
                
            }
        }
    }
    
    
    func viewMonthly(){
        /*
         Function to display a chart view of the users study sessions that occured in the last 30 days
         */
        chartView.animate(yAxisDuration: 2.0)
        self.dataNodes = sortByDate(nodes: self.dataNodes)
        var dataEntries: [BarChartDataEntry] = []
        var mins = [Double]( repeating: 0.0, count: 30)//days
        for node in self.dataNodes {
            if node.daysBefore < 30 {
                mins[29 - node.daysBefore] += Double(node.minutes)
            }
        }
        var count = 0
        for _ in mins{
            let dataEntry = BarChartDataEntry(x: Double(count), y: mins[count])
            dataEntries.append(dataEntry)
            count += 1
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        var xlabel = [String]( repeating: " ", count: 6)
        xlabel[0] = " agoabcdelmnopqrstuvwxyzabcdefghijklnmopqrstuvwxyzghhhhhhhhhhhhhhhhhhhhhhjsfhdjdbvhjdf                   30 days ago                          15 days ago                             Today                        aaaaaaaaaaaaaaaaaaaaaaaaaaaaa "//hacky way to get the xlabel axis to do what i want
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xlabel)
        chartView.xAxis.granularity = 0
    }
    
    func viewWeekly(){
        /*
         Function to display a chart view of the users study sessions that occured in the last 7 days
         */
        chartView.animate(yAxisDuration: 2.0)
        var dataEntries: [BarChartDataEntry] = []
        self.dataNodes = sortByDate(nodes: self.dataNodes)
        var mins = [Double]( repeating: 0.0, count: 7)//days
        var arrIndex = 0
        for node in self.dataNodes {
            if node.daysBefore < 7{
                mins[6 - node.daysBefore] += Double(node.minutes)
            }
        }
        var count = 0
        for i in mins{
            let dataEntry = BarChartDataEntry(x: Double(count), y: mins[count])
            dataEntries.append(dataEntry)
            count += 1
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        var xlabel = [String]( repeating: " ", count: 6)
        xlabel[0] = " agoabcdelmnuvwxyzabcdijklnmopqrstuvwxyzghhhhhhhhhhhhhhhhhhhhhhjsfhdjdbvhjdf                   6 days ago                           3 days ago                                 Today                        aaaaaaaaaaaaaaaaaaaaaaaaaaaaa "//hacky way to get the xlabel axis to do what i want
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xlabel)
        chartView.xAxis.granularity = 0
    }
    
    
    
    
    func allSessions(){
        /*
         Function to display a chart view of ALL the users study sessions
         */
        chartView.animate(yAxisDuration: 2.0)
        self.dataNodes = sortByDate(nodes: self.dataNodes)
        var dataEntries: [BarChartDataEntry] = []
        var firstDate = self.dataNodes[0].daysBefore
        var dayOne = false
        if firstDate == 0{
            firstDate = 1
            dayOne = true
        }
        var mins = [Double]( repeating: 0.0, count: firstDate)//days
        var arrIndex = 0
        for node in self.dataNodes {
            if node.daysBefore == 0{
                mins[0] += Double(node.minutes)
            }
            else{
                mins[node.daysBefore - 1] += Double(node.minutes)
            }
        }
        mins.reverse()
        var count = 0
        for i in mins{
            let dataEntry = BarChartDataEntry(x: Double(count), y: mins[count])
            dataEntries.append(dataEntry)
            count += 1
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        var xlabel = [String]( repeating: " ", count: 6)
        
        
        if dayOne{
            xlabel[0] = " "
        }
        else{
            xlabel[0] = " agoabcdelmnuvwxyzabcdijklnmopqrstuvwxyzjhbjhbjbhjbhjbjhhhhhhhhhhhhhhhhhhhhjsfhdjdbvhjdf                           \(firstDate) days ago                                                                              Today                        aaaaaaaaaaaaaaaaaaaaaaaaaaaaa "
        }
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xlabel)
        chartView.xAxis.granularity = 0
    }

}



