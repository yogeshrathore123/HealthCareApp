//
//  Medication.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 03/07/25.
//

import Foundation

// MARK: - Medication Model
struct Medication: Identifiable, Codable {
    var id = UUID()
    var name: String
    var dosage: String
    var frequency: String
    var reminderTimes: [Date] // Array of reminder times
    var timeOfDay: TimeOfDay
    var foodRelation: FoodRelation
    var isTaken: Bool = false
    var lastTaken: Date?
    
    enum TimeOfDay: String, CaseIterable, Codable {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
        case night = "Night"
    }
    
    enum FoodRelation: String, CaseIterable, Codable {
        case beforeFood = "Before Food"
        case afterFood = "After Food"
        case none = "None"
    }
}

extension Medication: Equatable {
    static func == (lhs: Medication, rhs: Medication) -> Bool {
        lhs.id == rhs.id
    }
}
