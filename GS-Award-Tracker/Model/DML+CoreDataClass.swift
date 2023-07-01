//
//  DML+CoreDataClass.swift
//  GS-Award-Tracker
//
//  Created by Diya V Gounder on 8/21/22.
//
//

import Foundation
import CoreData

var totalTime = 0

@objc(DML)
public class DML: NSManagedObject {

    func addTime(plusTime : Int) {
        totalTime += plusTime

    }
    
    func resultTime() -> Double {
        return Double(totalTime)/60.0
    }
}
