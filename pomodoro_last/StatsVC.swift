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
        //segmentedControl.selectedSegmentIndex =  1
        self.getData()
        
        //init chart view values
        chartView.pinchZoomEnabled = false
        chartView.drawBarShadowEnabled = false
        chartView.drawBordersEnabled = true
        chartView.doubleTapToZoomEnabled = false
        chartView.drawGridBackgroundEnabled = true
        chartView.noDataText = "No Data available for Chart"
        chartView.drawValueAboveBarEnabled = false
        //self.viewMonthly()
    }


    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var allStudySessions = [Int]()
    var dataNodes = [dataNode]()
    
    
    var firstLoad = true
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
    }
    
    func viewMonthly(){
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
        print("mins:", mins)
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
        chartView.animate(yAxisDuration: 2.0)
        self.dataNodes = sortByDate(nodes: self.dataNodes)
        var dataEntries: [BarChartDataEntry] = []
        let firstDate = self.dataNodes[0].daysBefore
        var mins = [Double]( repeating: 0.0, count: firstDate)//days
        var arrIndex = 0
        for node in self.dataNodes {
            if node.daysBefore <= firstDate{
                mins[firstDate - node.daysBefore] += Double(node.minutes)
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
        xlabel[0] = " agoabcdelmnuvwxyzabcdijklnmopqrstuvwxyzjhbjhbjbhjbhjbjhhhhhhhhhhhhhhhhhhhhjsfhdjdbvhjdf                           \(firstDate) days ago                                                                              Today                        aaaaaaaaaaaaaaaaaaaaaaaaaaaaa "//hacky way to get the xlabel axis to do what i want
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xlabel)
        chartView.xAxis.granularity = 0
    }

}



