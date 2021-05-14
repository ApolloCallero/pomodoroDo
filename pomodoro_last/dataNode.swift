//
//  dataNode.swift
//  pomodoro_last
//
//  Created by Apollo Callero on 4/19/21.
//class to represent each Study/breakSession

import Foundation
class dataNode{
    
    let myCalendar = Calendar(identifier: .gregorian)
    //let weekDay: String
    var date : String
    var currentDate : String
    
    // to be used by statsVC
    var occuredMonth : Bool
    var occuredWeek : Bool
    var daysBefore : Int // days before current date
    
    var isStudySess : Bool
    var minutes: Int
    //
    
    var currentMonth : Int
    var currentDay : Int
    var currentYear: Int
    var madeMonth : Int
    var madeDay : Int
    var madeYear : Int
    init(isStudySess_: Bool, minutes_: Int, date_: String,currentDate_: String) {
        self.date = date_
        self.minutes = minutes_
        self.isStudySess = isStudySess_
        self.currentDate = currentDate_
        //set date of study session
        self.madeDay = getDay(stringDate: date_)
        self.madeMonth = getMonth(stringDate: date_)
        self.madeYear = getYear(stringDate: date_)
        //set date of when the
        self.currentDay = getDay(stringDate: currentDate_)
        self.currentMonth = getMonth(stringDate: currentDate_)
        self.currentYear = getYear(stringDate: currentDate_)
        self.occuredMonth = happendMonth(currentD: currentDay, currentM: currentMonth, currentYear: currentYear, createdD: madeDay, createdM: madeMonth,createdYear:madeYear)
        self.occuredWeek = happendWeek(currentD: currentDay, currentM: currentMonth, currentYear: currentYear, createdD: madeDay, createdM: madeMonth,createdYear:madeYear)
        self.daysBefore = daysBeforeCurr(year: madeYear, month: madeMonth, day:madeDay , currYear: currentYear, currMonth: currentMonth, currDay: currentDay)
    }


}
    
    

func daysBeforeCurr(year:Int , month: Int, day: Int, currYear: Int, currMonth: Int, currDay: Int) -> Int{
    var sessionMade = NSDateComponents()
    sessionMade.year = year
    sessionMade.month = month
    sessionMade.day = day

    var curr = NSDateComponents()
    curr.year = currYear
    curr.month = currMonth
    curr.day = currDay
    // Get NSDate given the above date components
    var today = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: curr as DateComponents)
    var madeDate = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: sessionMade as DateComponents)
    let diffInDays = Calendar.current.dateComponents([.day], from: madeDate!, to: today!).day
    print("diff", diffInDays)
    return diffInDays!
}
//Assuming each month is only 30 days
func happendMonth(currentD: Int,currentM:Int,currentYear:Int,createdD:Int,createdM:Int,createdYear: Int ) -> Bool{
    //regular same month case
    if createdM == currentM && currentYear == currentYear{
        return true
    }
    else if currentM == createdM + 1 && currentYear == createdYear{
        let daysBefore = 30 - createdD
        if currentD + daysBefore > 30{
            return false
        }
        return true
    }
    else if currentYear == createdYear + 1 && createdM == 12 && currentM == 1{
        let daysBefore = 31 - createdD //31 days in decemebr
        if currentD + daysBefore <= 30{
            return true
        }
        return false
    }
    return false
}

func happendWeek(currentD: Int,currentM:Int,currentYear:Int,createdD:Int,createdM:Int,createdYear: Int ) -> Bool{
    
    //regualr 'middle' case
    if currentD <= createdD + 7 && currentM == createdM && currentYear == createdYear{
        return true
    }
    //new month happened case
    else if currentM == createdM + 1 && currentYear == createdYear{
        let daysBefore = 30 - createdD
        if currentD + daysBefore >= 7{
            return false
        }
        else{
            return true
        }
    }
    //new year case
    else if currentYear == createdYear + 1 && createdM == 12 && currentM == 1{
        let daysBefore = 31 - createdD //31 days in decemebr
        if currentD + daysBefore <= 7{
            return true
        }
        return false
    }
    return false
}



    //functions to format the string date to ints
    //dd-mm-yyyy
    func getDay(stringDate: String) -> Int{
        if stringDate[stringDate.index(stringDate.startIndex, offsetBy: 0)] == "0"{
            let day2 = stringDate[stringDate.index(stringDate.startIndex, offsetBy: 1)]
            return Int("\(day2)")!
        }
        else{
            let day = stringDate[stringDate.index(stringDate.startIndex, offsetBy: 0)]
            let day2 =  stringDate[stringDate.index(stringDate.startIndex, offsetBy: 1)]
            return Int("\(day)\(day2)")!
        }
    }
    func getMonth(stringDate: String) -> Int{
        if stringDate[stringDate.index(stringDate.startIndex, offsetBy: 3)] == "0"{
            let m2 = stringDate[stringDate.index(stringDate.startIndex, offsetBy: 4)]
            return Int("\(m2)")!
        }
        else{
            let month = stringDate[stringDate.index(stringDate.startIndex, offsetBy: 3)]
            let month2 =  stringDate[stringDate.index(stringDate.startIndex, offsetBy: 4)]
            return Int("\(month)\(month2)")!
        }
    }
    func getYear(stringDate: String) -> Int{
        let one = stringDate[stringDate.index(stringDate.startIndex, offsetBy: 6)]
        let two = stringDate[stringDate.index(stringDate.startIndex, offsetBy: 7)]
        let three = stringDate[stringDate.index(stringDate.startIndex, offsetBy: 8)]
        let four = stringDate[stringDate.index(stringDate.startIndex, offsetBy: 9)]
        
        return Int("\(one)\(two)\(three)\(four)")!
     
    }
    


   



