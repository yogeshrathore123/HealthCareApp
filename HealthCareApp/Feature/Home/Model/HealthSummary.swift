//
//  HealthSummary.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 03/07/25.
//

import Foundation

// MARK: - Health Summary Model
struct HealthSummary: Codable {
    var steps: Int
    var heartRate: Int
    var calories: Int
    var sleepHours: Double
    var waterIntake: Double // in liters
    var date: Date
}
