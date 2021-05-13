//
//  person.swift
//  pomodoro_last
//
//  Created by Apollo Callero on 4/24/21.
//

import Foundation
class Person {
    var name: String
    var timeStudy: Int
    
    init(n: String, mins:Int) {
        name = n
        timeStudy = mins
        print(name,":",timeStudy)
    }
}
