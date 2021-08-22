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
    var email:String
    init(n: String, mins:Int, e:String) {
        name = n
        timeStudy = mins
        email = e
        print(name,":",timeStudy)
    }
}
