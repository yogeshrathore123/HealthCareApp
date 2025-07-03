//
//  User.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 03/07/25.
//

import Foundation

// MARK: - User Model
struct User: Identifiable, Codable {
    var id = UUID()
    var name: String
    var age: Int
    var gender: Gender
    var height: Double // in cm
    var weight: Double // in kg
    
    enum Gender: String, CaseIterable, Codable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
}
