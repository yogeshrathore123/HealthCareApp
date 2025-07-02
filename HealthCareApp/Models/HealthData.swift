//
//  HealthData.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
//

import Foundation
import Combine

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

// MARK: - Appointment Model
final class Appointment: Identifiable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var doctor: String
    @Published var date: Date
    @Published var location: String
    @Published var notes: String?
    @Published var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        doctor: String,
        date: Date,
        location: String,
        notes: String? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.doctor = doctor
        self.date = date
        self.location = location
        self.notes = notes
        self.isCompleted = isCompleted
    }
}

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

// MARK: - Health Summary Model
struct HealthSummary: Codable {
    var steps: Int
    var heartRate: Int
    var calories: Int
    var sleepHours: Double
    var waterIntake: Double // in liters
    var date: Date
}

// MARK: - Mock Data
struct MockData {
    static let sampleUser = User(
        name: "John Doe",
        age: 35,
        gender: .male,
        height: 175.0,
        weight: 70.0
    )
    
    static let sampleAppointments = [
        Appointment(
            title: "Annual Checkup",
            doctor: "Dr. Sarah Johnson",
            date: Date().addingTimeInterval(86400), // Tomorrow
            location: "City Medical Center",
            notes: "Bring your recent blood test results"
        ),
        Appointment(
            title: "Dental Cleaning",
            doctor: "Dr. Michael Chen",
            date: Date().addingTimeInterval(172800), // Day after tomorrow
            location: "Bright Smile Dental",
            notes: "Regular cleaning and checkup"
        ),
        Appointment(
            title: "Cardiology Consultation",
            doctor: "Dr. Emily Rodriguez",
            date: Date().addingTimeInterval(604800), // Next week
            location: "Heart Care Institute",
            notes: "Follow-up appointment"
        )
    ]
    
    static let sampleMedications = [
        Medication(
            name: "Vitamin D3",
            dosage: "1000 IU",
            frequency: "Daily",
            reminderTimes: [Date().addingTimeInterval(60*60*8)],
            timeOfDay: .morning,
            foodRelation: .afterFood
        ),
        Medication(
            name: "Omega-3",
            dosage: "1000 mg",
            frequency: "Daily",
            reminderTimes: [Date().addingTimeInterval(60*60*18)],
            timeOfDay: .evening,
            foodRelation: .beforeFood
        ),
        Medication(
            name: "Blood Pressure Medication",
            dosage: "10 mg",
            frequency: "Daily",
            reminderTimes: [Date().addingTimeInterval(60*60*8), Date().addingTimeInterval(60*60*20)],
            timeOfDay: .morning,
            foodRelation: .beforeFood
        ),
        Medication(
            name: "Sleep Aid",
            dosage: "5 mg",
            frequency: "As needed",
            reminderTimes: [Date().addingTimeInterval(60*60*22)],
            timeOfDay: .night,
            foodRelation: .none
        )
    ]
    
    static let sampleHealthSummary = HealthSummary(
        steps: 8420,
        heartRate: 72,
        calories: 1850,
        sleepHours: 7.5,
        waterIntake: 2.1,
        date: Date()
    )
} 
