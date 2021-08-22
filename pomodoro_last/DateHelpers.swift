//
//  DateHelpers.swift
//  pomodoro_last
//
//  Created by Apollo Callero on 4/24/21.
//

import Foundation


//firstNode was before second
func earlierThan(n1: dataNode,n2: dataNode) -> Bool{
    /*
     utility function to figure what data node was made first
     returns true of n2 was made after n1
     */
    if n1.madeYear < n2.madeYear {
        return true
    }
    else if n1.madeMonth < n2.madeMonth && n1.madeYear <= n2.madeYear{
        return true
    }
    
    else if n1.madeDay < n2.madeDay && n1.madeMonth <= n2.madeMonth && n1.madeYear <= n2.madeYear{
        return true
    }
    return false
}

func sortByDate(nodes: [dataNode]) -> [dataNode]{
    if nodes.count < 2{
        return nodes
    }
    print("yuh")
    var tempN = nodes
    
    for i in 0...nodes.count - 1{

        for j in 0...nodes.count - 2{
            if earlierThan(n1: tempN[j+1],n2: tempN[j]){
                tempN.swapAt(j+1,j)
            }
        }
    }
    return tempN
}

func getDate() -> String{
    //get current date
    let now = Date()
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "nl_NL")
    formatter.setLocalizedDateFormatFromTemplate("dd-MM-yyyy")
    let dateTime = formatter.string(from: now)
    return dateTime
}
//func secondsBetween()
